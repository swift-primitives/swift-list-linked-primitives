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

// MARK: - Sequenceable witness (consuming makeIterator)
//
// The single-pass consuming scalar iterator over a snapshot — the `Copyable` witness for the
// cold `Sequenceable` conformance (declared in the ops module). A public member in the type
// module per [MOD-036] refined-C; snapshots the inline storage (avoids pointer-escape from the
// `@_rawLayout` inline bytes under the consuming yield).

extension List.Linked.Inline where Element: Copyable {

    /// A single-pass consuming iterator over a snapshot of the inline list's elements.
    /// Witness for `Sequenceable`.
    @inlinable
    public consuming func makeIterator() -> Iterator {
        _snapshotIterator()
    }
}
