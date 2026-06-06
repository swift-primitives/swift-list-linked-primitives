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
    @Suite struct BoundedWithinCapacity {}
    @Suite struct BoundedOverflow {}
    @Suite struct NonCopyable {}
}

private struct Move: ~Copyable {
    let value: Int
    init(_ value: Int) { self.value = value }
}

extension ListLinkedVariantsBuilderTests {
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
    func `Bounded noncopyable within capacity`() throws {
        let list = try List<Move>.Linked<2>.Bounded(capacity: 4) {
            Move(1)
            Move(2)
        }
        #expect(ListLinkedVariantsBuilderTests.drainMove(list) == [1, 2])
    }
}
