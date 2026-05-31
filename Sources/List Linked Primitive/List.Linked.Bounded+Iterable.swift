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
// `List.Linked.Bounded` has NO contiguous element span; it produces its bulk iterator by
// wrapping the scalar node-walk `Iterator` in `Iterator.Materializing` and does NOT conform
// `Memory.Contiguous.Protocol`. `@_implements` splits the unified `Iterator` associated type:
// `Iterable.Iterator` binds the materialising bulk iterator here; `Sequenceable.Iterator`
// binds the scalar `Iterator` (List.Linked.Bounded+Sequenceable.swift).

extension List.Linked.Bounded: Iterable where Element: Copyable {
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
