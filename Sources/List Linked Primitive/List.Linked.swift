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
import Index_Primitives

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
}

// The Bounded variant, and the Peek/Reversed tag-namespace enums, live in their own files
// (single-type-per-file): List.Linked.Bounded.swift, List.Linked.Peek.swift,
// List.Linked.Reversed.swift, List.Linked.Bounded.Peek.swift, List.Linked.Bounded.Reversed.swift.

// MARK: - Conditional Conformances (co-located per [COPY-FIX-004])

/// `__ListLinked` is `Copyable` exactly when its column is — the S5 chain through `Shared`.
/// `Element: ~Copyable` is restated per [MEM-COPY-004] (copyability flows from `S`, not the element).
extension __ListLinked: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline (single-owner move-only, or CoW-restored `Shared`).
/// `S: ~Copyable` is restated (M1/[MEM-COPY-004]) so the conformance reaches the move-only column.
extension __ListLinked: @unchecked Sendable where S: Sendable, S: ~Copyable, Element: ~Copyable {}

// __ListLinked.Bounded's Copyable/Sendable conformances live in List.Linked.Bounded.swift
// (conditional conformance to a suppressible protocol must be co-located with the struct).
