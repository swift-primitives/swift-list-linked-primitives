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
public import Index_Primitives

extension List.Linked.Bounded where Element: ~Copyable {
    /// Constructs a heap-allocated bounded linked list from a result-builder closure.
    ///
    /// Wraps the dynamic `List<Element>.Linked<N>.Builder` per Round-2
    /// Option Y. Capacity is supplied at the outer init; overflow throws
    /// `Error.overflow` from `List.Linked.Bounded.append`.
    ///
    /// ```swift
    /// let list = try List<Int>.Linked<2>.Bounded(capacity: 8) {
    ///     1; 2; 3
    /// }
    /// ```
    @inlinable
    public init(
        capacity: Index<Element>.Count,
        @List<Element>.Linked<N>.Builder _ builder: () -> List<Element>.Linked<N>
    ) throws(Self.Error) {
        var bounded = try List<Element>.Linked<N>.Bounded(capacity: capacity)
        var dynamic = builder()
        while let elem = dynamic.popFirst() {
            try bounded.append(consume elem)
        }
        self = bounded
    }
}
