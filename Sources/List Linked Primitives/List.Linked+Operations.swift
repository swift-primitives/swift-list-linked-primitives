public import Buffer_Linked_Primitive
public import Index_Primitives
public import List_Linked_Primitive

extension __ListLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, N>
{

    @inlinable
    public var count: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(UInt(_buffer.count))
    }

    @inlinable
    public var isEmpty: Bool { _buffer.isEmpty }

    @inlinable
    public var capacity: Index_Primitives.Index<Element>.Count {
        Index_Primitives.Index<Element>.Count(UInt(_buffer.capacity))
    }
}

extension __ListLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, N>
{

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

    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

extension __ListLinked
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public mutating func prepend(_ element: Element)
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >
    {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertFront(element)
        } catch {
            fatalError("List.Linked.prepend: insertion failed after capacity ensured: \(error)")
        }
    }

    @inlinable
    public mutating func append(_ element: Element)
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >
    {
        if _buffer.isFull { _buffer.ensureCapacity(_buffer.count + 1) }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError("List.Linked.append: insertion failed after capacity ensured: \(error)")
        }
    }

    @inlinable
    public mutating func reserve(_ minimumCapacity: Int)
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >
    {
        _buffer.ensureCapacity(minimumCapacity)
    }
}

extension __ListLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, N>
{

    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? { _buffer.removeFront() }

    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? { _buffer.removeBack() }

    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

extension __ListLinked
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, N>
{

    @inlinable
    public func peekFront<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekFront(body) }

    @inlinable
    public func peekBack<R>(_ body: (borrowing Element) -> R) -> R? { _buffer.peekBack(body) }

    @inlinable
    public func forEach(_ body: (borrowing Element) -> Void) { _buffer.forEach(body) }

    @inlinable
    public func forEachReversed(_ body: (borrowing Element) -> Void) {
        precondition(N >= 2, "forEachReversed requires N >= 2 (doubly-linked)")
        _buffer.forEachReversed(body)
    }
}

extension __ListLinked
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public var first: Element? { _buffer.first() }

    @inlinable
    public var last: Element? { _buffer.last() }

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
