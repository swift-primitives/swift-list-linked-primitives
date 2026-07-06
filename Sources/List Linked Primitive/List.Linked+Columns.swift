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

// MARK: - Construction (per column)
//
// Construction pins per column — the move-only generational store (any element) and the `Shared`
// CoW box over it (Copyable elements, where the box's clone strategy is captured). Each forwards to
// the corresponding `Buffer<S>.Linked<N>` constructor.

// MARK: Move-only column

extension __ListLinked where S: ~Copyable, Element: ~Copyable {
    /// Creates an empty linked list (move-only column), reserving capacity for 4 nodes.
    @inlinable
    public init() where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))))
    }

    /// Creates an empty linked list reserving capacity for `capacity` nodes (move-only column).
    @inlinable
    public init(reservingCapacity capacity: Int)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        precondition(capacity > 0, "capacity must be positive")
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))))
    }
}

// MARK: CoW (Shared) column

extension __ListLinked where S: ~Copyable, Element: ~Copyable {
    /// Creates an empty value-semantic linked list (CoW column), reserving capacity for 4 nodes.
    @inlinable
    public init()
    where
        S == Ownership.Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>>,
        Element: Copyable
    {
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(4))))
    }

    /// Creates an empty value-semantic linked list reserving capacity for `capacity` nodes.
    @inlinable
    public init(reservingCapacity capacity: Int)
    where
        S == Ownership.Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>>,
        Element: Copyable
    {
        precondition(capacity > 0, "capacity must be positive")
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: Index_Primitives.Index<Element>.Count(UInt(capacity))))
    }
}

// MARK: - Bounded construction (per column)

extension __ListLinked.Bounded where S: ~Copyable, Element: ~Copyable {
    /// Creates a fixed-capacity linked list (move-only column).
    @inlinable
    public init(capacity: Index_Primitives.Index<Element>.Count) throws(__ListLinkedError)
    where S == Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>> {
        guard capacity > .zero else { throw .invalidCapacity }
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: capacity), capacity: capacity)
    }

    /// Creates a fixed-capacity value-semantic linked list (CoW column).
    @inlinable
    public init(capacity: Index_Primitives.Index<Element>.Count) throws(__ListLinkedError)
    where
        S == Ownership.Shared<Node<Element, N>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, N>>>,
        Element: Copyable
    {
        guard capacity > .zero else { throw .invalidCapacity }
        self.init(_buffer: Buffer<S>.Linked<N>(minimumCapacity: capacity), capacity: capacity)
    }
}
