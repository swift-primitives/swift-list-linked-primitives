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
// `List.Linked.Small` is unconditionally `~Copyable` and has NO contiguous element span; it
// produces its bulk iterator by wrapping the snapshot scalar `Iterator` in
// `Iterator.Materializing` and does NOT conform `Memory.Contiguous.Protocol`. The unconditional
// `~Copyable` container can still conform `Iterable` (the protocol suppresses Copyable); the
// conformance is gated `where Element: Copyable` because the materialise adapter requires it.
// `@_implements` splits the unified `Iterator` associated type between the two attachables.

extension List.Linked.Small: Iterable where Element: Copyable {
    @_implements(Iterable, Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    /// Iterable's bulk span witness: wraps the snapshot scalar iterator in the generator
    /// materialise adapter.
    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable, makeIterator())
    public borrowing func iterableMakeIterator() -> Iterator_Primitive.Iterator.Materializing<Iterator> {
        Iterator_Primitive.Iterator.Materializing(_snapshotIterator())
    }
}
