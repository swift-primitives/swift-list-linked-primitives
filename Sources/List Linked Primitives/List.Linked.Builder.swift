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

extension List.Linked where Element: ~Copyable {
    /// A result builder for declaratively constructing linked lists.
    ///
    /// The builder appends each declared element to the back of the list
    /// in declaration order. Consumers iterating from the head of the list
    /// (e.g., `popFirst()`) see elements in the same order they were
    /// declared.
    ///
    /// ```swift
    /// let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
    ///     1
    ///     2
    ///     3
    /// }
    /// // popFirst() returns 1, then 2, then 3.
    /// ```
    ///
    /// Supports `~Copyable` elements via consuming append:
    ///
    /// ```swift
    /// struct FileHandle: ~Copyable { ... }
    /// let list: List<FileHandle>.Linked<2> = List<FileHandle>.Linked<2> {
    ///     FileHandle()
    ///     FileHandle()
    /// }
    /// ```
    ///
    /// ## `for` Loops Not Supported
    ///
    /// `buildArray` is omitted because Swift's result-builder transform's
    /// buildArray step uses `Swift.Array<Component>`, which currently
    /// requires `Component: Copyable`. The component here is the
    /// ~Copyable `List<Element>.Linked<N>`.
    @resultBuilder
    public enum Builder {

        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(
            _ expression: consuming Element
        ) -> List<Element>.Linked<N> {
            var result = List<Element>.Linked<N>()
            result.append(consume expression)
            return result
        }

        @inlinable
        public static func buildExpression(
            _ expression: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            consume expression
        }

        @inlinable
        public static func buildExpression(
            _ expression: consuming Element?
        ) -> List<Element>.Linked<N> {
            var result = List<Element>.Linked<N>()
            if let value = consume expression {
                result.append(consume value)
            }
            return result
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(
            first: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            consume first
        }

        @inlinable
        public static func buildPartialBlock(
            first: Void
        ) -> List<Element>.Linked<N> {
            List<Element>.Linked<N>()
        }

        @inlinable
        public static func buildPartialBlock(
            first: Never
        ) -> List<Element>.Linked<N> {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: consuming List<Element>.Linked<N>,
            next: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            var result = consume accumulated
            var rest = consume next
            while let element = rest.popFirst() {
                result.append(consume element)
            }
            return result
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> List<Element>.Linked<N> {
            List<Element>.Linked<N>()
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(
            _ component: consuming List<Element>.Linked<N>?
        ) -> List<Element>.Linked<N> {
            if let result = consume component {
                return consume result
            }
            return List<Element>.Linked<N>()
        }

        @inlinable
        public static func buildEither(
            first: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            consume first
        }

        @inlinable
        public static func buildEither(
            second: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            consume second
        }

        // buildArray omitted: see DocC above.

        @inlinable
        public static func buildLimitedAvailability(
            _ component: consuming List<Element>.Linked<N>
        ) -> List<Element>.Linked<N> {
            consume component
        }
    }
}

// MARK: - Convenience Init

extension List.Linked where Element: ~Copyable {
    /// Constructs a linked list from a result-builder closure.
    ///
    /// Each element is appended to the back of the list in declaration
    /// order. `popFirst()` returns elements in declaration order.
    ///
    /// ```swift
    /// let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
    ///     1
    ///     2
    ///     3
    /// }
    /// ```
    @inlinable
    public init(@List<Element>.Linked<N>.Builder _ builder: () -> Self) {
        self = builder()
    }
}

// MARK: - Sequence Bulk-Add (Copyable Element only)

extension List.Linked.Builder where Element: Copyable {
    /// Bulk-add a Swift.Sequence to the back of the list without
    /// per-iteration allocation.
    @inlinable
    public static func buildExpression<S: Swift.Sequence>(_ expression: S) -> List<Element>.Linked<N>
    where S.Element == Element {
        var result = List<Element>.Linked<N>()
        for value in expression {
            result.append(value)
        }
        return result
    }
}
