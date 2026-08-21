public import Buffer_Linked_Primitive
public import List_Primitives

extension List where Element: ~Copyable {

    public typealias Linked<S: ~Copyable, let N: Int> = __ListLinked<Element, S, N>

    public typealias Doubly =
        __ListLinked<
            Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>, 2
        >

    public typealias Singly =
        __ListLinked<
            Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>, 1
        >
}

extension List where Element: Copyable {

    public enum Value {}
}

extension List.Value where Element: Copyable {

    public typealias Doubly =
        __ListLinked<
            Element,
            Ownership.Shared<
                Node<Element, 2>,
                Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>
            >,
            2
        >

    public typealias Singly =
        __ListLinked<
            Element,
            Ownership.Shared<
                Node<Element, 1>,
                Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>
            >,
            1
        >
}
