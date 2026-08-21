public import Buffer_Linked_Primitive
public import Index_Primitives

extension __ListLinked where S: ~Copyable, Element: ~Copyable {

    @inlinable
    public init()
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        self.init(
            _buffer: Buffer<S>.Linked<N>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))
            )
        )
    }

    @inlinable
    public init(reservingCapacity capacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        precondition(capacity > 0, "capacity must be positive")
        self.init(
            _buffer: Buffer<S>.Linked<N>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))
            )
        )
    }
}

extension __ListLinked where S: ~Copyable, Element: ~Copyable {

    @inlinable
    public init()
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >,
        Element: Copyable
    {
        self.init(
            _buffer: Buffer<S>.Linked<N>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))
            )
        )
    }

    @inlinable
    public init(reservingCapacity capacity: Int)
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >,
        Element: Copyable
    {
        precondition(capacity > 0, "capacity must be positive")
        self.init(
            _buffer: Buffer<S>.Linked<N>(
                minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))
            )
        )
    }
}

extension __ListLinked.Bounded where S: ~Copyable, Element: ~Copyable {

    @inlinable
    public init(capacity: Index_Primitives.Index<Element>.Count) throws(__ListLinked.Bounded.Error)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        guard capacity > .zero else { throw .invalidCapacity }
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: capacity), capacity: capacity)
    }

    @inlinable
    public init(capacity: Index_Primitives.Index<Element>.Count) throws(__ListLinked.Bounded.Error)
    where
        S == Ownership.Shared<
            Node<Element, N>,
            Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>
        >,
        Element: Copyable
    {
        guard capacity > .zero else { throw .invalidCapacity }
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: capacity), capacity: capacity)
    }
}
