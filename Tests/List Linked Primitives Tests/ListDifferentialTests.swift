import List_Linked_Primitives_Test_Support
import Testing

@testable import List_Linked_Primitives

private struct SplitMix64 {
    var state: UInt64
    init(seed: UInt64) { self.state = seed }
}

extension SplitMix64 {
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@Suite
struct `List.Linked Differential Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @Test
    func `600 mixed ops match a plain-array oracle (move-only doubly column)`() {
        var rng = SplitMix64(seed: 0x5EED_1157_ADC0_FFEE)
        var list = List<Int>.Doubly()
        var oracle: [Int] = []

        (0..<600).forEach { step in
            let op = rng.next() % 6
            let value = Int(rng.next() % 10)
            switch op {
            case 0, 1:
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

            let count = list.count
            #expect(count == Index<Int>.Count(UInt(oracle.count)), "step \(step): count diverged")
            let empty = list.isEmpty
            #expect(empty == oracle.isEmpty, "step \(step): isEmpty diverged")
        }

        var snapshot: [Int] = []
        list.forEach { (element: borrowing Int) in snapshot.append(copy element) }
        #expect(snapshot == oracle)

        var reversedSnapshot: [Int] = []
        list.forEachReversed { (element: borrowing Int) in reversedSnapshot.append(copy element) }
        #expect(reversedSnapshot == Array(oracle.reversed()))
    }
}
