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
public import List_Linked_Primitive
public import List_Primitives

// MARK: - Equatable / Hashable (front-to-back SEQUENCE walks)
//
// Element-keyed equality is a front-to-back walk of the live elements — NOT store-equality (the
// generational slot layout is non-canonical after removals). The walk materializes each side
// through the buffer's safe `forEach` and compares the snapshots. Both conformances require the
// CoW column (`S: Copyable`) — value-semantic comparison flows from the column, exactly as
// `Array<S>: Equatable where S: Equatable`; the move-only column is never `Equatable`, by design.
// The seam constraint sits on the EXTENSION (call site), never on the `List.Linked` type — see
// `List.Linked.swift` for why (cross-package type-metadata miscompile).

extension List.Linked: Equatable
where S: Copyable, Element: Equatable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Two lists are equal when their live elements match front to back.
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

extension List.Linked: Hashable
where S: Copyable, Element: Hashable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Hashes the live elements, front to back.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        var elements: [Element] = []
        _buffer.forEach { (element: borrowing Element) in elements.append(copy element) }
        hasher.combine(elements)
    }
}

extension List.Linked.Bounded: Equatable
where S: Copyable, Element: Equatable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Two bounded lists are equal when their live elements match front to back.
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

extension List.Linked.Bounded: Hashable
where S: Copyable, Element: Hashable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// Hashes the live elements, front to back.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        var elements: [Element] = []
        _buffer.forEach { (element: borrowing Element) in elements.append(copy element) }
        hasher.combine(elements)
    }
}

// MARK: - Iteration (stdlib Sequence over a snapshot; the CoW column)

extension List.Linked
where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// A forward iterator over a snapshot of the elements, head to tail.
    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}

extension List.Linked.Bounded
where Element: Copyable, S: ~Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {
    /// A forward iterator over a snapshot of the elements, head to tail.
    @inlinable
    public func makeIterator() -> [Element].Iterator { _buffer.makeIterator() }
}

extension List.Linked: Swift.Sequence
where S: Copyable, Element: Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {}

extension List.Linked.Bounded: Swift.Sequence
where S: Copyable, Element: Copyable, S: Store.Generational.`Protocol`, S.Element == Node<Element, N> {}
