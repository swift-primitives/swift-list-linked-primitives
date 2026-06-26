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
public import List_Primitives

// MARK: - Properties (seam-generic over the column)

extension List.Linked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// The current number of elements in the list.
    @inlinable
    public var count: Index_Primitives.Index<Element>.Count { Index_Primitives.Index<Element>.Count(UInt(_buffer.count)) }

    /// Whether the list is empty.
    @inlinable
    public var isEmpty: Bool { _buffer.isEmpty }

    /// The current capacity of the list.
    @inlinable
    public var capacity: Index_Primitives.Index<Element>.Count { Index_Primitives.Index<Element>.Count(UInt(_buffer.capacity)) }
}

// MARK: - Growing inserts (per column — auto-grow)

extension List.Linked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Adds an element to the front (move-only column; grows as needed).
    @inlinable
    public mutating func prepend(_ element: consuming Element)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertFront(element)
        } catch {
            fatalError("List.Linked.prepend: insertion failed after capacity ensured: \(error)")
        }
    }

    /// Adds an element to the back (move-only column; grows as needed).
    @inlinable
    public mutating func append(_ element: consuming Element)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError("List.Linked.append: insertion failed after capacity ensured: \(error)")
        }
    }

    /// Reserves capacity for at least `minimumCapacity` elements (move-only column).
    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

extension List.Linked where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Adds an element to the front (CoW column; grows as needed, copy-on-write correct).
    @inlinable
    public mutating func prepend(_ element: Element)
    where S == Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>> {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertFront(element)
        } catch {
            fatalError("List.Linked.prepend: insertion failed after capacity ensured: \(error)")
        }
    }

    /// Adds an element to the back (CoW column; grows as needed, copy-on-write correct).
    @inlinable
    public mutating func append(_ element: Element)
    where S == Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>> {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError("List.Linked.append: insertion failed after capacity ensured: \(error)")
        }
    }

    /// Reserves capacity for at least `minimumCapacity` elements (CoW column).
    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where S == Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>> {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

// MARK: - Removal (seam-generic)

extension List.Linked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Removes and returns the first element, or `nil` if empty.
    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? { _buffer.removeFront() }

    /// Removes and returns the last element, or `nil` if empty.
    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? { _buffer.removeBack() }

    /// Removes and returns the first element; throws `.empty` if the list is empty.
    @inlinable
    public mutating func removeFirst() throws(List<Element>.Linked<S, N>.Error) -> Element {
        guard let element = popFirst() else { throw .empty }
        return element
    }

    /// Removes and returns the last element; throws `.empty` if the list is empty.
    @inlinable
    public mutating func removeLast() throws(List<Element>.Linked<S, N>.Error) -> Element {
        guard let element = popLast() else { throw .empty }
        return element
    }

    /// Removes all elements (the node store is retained).
    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

// MARK: - Peek / Traversal (seam-generic)
//
// These mirror the backing buffer's borrowing surface (the `Property.View` `peek.first` form
// cannot thread the column parameter `S` — `Property.Borrow.Typed.Valued` carries `Element` and `N`
// but has no slot for the column). Closure forms support `~Copyable` elements; `first`/`last`
// properties (Copyable) are below.

extension List.Linked where Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
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

// MARK: - Convenience accessors + drain (Copyable)

extension List.Linked where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// The first element, or `nil` if empty.
    @inlinable
    public var first: Element? { _buffer.first() }

    /// The last element, or `nil` if empty.
    @inlinable
    public var last: Element? { _buffer.last() }

    /// Drains elements front-to-back while `predicate` holds, passing each to `body`.
    @inlinable
    public mutating func drain(
        while predicate: (borrowing Element) -> Bool,
        _ body: (consuming Element) -> Void
    ) {
        while let element = first, predicate(element) {
            guard let next = popFirst() else { break }
            body(next)
        }
    }
}
