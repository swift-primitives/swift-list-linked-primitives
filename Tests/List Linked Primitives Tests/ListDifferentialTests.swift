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

// MARK: - Deterministic RNG (SplitMix64 — no seeding nondeterminism in CI)

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// MARK: - Differential vs a plain-array oracle (the W2 test floor, §9.3 convention rider)

@Suite("List.Linked — differential vs array oracle")
struct ListLinkedDifferentialTests {

    /// ≥500 mixed ops against a plain-`[Int]` oracle over the move-only default column
    /// (`List<Int>.Doubly`): duplicates (values drawn from 0..<10), interleaved
    /// append/prepend/popFirst/popLast/peeks, growth across reallocations (initial node
    /// capacity is 4; insert bias grows the list well past it), step-by-step match.
    @Test
    func `600 mixed ops match a plain-array oracle (move-only doubly column)`() {
        var rng = SplitMix64(seed: 0x5EED_1157_ADC0_FFEE)
        var list = List<Int>.Doubly()
        var oracle: [Int] = []

        for step in 0..<600 {
            let op = rng.next() % 6
            let value = Int(rng.next() % 10)  // small range -> duplicates guaranteed
            switch op {
            case 0, 1:  // insert bias (3/6 insert vs 2/6 remove) -> growth across reallocations
                list.append(value)
                oracle.append(value)

            case 2:
                list.prepend(value)
                oracle.insert(value, at: 0)

            case 3:
                let got = list.popFirst()
                let want = oracle.isEmpty ? nil : oracle.removeFirst()
                #expect(got == want, "step \(step): popFirst diverged")

            case 4:
                let got = list.popLast()
                let want = oracle.isEmpty ? nil : oracle.removeLast()
                #expect(got == want, "step \(step): popLast diverged")

            default:
                let front = list.peekFront { copy $0 }
                #expect(front == oracle.first, "step \(step): peekFront diverged")
                let back = list.peekBack { copy $0 }
                #expect(back == oracle.last, "step \(step): peekBack diverged")
            }

            // Step-by-step invariants (bound to locals -- move-only #expect capture discipline).
            let count = list.count
            #expect(count == Index<Int>.Count(UInt(oracle.count)), "step \(step): count diverged")
            let empty = list.isEmpty
            #expect(empty == oracle.isEmpty, "step \(step): isEmpty diverged")
        }

        // Final full-order check, front to back.
        var snapshot: [Int] = []
        list.forEach { (element: borrowing Int) in snapshot.append(copy element) }
        #expect(snapshot == oracle)

        // And back to front (the doubly column's reverse walk).
        var reversedSnapshot: [Int] = []
        list.forEachReversed { (element: borrowing Int) in reversedSnapshot.append(copy element) }
        #expect(reversedSnapshot == Array(oracle.reversed()))
    }
}
