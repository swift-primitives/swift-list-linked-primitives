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

public import List_Primitives
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Buffer_Linked_Primitive
public import Buffer_Linked_Primitives
public import Iterator_Primitive
public import Iterator_Protocol

// MARK: - Scalar node-walk iterator (Bounded)
//
// `List.Linked.Bounded` is pointer-chained (Buffer.Linked-backed): no contiguous element span,
// so it produces its bulk iterator by wrapping this hand-written scalar node-walk in
// `Iterator.Materializing` and does NOT conform `Span.Protocol`. The scalar walk
// follows the backing `Buffer.Linked` link chain and is IRREDUCIBLE — not deduplicated via any
// `memory-sequence` bridge or generic `Memory.Cursor`.
//
// In the type module per [MOD-036]: the `init(inner:)` captures the buffer's iterator state.

extension List.Linked.Bounded where Element: Copyable {
    /// A single-pass scalar iterator over the bounded list's elements, front to back.
    ///
    /// Walks the backing `Buffer.Linked` node link chain. Scalar source for both the
    /// materialising `Iterable` face and the consuming `Sequenceable` face.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        package var _inner: Buffer<Storage<Element>.Contiguous<Memory.Heap<Element>>>.Linked<N>.Iterator

        @inlinable
        package init(inner: Buffer<Storage<Element>.Contiguous<Memory.Heap<Element>>>.Linked<N>.Iterator) {
            self._inner = inner
        }

        @inlinable
        public mutating func next() -> Element? {
            _inner.next()
        }
    }
}
