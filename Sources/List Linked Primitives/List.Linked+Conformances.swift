public import Buffer_Linked_Primitive
public import List_Linked_Primitive

extension __ListLinked: Equatable
where
    S: Copyable, Element: Equatable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._buffer.count == rhs._buffer.count else { return false }
        var left: [Element] = []
        lhs._buffer.forEach { (element: borrowing Element) in left.append(copy element) }
        var right: [Element] = []
        rhs._buffer.forEach { (element: borrowing Element) in right.append(copy element) }
        return left == right
    }
}

extension __ListLinked: Hashable
where
    S: Copyable, Element: Hashable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public func hash(into hasher: inout Hasher) {
        var elements: [Element] = []
        _buffer.forEach { (element: borrowing Element) in elements.append(copy element) }
        hasher.combine(elements)
    }
}

extension __ListLinked.Bounded: Equatable
where
    S: Copyable, Element: Equatable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._buffer.count == rhs._buffer.count else { return false }
        var left: [Element] = []
        lhs._buffer.forEach { (element: borrowing Element) in left.append(copy element) }
        var right: [Element] = []
        rhs._buffer.forEach { (element: borrowing Element) in right.append(copy element) }
        return left == right
    }
}

extension __ListLinked.Bounded: Hashable
where
    S: Copyable, Element: Hashable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public func hash(into hasher: inout Hasher) {
        var elements: [Element] = []
        _buffer.forEach { (element: borrowing Element) in elements.append(copy element) }
        hasher.combine(elements)
    }
}

extension __ListLinked
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}

extension __ListLinked.Bounded
where
    Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{

    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}

extension __ListLinked: Swift.Sequence
where
    S: Copyable, Element: Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{}

extension __ListLinked.Bounded: Swift.Sequence
where
    S: Copyable, Element: Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N>
{}
