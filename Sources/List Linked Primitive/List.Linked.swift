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

// MARK: - __ListLinked (the hoisted ADT carrier — generic over the storage COLUMN)
//
// The ratified two-column design (mirrors `Array<S>`, `Research/adt-tower.md` §9.3):
// `__ListLinked` is a thin semantic discipline over a `Buffer<S>.Linked<N>`, generic over the
// storage column `S`, and **copyability flows from the column** — `Buffer<Ownership.Shared<…>>.Linked`
// is `Copyable` when the element is, so `List<E>.Linked<Ownership.Shared<…>, N>` is the
// value-semantic (CoW) column and `List<E>.Linked<Storage<…>.Generational<…>, N>` stays the
// zero-cost move-only column.
//
// `Element` rides the carrier (unlike the contiguous families, where the user element IS
// `S.Element`): the linked store's element is the NODE (`S.Element == Node<Element, N>`), and
// the seam bound is deliberately kept OFF the type (see the type doc below), so `S.Element` is
// not projectable at the type level — the payload type must be a carrier parameter. The §9.3
// carrier spelling `__ListLinked<S, let N: Int>` elides this parameter, which the enclosing
// `List<Element>` namespace supplied before the hoist.
//
// The public spelling is the front-door NEST alias `List<E>.Linked<S, N>` (D4.1 sense (b),
// [DS-028]) plus the column front doors `List<E>.Doubly` / `.Singly` / `.Value.Doubly` /
// `.Value.Singly` — declared in `List.Linked.FrontDoor.swift`.

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
@_documentation(visibility: public)
@frozen
public struct __ListLinked<Element: ~Copyable, S: ~Copyable, let N: Int>: ~Copyable {

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
    /// (embedded, real-time). Shares the same storage column `S` as its enclosing carrier.
    ///
    /// - Important: This hand-written type is the ratified **W3-blocked residual** of
    ///   `adt-tower.md` §9.6 item 4: the [DS-028] capacity ALIAS (the column-preserving
    ///   `__ListLinked<S.Bounded>` form, law 2) is inexpressible while the linked discipline's
    ///   seam (`Store.Generational.`Protocol``) vends neither `Store.Direct` nor a `Bounded`
    ///   capacity-twin column (W1.5 conformed `Buffer.Linear` + `Buffer.Ring` only; linked op
    ///   generalization is wave W3, §9.1). It migrates to the capacity alias when W3 lands the
    ///   linked twin — do not extend this type in the interim.
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

// MARK: - Conditional Conformances (co-located per [COPY-FIX-004])

/// `__ListLinked` is `Copyable` exactly when its column is — the S5 chain through `Shared`.
/// `Element: ~Copyable` is restated per [MEM-COPY-004] (copyability flows from `S`, not the element).
extension __ListLinked: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline (single-owner move-only, or CoW-restored `Shared`).
/// `S: ~Copyable` is restated (M1/[MEM-COPY-004]) so the conformance reaches the move-only column.
extension __ListLinked: @unsafe @unchecked Sendable where S: Sendable, S: ~Copyable, Element: ~Copyable {}

/// `__ListLinked.Bounded` is `Copyable` exactly when its column is — the S5 chain.
extension __ListLinked.Bounded: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline.
/// `S: ~Copyable` is restated (M1/[MEM-COPY-004]) so the conformance reaches the move-only column.
extension __ListLinked.Bounded: @unsafe @unchecked Sendable where S: Sendable, S: ~Copyable, Element: ~Copyable {}
