// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Buffer_Linked_Primitive
public import Index_Primitives
public import List_Primitives

// MARK: - List.Linked (the ADT tier — generic over the storage COLUMN)
//
// The ratified two-column design (mirrors `Array<S>`, `PROPOSAL-tower-perfected-design.md` §1.3):
// `List.Linked` is a thin semantic discipline over a `Buffer<S>.Linked<N>`, generic over the
// storage column `S`, and **copyability flows from the column** — `Buffer<Ownership.Shared<…>>.Linked` is
// `Copyable` when the element is, so `List<E>.Linked<Ownership.Shared<…>, N>` is the value-semantic (CoW)
// column and `List<E>.Linked<Storage<…>.Generational<…>, N>` stays the zero-cost move-only column.
//
// The user element is the node's payload (`S.Element == Node<Element, N>`), pinned here at the
// type level because `Element` is in scope from `List`. Convenience typealiases (`List<E>.Doubly`,
// `List<E>.Value.Doubly`, …) hide the verbose column spelling.

extension List where Element: ~Copyable {

    /// A linked list with `N` links per node, over an explicit storage column.
    ///
    /// - `Linked<S, 1>`: singly-linked (forward link; `popLast` is O(n))
    /// - `Linked<S, 2>`: doubly-linked (forward + backward; `popLast` is O(1))
    ///
    /// Prefer the column typealiases — `List<E>.Doubly` / `List<E>.Singly` (move-only) and
    /// `List<E>.Value.Doubly` / `List<E>.Value.Singly` (CoW) — over spelling `S` directly.
    /// - Important: The storage-capability constraint (`S: Store.Generational.`Protocol``,
    ///   `S.Element == Node<Element, N>`) is deliberately NOT on the type — it lives on the
    ///   operation extensions, exactly as `Buffer.Linked` does it. Putting it on the type forces
    ///   the column's `Store.Generational.`Protocol`` conformance into the (deeply-nested) type
    ///   metadata, which miscompiles cross-package for the `Shared` (CoW) column on Apple Swift
    ///   6.3.2 (SIGSEGV on bare construction). Keeping the type bound to `S: ~Copyable` only,
    ///   and constraining at the call sites, avoids embedding that conformance in the metadata.
    @frozen
    public struct Linked<S: ~Copyable, let N: Int>: ~Copyable {

        /// The backing linked buffer over the storage column.
        @usableFromInline
        package var _buffer: Buffer<S>.Linked<N>

        @inlinable
        package init(_buffer: consuming Buffer<S>.Linked<N>) {
            self._buffer = _buffer
        }

        /// Tag namespace for the borrowing `peek` accessor.
        public enum Peek {}

        /// Tag namespace for the borrowing `reversed` accessor.
        public enum Reversed {}

        // MARK: - Bounded variant (nested for ~Copyable propagation, [MEM-COPY-006])

        /// A fixed-capacity linked list — allocates storage upfront and throws on overflow.
        ///
        /// Use when capacity is known or in contexts requiring predictable memory behavior
        /// (embedded, real-time). Shares the same storage column `S` as its enclosing `Linked`.
        @frozen
        public struct Bounded: ~Copyable {
            /// The backing linked buffer over the storage column.
            @usableFromInline
            package var _buffer: Buffer<S>.Linked<N>

            /// The maximum number of elements the list can hold.
            public let capacity: Index_Primitives.Index<Element>.Count

            @inlinable
            package init(_buffer: consuming Buffer<S>.Linked<N>, capacity: Index_Primitives.Index<Element>.Count) {
                self._buffer = _buffer
                self.capacity = capacity
            }

            /// Tag namespace for the borrowing `peek` accessor.
            public enum Peek {}

            /// Tag namespace for the borrowing `reversed` accessor.
            public enum Reversed {}
        }
    }
}

// MARK: - Conditional Conformances (co-located per [COPY-FIX-004])

/// `List.Linked` is `Copyable` exactly when its column is — the S5 chain through `Shared`.
/// `Element: ~Copyable` is restated per [MEM-COPY-004] (copyability flows from `S`, not the element).
extension List.Linked: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline (single-owner move-only, or CoW-restored `Shared`).
extension List.Linked: @unsafe @unchecked Sendable where S: Sendable, Element: ~Copyable {}

/// `List.Linked.Bounded` is `Copyable` exactly when its column is — the S5 chain.
extension List.Linked.Bounded: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline.
extension List.Linked.Bounded: @unsafe @unchecked Sendable where S: Sendable, Element: ~Copyable {}

// MARK: - Column Typealiases (ergonomic spellings)

extension List where Element: ~Copyable {
    /// Doubly-linked, move-only (zero-cost default column).
    public typealias Doubly =
        Linked<Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>, 2>

    /// Singly-linked, move-only (zero-cost default column).
    public typealias Singly =
        Linked<Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>, 1>
}

extension List where Element: Copyable {
    /// Value-semantic (CoW) linked-list columns.
    public enum Value {
        /// Doubly-linked, value-semantic (the `Shared` CoW column).
        public typealias Doubly =
            List<Element>.Linked<
                Ownership.Shared<Node<Element, 2>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>>,
                2
            >

        /// Singly-linked, value-semantic (the `Shared` CoW column).
        public typealias Singly =
            List<Element>.Linked<
                Ownership.Shared<Node<Element, 1>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>>,
                1
            >
    }
}
