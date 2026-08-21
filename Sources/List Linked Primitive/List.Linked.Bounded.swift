public import Buffer_Linked_Primitive
public import Index_Primitives

extension __ListLinked where Element: ~Copyable, S: ~Copyable {

    @frozen
    public struct Bounded: ~Copyable {

        @usableFromInline
        package var _buffer: Buffer<S>.Linked<N>

        public let capacity: Index_Primitives.Index<Element>.Count

        @inlinable
        package init(
            _buffer: consuming Buffer<S>.Linked<N>,
            capacity: Index_Primitives.Index<Element>.Count
        ) {
            self._buffer = _buffer
            self.capacity = capacity
        }
    }
}

extension __ListLinked.Bounded: Copyable where S: Copyable, Element: ~Copyable {}

extension __ListLinked.Bounded: @unchecked Sendable
where S: Sendable, S: ~Copyable, Element: ~Copyable {}
