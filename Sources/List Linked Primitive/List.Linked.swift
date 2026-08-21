public import Buffer_Linked_Primitive
import Index_Primitives

@_documentation(visibility: public)
@frozen
public struct __ListLinked<Element: ~Copyable, S: ~Copyable, let N: Int>: ~Copyable {

    @usableFromInline
    package var _buffer: Buffer<S>.Linked<N>

    @inlinable
    package init(_buffer: consuming Buffer<S>.Linked<N>) {
        self._buffer = _buffer
    }
}

extension __ListLinked: Copyable where S: Copyable, Element: ~Copyable {}

extension __ListLinked: @unchecked Sendable where S: Sendable, S: ~Copyable, Element: ~Copyable {}
