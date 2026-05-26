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

import Testing

@testable import List_Linked_Primitives

// MARK: - Test Suite Structure

@Suite("List.Linked.Builder")
struct ListLinkedBuilderTests {
    @Suite struct Unit {}
    @Suite struct EdgeCase {}
    @Suite struct Integration {}
    @Suite struct NonCopyable {}
    @Suite struct StaticMethods {}
    @Suite struct SinglyLinked {}
    @Suite struct DoublyLinked {}
}

// MARK: - Move-Only Test Fixture

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

// MARK: - Iteration Helpers (drain via popFirst)

extension ListLinkedBuilderTests {
    fileprivate static func collected<let N: Int>(
        _ list: consuming List<Int>.Linked<N>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let elem = rest.popFirst() {
            result.append(elem)
        }
        return result
    }

    fileprivate static func collected<let N: Int>(
        _ list: consuming List<Move>.Linked<N>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let elem = rest.popFirst() {
            result.append(elem.value)
        }
        return result
    }
}

// MARK: - Unit (Doubly-Linked)

extension ListLinkedBuilderTests.Unit {

    @Test
    func `Single element expression`() {
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> { 42 }
        #expect(ListLinkedBuilderTests.collected(list) == [42])
    }

    @Test
    func `Multiple element expressions in declaration order`() {
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            2
            3
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Optional element - some`() {
        let value: Int? = 42
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> { value }
        #expect(ListLinkedBuilderTests.collected(list) == [42])
    }

    @Test
    func `Optional element - none`() {
        let value: Int? = nil
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> { value }
        let isEmpty = list.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `Mixed elements and optionals`() {
        let some: Int? = 2
        let none: Int? = nil
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            some
            none
            3
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Empty block`() {
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {}
        let isEmpty = list.isEmpty
        #expect(isEmpty)
    }
}

// MARK: - Control Flow

extension ListLinkedBuilderTests.Unit {

    @Test
    func `Conditional include`() {
        let include = true
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            if include {
                2
            }
            3
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Conditional exclude`() {
        let include = false
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            if include {
                2
            }
            3
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 3])
    }

    @Test
    func `If-else first branch`() {
        let condition = true
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            if condition {
                1
            } else {
                2
            }
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1])
    }

    @Test
    func `If-else second branch`() {
        let condition = false
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            if condition {
                1
            } else {
                2
            }
        }
        #expect(ListLinkedBuilderTests.collected(list) == [2])
    }
}

// MARK: - Edge Cases

extension ListLinkedBuilderTests.EdgeCase {

    @Test
    func `Deeply nested conditionals`() {
        let a = true
        let b = false
        let c = true
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            0
            if a {
                1
                if b {
                    2
                } else {
                    3
                    if c {
                        4
                    }
                }
            }
            99
        }
        #expect(ListLinkedBuilderTests.collected(list) == [0, 1, 3, 4, 99])
    }

    @Test
    func `Many elements preserve declaration order`() {
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            2
            3
            4
            5
            6
            7
            8
            9
            10
        }
        #expect(ListLinkedBuilderTests.collected(list) == Swift.Array(1...10))
    }
}

// MARK: - SinglyLinked (Linked<1>)

extension ListLinkedBuilderTests.SinglyLinked {

    @Test
    func `Singly-linked builder constructs in declaration order`() {
        let list: List<Int>.Linked<1> = List<Int>.Linked<1> {
            1
            2
            3
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Singly-linked empty builder`() {
        let list: List<Int>.Linked<1> = List<Int>.Linked<1> {}
        let isEmpty = list.isEmpty
        #expect(isEmpty)
    }
}

// MARK: - DoublyLinked (Linked<2>)

extension ListLinkedBuilderTests.DoublyLinked {

    @Test
    func `Doubly-linked builder constructs in declaration order`() {
        let list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            10
            20
            30
        }
        #expect(ListLinkedBuilderTests.collected(list) == [10, 20, 30])
    }

    @Test
    func `Doubly-linked popLast after builder`() {
        var list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            2
            3
        }
        let last = list.popLast()
        #expect(last == 3)
    }
}

// MARK: - Integration

extension ListLinkedBuilderTests.Integration {

    @Test
    func `Builder result is mutable - append continues sequence`() {
        var list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            1
            2
            3
        }
        list.append(4)
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3, 4])
    }

    @Test
    func `Builder result accepts prepend after construction`() {
        var list: List<Int>.Linked<2> = List<Int>.Linked<2> {
            2
            3
        }
        list.prepend(1)
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }
}

