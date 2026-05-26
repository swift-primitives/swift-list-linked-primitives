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

extension List.Linked.Inline where Element: ~Copyable {
    /// Constructs a fixed-capacity inline linked list from a result-builder closure.
    ///
    /// Wraps the dynamic `List<Element>.Linked<N>.Builder` per Round-2
    /// Option Y. Overflow throws `Error.overflow` from
    /// `List.Linked.Inline.append`.
    ///
    /// ```swift
    /// let list = try List<Int>.Linked<2>.Inline<8> {
    ///     1; 2; 3
    /// }
    /// ```
    @inlinable
    public init(
        @List<Element>.Linked<N>.Builder _ builder: () -> List<Element>.Linked<N>
    ) throws(Self.Error) {
        var dynamic = builder()
        self.init()
        while let elem = dynamic.popFirst() {
            try self.append(consume elem)
        }
    }
}
