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
public import List_Primitives_Core
import Sequence_Primitives

// MARK: - Sequence.Clearable Conformance

extension List.Linked.Inline: Sequence.Clearable where Element: Copyable {
    /// Removes all elements from the inline list.
    ///
    /// This enables `.forEach.consuming { }` pattern via `Property.Inout` extension.
    @inlinable
    public mutating func removeAll() {
        clear()
    }
}
