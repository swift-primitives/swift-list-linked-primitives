public import Buffer_Linked_Primitive
public import Index_Primitives
public import List_Linked_Primitive

extension __ListLinked.Bounded
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
    public var isFull: Bool { _buffer.isFull }
}

extension __ListLinked.Bounded
where
    Element: ~Copyable, S: ~Copyable, S: Store.Generational.`Protocol`,
    S.Element == Node<Element, N>
{

    @inlinable
    public mutating func prepend(_ element: consuming Element) throws(__ListLinked.Bounded.Error) {
        guard !isFull else { throw .overflow }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertFront(element)
        } catch {
            fatalError(
                "List.Linked.Bounded.prepend: insertion failed despite capacity check: \(error)"
            )
        }
    }

    @inlinable
    public mutating func append(_ element: consuming Element) throws(__ListLinked.Bounded.Error) {
        guard !isFull else { throw .overflow }
        do throws(Buffer<S>.Linked<N>.Error) {
            try _buffer.insertBack(element)
        } catch {
            fatalError(
                "List.Linked.Bounded.append: insertion failed despite capacity check: \(error)"
            )
        }
    }

    @inlinable
    @discardableResult
    public mutating func popFirst() -> Element? { _buffer.removeFront() }

    @inlinable
    @discardableResult
    public mutating func popLast() -> Element? { _buffer.removeBack() }

    @inlinable
    public mutating func clear() { _buffer.removeAll() }
}

extension __ListLinked.Bounded
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

extension __ListLinked.Bounded
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public var first: Element? { _buffer.first() }

    @inlinable
    public var last: Element? { _buffer.last() }
}