// MARK: - NonCopyable

extension ListLinkedBuilderTests.NonCopyable {

    @Test
    func `Builder with single noncopyable element`() {
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {
            Move(42)
        }
        #expect(ListLinkedBuilderTests.collected(list) == [42])
    }

    @Test
    func `Builder with multiple noncopyable elements`() {
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Builder with conditional noncopyable element - included`() {
        let include = true
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {
            Move(1)
            if include {
                Move(2)
            }
            Move(3)
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 2, 3])
    }

    @Test
    func `Builder with conditional noncopyable element - excluded`() {
        let include = false
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {
            Move(1)
            if include {
                Move(2)
            }
            Move(3)
        }
        #expect(ListLinkedBuilderTests.collected(list) == [1, 3])
    }

    @Test
    func `Builder with if-else noncopyable`() {
        let condition = true
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {
            if condition {
                Move(10)
            } else {
                Move(20)
            }
        }
        #expect(ListLinkedBuilderTests.collected(list) == [10])
    }

    @Test
    func `Empty noncopyable builder`() {
        let list: List<Move>.Linked<2> = List<Move>.Linked<2> {}
        let isEmpty = list.isEmpty
        #expect(isEmpty)
    }
}

// MARK: - Static Method Tests

extension ListLinkedBuilderTests.StaticMethods {

    @Test
    func `buildExpression single element`() {
        let result = List<Int>.Linked<2>.Builder.buildExpression(42)
        #expect(ListLinkedBuilderTests.collected(result) == [42])
    }

    @Test
    func `buildExpression existing list`() {
        let input: List<Int>.Linked<2> = List<Int>.Linked<2> { 1; 2; 3 }
        let result = List<Int>.Linked<2>.Builder.buildExpression(input)
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2, 3])
    }

    @Test
    func `buildExpression optional - some`() {
        let value: Int? = 42
        let result = List<Int>.Linked<2>.Builder.buildExpression(value)
        #expect(ListLinkedBuilderTests.collected(result) == [42])
    }

    @Test
    func `buildExpression optional - none`() {
        let value: Int? = nil
        let result = List<Int>.Linked<2>.Builder.buildExpression(value)
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildPartialBlock first`() {
        let first: List<Int>.Linked<2> = List<Int>.Linked<2> { 1; 2; 3 }
        let result = List<Int>.Linked<2>.Builder.buildPartialBlock(first: first)
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2, 3])
    }

    @Test
    func `buildPartialBlock first void`() {
        let result = List<Int>.Linked<2>.Builder.buildPartialBlock(first: ())
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildPartialBlock accumulated and next preserves order`() {
        let acc: List<Int>.Linked<2> = List<Int>.Linked<2> { 1; 2 }
        let next: List<Int>.Linked<2> = List<Int>.Linked<2> { 3; 4 }
        let result = List<Int>.Linked<2>.Builder.buildPartialBlock(
            accumulated: acc,
            next: next
        )
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2, 3, 4])
    }

    @Test
    func `buildBlock empty`() {
        let result = List<Int>.Linked<2>.Builder.buildBlock()
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildOptional some`() {
        let component: List<Int>.Linked<2>? = List<Int>.Linked<2> { 1; 2 }
        let result = List<Int>.Linked<2>.Builder.buildOptional(component)
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2])
    }

    @Test
    func `buildOptional none`() {
        let component: List<Int>.Linked<2>? = nil
        let result = List<Int>.Linked<2>.Builder.buildOptional(component)
        let isEmpty = result.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `buildEither first`() {
        let first: List<Int>.Linked<2> = List<Int>.Linked<2> { 1; 2 }
        let result = List<Int>.Linked<2>.Builder.buildEither(first: first)
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2])
    }

    @Test
    func `buildEither second`() {
        let second: List<Int>.Linked<2> = List<Int>.Linked<2> { 3; 4 }
        let result = List<Int>.Linked<2>.Builder.buildEither(second: second)
        #expect(ListLinkedBuilderTests.collected(result) == [3, 4])
    }

    @Test
    func `buildLimitedAvailability passthrough`() {
        let component: List<Int>.Linked<2> = List<Int>.Linked<2> { 1; 2; 3 }
        let result = List<Int>.Linked<2>.Builder.buildLimitedAvailability(component)
        #expect(ListLinkedBuilderTests.collected(result) == [1, 2, 3])
    }
}
