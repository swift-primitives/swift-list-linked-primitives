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

@Suite("List.Linked variants + Builder")
struct ListLinkedVariantsBuilderTests {
    @Suite struct InlineWithinCapacity {}
    @Suite struct InlineOverflow {}
    @Suite struct SmallSpill {}
    @Suite struct BoundedWithinCapacity {}
    @Suite struct BoundedOverflow {}
    @Suite struct NonCopyable {}
}

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

extension ListLinkedVariantsBuilderTests {
    fileprivate static func drain<let N: Int, let C: Int>(
        _ list: consuming List<Int>.Linked<N>.Inline<C>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e)
        }
        return result
    }

    fileprivate static func drain<let N: Int, let C: Int>(
        _ list: consuming List<Int>.Linked<N>.Small<C>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e)
        }
        return result
    }

    fileprivate static func drain<let N: Int>(
        _ list: consuming List<Int>.Linked<N>.Bounded
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e)
        }
        return result
    }

    fileprivate static func drainMove<let N: Int, let C: Int>(
        _ list: consuming List<Move>.Linked<N>.Inline<C>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e.value)
        }
        return result
    }

    fileprivate static func drainMove<let N: Int, let C: Int>(
        _ list: consuming List<Move>.Linked<N>.Small<C>
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e.value)
        }
        return result
    }

    fileprivate static func drainMove<let N: Int>(
        _ list: consuming List<Move>.Linked<N>.Bounded
    ) -> [Int] {
        var rest = consume list
        var result: [Int] = []
        while let e = rest.popFirst() {
            result.append(e.value)
        }
        return result
    }
}

extension ListLinkedVariantsBuilderTests.InlineWithinCapacity {

    @Test
    func `Inline doubly-linked within capacity`() throws {
        let list = try List<Int>.Linked<2>.Inline<8> {
            1
            2
            3
        }
        #expect(ListLinkedVariantsBuilderTests.drain(list) == [1, 2, 3])
    }

    @Test
    func `Inline singly-linked within capacity`() throws {
        let list = try List<Int>.Linked<1>.Inline<8> {
            10
            20
        }
        #expect(ListLinkedVariantsBuilderTests.drain(list) == [10, 20])
    }
}

extension ListLinkedVariantsBuilderTests.InlineOverflow {

    @Test
    func `Inline throws on overflow`() {
        do {
            _ = try List<Int>.Linked<2>.Inline<2> {
                1
                2
                3
            }
            Issue.record("expected throw")
        } catch {
            // expected
        }
    }
}

extension ListLinkedVariantsBuilderTests.SmallSpill {

    @Test
    func `Small spills to heap on overflow`() {
        let list = List<Int>.Linked<2>.Small<2> {
            1
            2
            3
            4
            5
        }
        #expect(ListLinkedVariantsBuilderTests.drain(list) == [1, 2, 3, 4, 5])
    }

    @Test
    func `Small within inline capacity`() {
        let list = List<Int>.Linked<2>.Small<8> {
            1
            2
        }
        #expect(ListLinkedVariantsBuilderTests.drain(list) == [1, 2])
    }
}

extension ListLinkedVariantsBuilderTests.BoundedWithinCapacity {

    @Test
    func `Bounded within capacity`() throws {
        let list = try List<Int>.Linked<2>.Bounded(capacity: 8) {
            1
            2
            3
        }
        #expect(ListLinkedVariantsBuilderTests.drain(list) == [1, 2, 3])
    }
}

extension ListLinkedVariantsBuilderTests.BoundedOverflow {

    @Test
    func `Bounded throws on overflow`() {
        do {
            _ = try List<Int>.Linked<2>.Bounded(capacity: 2) {
                1
                2
                3
            }
            Issue.record("expected throw")
        } catch {
            // expected
        }
    }
}

extension ListLinkedVariantsBuilderTests.NonCopyable {

    @Test
    func `Inline noncopyable within capacity`() throws {
        let list = try List<Move>.Linked<2>.Inline<4> {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(ListLinkedVariantsBuilderTests.drainMove(list) == [1, 2, 3])
    }

    @Test
    func `Small noncopyable spills`() {
        let list = List<Move>.Linked<2>.Small<2> {
            Move(1)
            Move(2)
            Move(3)
        }
        #expect(ListLinkedVariantsBuilderTests.drainMove(list) == [1, 2, 3])
    }

    @Test
    func `Bounded noncopyable within capacity`() throws {
        let list = try List<Move>.Linked<2>.Bounded(capacity: 4) {
            Move(1)
            Move(2)
        }
        #expect(ListLinkedVariantsBuilderTests.drainMove(list) == [1, 2])
    }
}
