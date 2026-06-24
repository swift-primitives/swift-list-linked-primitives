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
internal import Buffer_Linked_Primitive
internal import Buffer_Linked_Primitives

// MARK: - Sequenceable witness (consuming makeIterator)
//
// The single-pass consuming scalar iterator — the `Copyable` witness for the cold
// `Sequenceable` conformance (declared in the ops module). A public member in the type module
// per [MOD-036] refined-C: it copies the backing buffer's iterator state out of the consumed
// bounded list.

extension List.Linked.Bounded where Element: Copyable {

    /// A single-pass consuming iterator over the bounded list's elements, front to back.
    /// Witness for `Sequenceable`.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        Iterator(inner: _buffer.makeIterator())
    }
}
