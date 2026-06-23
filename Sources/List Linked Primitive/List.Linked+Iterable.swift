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

public import List_Primitives_Core
public import Iterable
public import Iterator_Primitive
public import Iterator_Chunk_Primitives

// MARK: - Iterable (multipass, borrowing) — via materialising adapter
//
// The pointer-chained list type has NO contiguous element span, so — unlike the contiguous
// single-element containers (set-ordered / stack / heap) which vend `Iterator.Chunk` over a
// `Span.Protocol` span — `List.Linked` produces its bulk iterator by wrapping
// the scalar node-walk `Iterator` in `Iterator.Materializing`, the span-primitive adapter for
// generator-style sequences (the same shape `Single` / dict-ordered use). The list therefore
// does NOT conform `Span.Protocol` (no element span exists).
//
// Both `Iterable` and `Sequenceable` declare `associatedtype Iterator`, which Swift unifies
// across protocols; the dual conformer splits the two bindings with `@_implements`.
// `Iterable.Iterator` binds to the materialising bulk iterator here; `Sequenceable.Iterator`
// binds to the scalar `Iterator` (List.Linked+Sequenceable.swift).
//
// The borrowing `makeIterator()` is a public member in the type module per [MOD-036].

extension List.Linked: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    /// Iterable's bulk span witness: wraps the scalar node-walk iterator in the generator
    /// materialise adapter.
    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator() -> Iterator_Primitive.Iterator.Materializing<Iterator> {
        Iterator_Primitive.Iterator.Materializing(Iterator(inner: _buffer.makeIterator()))
    }
}
