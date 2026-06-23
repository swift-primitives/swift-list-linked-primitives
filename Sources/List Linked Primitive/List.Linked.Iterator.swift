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
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Buffer_Linked_Primitive
public import Buffer_Linked_Primitives
public import Iterator_Primitive
public import Iterator_Protocol

// MARK: - Scalar node-walk iterator
//
// `List.Linked` is pointer-chained (Buffer.Linked-backed node pool): it has NO contiguous
// element span, so — unlike the contiguous single-element containers (set-ordered / stack /
// heap) which vend `Iterator.Chunk` over a `Span.Protocol` span — the list
// produces its bulk iterator by wrapping this hand-written scalar node-walk in
// `Iterator.Materializing`, the span-primitive adapter for generator-style sequences (the
// same shape `Single` / dict-ordered use). The list therefore does NOT conform
// `Span.Protocol` (no element span exists).
//
// The scalar walk is IRREDUCIBLE — it follows the link chain through the backing
// `Buffer.Linked` pool — and is NOT deduplicated via any `memory-sequence` bridge or generic
// `Memory.Cursor` (the `swift_getAssociatedTypeWitness` demangle crash). It is kept here as
// a thin wrapper over the buffer's own node-walk cursor.
//
// In the type module per [MOD-036]: the `init(inner:)` captures the buffer's iterator state.
// One scalar `Iterator` serves both `List.Linked` and `List.Linked.Bounded` (both backed by
// `Buffer.Linked<N>`).

extension List.Linked where Element: Copyable {
    /// A single-pass scalar iterator over the list's elements, front to back.
    ///
    /// Walks the backing `Buffer.Linked` node link chain. This is the scalar
    /// `Iterator.`Protocol`` source the materialising bulk iterator
    /// (`Iterator.Materializing`) wraps for the `Iterable` face, and the iterator the
    /// consuming `Sequenceable` face vends directly.
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
