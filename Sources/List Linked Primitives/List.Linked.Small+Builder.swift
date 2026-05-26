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

extension List.Linked.Small where Element: ~Copyable {
    /// Constructs a SmallVec linked list from a result-builder closure.
    ///
    /// Wraps the dynamic `List<Element>.Linked<N>.Builder` per Round-2
    /// Option Y. Non-throwing because Small spills inline capacity to
    /// the heap.
    ///
    /// ```swift
    /// let list = List<Int>.Linked<2>.Small<4> {
    ///     1; 2; 3; 4; 5  // first 4 inline, 5th spills to heap
    /// }
    /// ```
    @inlinable
    public init(
        @List<Element>.Linked<N>.Builder _ builder: () -> List<Element>.Linked<N>
    ) {
        var dynamic = builder()
        self.init()
        while let elem = dynamic.popFirst() {
            self.append(consume elem)
        }
    }
}
