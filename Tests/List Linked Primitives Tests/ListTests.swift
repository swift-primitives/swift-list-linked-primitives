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

import List_Linked_Primitives_Test_Support
import Testing

@testable import List_Linked_Primitives

// MARK: - CoW (value-semantic) column

@Suite
struct `List.Linked Value Tests` {

    @Test
    func `empty, append, prepend, first, last`() {
        var list = List<Int>.Value.Doubly()
        #expect(list.isEmpty)
        list.append(2)
        list.prepend(1)
        list.append(3)  // 1, 2, 3
        #expect(list.count == 3)
        #expect(list.first == 1)
        #expect(list.last == 3)
        #expect(Array(list) == [1, 2, 3])
    }

    @Test
    func `popFirst and popLast`() {
        var list = List<Int>.Value.Doubly()
        for value in [10, 20, 30] { list.append(value) }
        #expect(list.popFirst() == 10)
        #expect(list.popLast() == 30)
        #expect(Array(list) == [20])
        #expect(list.popFirst() == 20)
        #expect(list.popFirst() == Int?.none)
    }

    @Test
    func `grows past the initial capacity`() {
        var list = List<Int>.Value.Singly()
        for value in 0..<100 { list.append(value) }
        #expect(list.count == 100)
        #expect(Array(list) == Array(0..<100))
    }

    @Test
    func `copy then mutate is independent`() {
        var a = List<Int>.Value.Doubly()
        for value in [1, 2, 3] { a.append(value) }
        var b = a
        b.append(4)
        a.prepend(0)
        #expect(Array(a) == [0, 1, 2, 3])
        #expect(Array(b) == [1, 2, 3, 4])
    }

    @Test
    func `equality is a front-to-back walk`() {
        var a = List<Int>.Value.Doubly()
        var b = List<Int>.Value.Doubly()
        for value in [1, 2, 3] {
            a.append(value)
            b.append(value)
        }
        #expect(a == b)
        b.append(4)
        #expect(a != b)
        _ = b.popLast()
        #expect(a == b)
    }

    @Test
    func `hash agrees with equality`() {
        var a = List<Int>.Value.Doubly()
        var b = List<Int>.Value.Doubly()
        for value in [5, 6, 7] {
            a.append(value)
            b.append(value)
        }
        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `peek does not remove`() {
        var list = List<Int>.Value.Doubly()
        for value in [1, 2, 3] { list.append(value) }
        let front = list.peekFront { copy $0 }
        let back = list.peekBack { copy $0 }
        #expect(front == 1)
        #expect(back == 3)
        #expect(list.count == 3)
    }
}

// MARK: - Move-only column

@Suite
struct `List.Linked MoveOnly Tests` {

    private struct Token: ~Copyable {
        let id: Int
        init(_ id: Int) { self.id = id }
    }

    @Test
    func `Copyable element on the move-only column`() {
        var list = List<Int>.Doubly()
        list.append(1)
        list.prepend(0)
        #expect(list.count == 2)
        var seen: [Int] = []
        list.forEach { (e: borrowing Int) in seen.append(copy e) }
        #expect(seen == [0, 1])
        #expect(list.popFirst() == 0)
        #expect(list.popLast() == 1)
    }

    @Test
    func `~Copyable element flows through insert, peek, remove`() {
        var list = List<Token>.Singly()
        list.append(Token(7))
        list.append(Token(8))
        let frontID = list.peekFront { (t: borrowing Token) in t.id }
        #expect(frontID == 7)
        guard let taken = list.popFirst() else {
            Issue.record("expected element")
            return
        }
        #expect(taken.id == 7)
        _ = consume taken
    }
}

// MARK: - Bounded

@Suite
struct `List.Linked Bounded Tests` {

    @Test
    func `bounded overflows at capacity`() throws {
        var list = try List<Int>.Value.Doubly.Bounded(capacity: Index<Int>.Count(UInt(2)))
        try list.append(1)
        try list.append(2)
        #expect(list.isFull)
        var didOverflow = false
        do throws(__ListLinkedError) { try list.append(3) } catch { didOverflow = (error == .overflow) }
        #expect(didOverflow)
        #expect(list.count == 2)
        #expect(list.popFirst() == 1)
        try list.append(9)  // room recycled
        #expect(list.popFirst() == 2)
        #expect(list.popFirst() == 9)
    }
}
