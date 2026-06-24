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

// MARK: - removeAll()

extension List.Linked where Element: Copyable {
    /// Removes all elements from the list.
    @inlinable
    public mutating func removeAll() {
        clear(keepingCapacity: false)
    }
}
