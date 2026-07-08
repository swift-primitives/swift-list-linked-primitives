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
public import List_Primitives

// MARK: - List<E>.Linked — the canonical front-door NEST alias ([DS-028], D4.1 sense (b))

extension List where Element: ~Copyable {

    /// A linked list with `N` links per node, over an explicit storage column.
    ///
    /// This is the family's canonical **nest alias** (D4.1 sense (b), [DS-028]): it NAMES the
    /// hoisted `__ListLinked` carrier under the `List` namespace root, so consumers keep
    /// spelling `List<Element>.Linked<S, N>`. `Element` is inherited from the member it is
    /// named on ([DS-028]); the column `S` and the per-node link count `N` stay free — pin
    /// them through the column front doors below rather than spelling `S` directly.
    ///
    /// M1 restatement ([MEM-COPY-004]): the hosting extension restates `Element: ~Copyable`,
    /// and the alias's own column parameter declares its suppression (`S: ~Copyable`), so the
    /// alias is reachable from move-only elements and move-only columns alike.
    public typealias Linked<S: ~Copyable, let N: Int> = __ListLinked<Element, S, N>

    /// Doubly-linked, move-only (zero-cost default column).
    public typealias Doubly =
        __ListLinked<Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>, 2>

    /// Singly-linked, move-only (zero-cost default column).
    public typealias Singly =
        __ListLinked<Element, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>, 1>
}

// MARK: - List<E>.Value — the value-semantic (CoW) column front doors

extension List where Element: Copyable {
    /// Value-semantic (CoW) linked-list columns.
    public enum Value {}
}

extension List.Value where Element: Copyable {
    /// Doubly-linked, value-semantic (the `Shared` CoW column).
    public typealias Doubly =
        __ListLinked<
            Element,
            Ownership.Shared<Node<Element, 2>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 2>>>,
            2
        >

    /// Singly-linked, value-semantic (the `Shared` CoW column).
    public typealias Singly =
        __ListLinked<
            Element,
            Ownership.Shared<Node<Element, 1>, Storage<Memory.Allocator<Memory.Heap>.Pool>.Generational<Node<Element, 1>>>,
            1
        >
}
