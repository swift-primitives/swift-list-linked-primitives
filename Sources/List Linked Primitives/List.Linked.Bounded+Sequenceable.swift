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

public import List_Linked_Primitive
public import List_Primitives
internal import Sequence_Primitives

// MARK: - Sequenceable (single-pass, consuming)
//
// Re-uses the scalar node-walk `Iterator`. The consuming `makeIterator()` witness is a public
// member in the type module (List.Linked.Bounded+Sequenceable.swift) per [MOD-036] refined-C;
// this conformance is thin and splits the `Iterator` associated-type binding from `Iterable`'s
// via `@_implements`. The per-type `Swift.Sequence` conformance is dropped to match the
// exemplar (deferred stdlib-interop axis).

extension List.Linked.Bounded: Sequenceable where Element: Copyable {
    @_implements(Sequenceable, Iterator)
    public typealias SequenceableIterator = Iterator

    /// Returns the count as the underestimated count since we know the exact size.
    @inlinable
    public var underestimatedCount: Int { Int(bitPattern: count) }
}
