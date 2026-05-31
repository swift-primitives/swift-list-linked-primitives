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
internal import Buffer_Linked_Inline_Primitives
public import Iterator_Primitive
public import Iterator_Protocol

// MARK: - Scalar node-walk iterator (Inline, snapshot)
//
// `List.Linked.Inline` is unconditionally `~Copyable`: its inline `@_rawLayout` node storage
// cannot back a `Copyable` stdlib iterator, and a pointer cursor into that storage cannot
// survive the `consuming` `Sequenceable.makeIterator()` (the inline bytes move). So — like
// dict-ordered's inline-storage variants — the scalar iterator SNAPSHOTS the elements (via the
// buffer's `~Copyable`-safe `forEach` node-walk) into an owned `[Element]` and walks that.
// Snapshot is gated on `Element: Copyable` (the materialise constraint). The list still does
// NOT conform `Memory.Contiguous.Protocol` (no element span exists).
//
// In the type module per [MOD-036]: `_snapshotIterator()` names the buffer's forEach window.

extension List.Linked.Inline where Element: Copyable {
    /// A single-pass scalar iterator over a snapshot of the inline list's elements, front to back.
    ///
    /// Built by node-walking the inline buffer into an owned array (avoids pointer-escape from
    /// the inline `@_rawLayout` storage). Scalar source for both the materialising `Iterable`
    /// face and the consuming `Sequenceable` face.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _snapshot: [Element]

        @usableFromInline
        var _position: Int

        @inlinable
        init(snapshot: consuming [Element]) {
            self._snapshot = snapshot
            self._position = 0
        }

        @inlinable
        public mutating func next() -> Element? {
            guard _position < _snapshot.count else { return nil }
            defer { _position += 1 }
            return _snapshot[_position]
        }
    }

    /// Builds an owned snapshot of the inline storage by node-walking the buffer.
    @inlinable
    func _snapshotIterator() -> Iterator {
        var snapshot: [Element] = []
        _buffer.forEach { snapshot.append($0) }
        return Iterator(snapshot: snapshot)
    }
}
