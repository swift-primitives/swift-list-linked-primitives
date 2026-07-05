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

public import Buffer_Linked_Primitive
public import Index_Primitives
public import List_Linked_Primitive

// MARK: - Properties (seam-generic over the column)

extension __ListLinked.Bounded where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// The current number of elements in the list.
    @inlinable
    public var count: Index_Primitives.Index<Element>.Count { Index_Primitives.Index<Element>.Count(UInt(_buffer.count)) }

    /// Whether the list is empty.
    @inlinable
    public var isEmpty: Bool { _buffer.isEmpty }

    /// Whether the list is at capacity.
    @inlinable
    public var isFull: Bool { _buffer.isFull }
}

// MARK: - Core operations (seam-generic; inserts throw on overflow — no auto-grow)

extension __ListLinked.Bounded where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Adds an element to the front; throws `.overflow` if at capacity.
    @inlinable
    public mutating func prepend(_ element: consuming Element) throws(__ListLinkedBoundedError) {
        guard !isFull else { throw .overflow }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertFront(element)
        } catch {
            fatalError("List.Linked.Bounded.prepend: insertion failed despite capacity check: \(error)")
        }
    }

    /// Adds an element to the back; throws `.overflow` if at capacity.
    @inlinable
    public mutating func append(_ element: consuming Element) throws(__ListLinkedBoundedError) {
        guard !isFull else { throw .overflow }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError("List.Linked.Bounded.append: insertion failed despite capacity check: \(error)")
        }
    }

    /// Removes and returns the first element, or `nil` if empty.
    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? { _buffer.removeFront() }

    /// Removes and returns the last element, or `nil` if empty.
    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? { _buffer.removeBack() }

    /// Removes and returns the first element; throws `.empty` if empty.
    @inlinable
    public mutating func removeFirst() throws(__ListLinkedBoundedError) -> Element {
        guard let element = popFirst() else { throw .empty }
        return element
    }

    /// Removes and returns the last element; throws `.empty` if empty.
    @inlinable
    public mutating func removeLast() throws(__ListLinkedBoundedError) -> Element {
        guard let element = popLast() else { throw .empty }
        return element
    }

    /// Removes all elements (the node store is retained).
    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

// MARK: - Peek / Traversal (seam-generic; mirrors the buffer's borrowing surface)

extension __ListLinked.Bounded where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Borrowing access to the front element without removing it; `nil` if empty.
    @inlinable
    public func peekFront<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekFront(body) }

    /// Borrowing access to the back element without removing it; `nil` if empty.
    @inlinable
    public func peekBack<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekBack(body) }

    /// Calls the given closure for each element, front to back.
    @inlinable
    public func forEach(_ body: (borrowing Element) -> Void) { _buffer.forEach(body) }

    /// Calls the given closure for each element, back to front (requires `N >= 2`).
    @inlinable
    public func forEachReversed(_ body: (borrowing Element) -> Void) {
        precondition(N >= 2, "forEachReversed requires N >= 2 (doubly-linked)")
        _buffer.forEachReversed(body)
    }
}

// MARK: - Convenience accessors (Copyable)

extension __ListLinked.Bounded where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// The first element, or `nil` if empty.
    @inlinable
    public var first: Element? { _buffer.first() }

    /// The last element, or `nil` if empty.
    @inlinable
    public var last: Element? { _buffer.last() }
}
