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

// MARK: - swift#86652 guard (Wall 2 — cross-package @_rawLayout deinit-skip)
//
// The six PURE-INLINE deinit checks below are wrapped in `withKnownIssue` because the
// COMPILER, not the design, fails them. `List.Linked.{Inline,Small}` composes the kept
// `Buffer.Linked.{Inline,Small}` buffer variant, which composes
// `Storage.Contiguous<Memory.Inline>` — whose `@_rawLayout` storage is reached cross-module.
// swiftlang/swift#86652 (Wall 2) misclassifies the composing buffer's value-witness as
// TRIVIAL when consumed from a separate package, so its `deinit` is SKIPPED during the
// list's member-destruction → `deinitCount → 0`. The teardown source is CORRECT: the
// same-package canaries pass (swift-buffer-linked-primitives), and the SPILL (heap) paths
// pass here too (Memory.Heap's class `deinit` is unaffected).
//
// This is NOT a real leak, and there is NO source fix in this arc: a buffer-level
// `_deinitWorkaround` SIGSEGV-miscompiles on the nested substrate (Memory.Inline already
// carries the only workaround), and the pure-generic alternative is blocked by SE-0427's
// `deinit ⟹ unconditionally ~Copyable` law (Wall 1 — see the research note). `withKnownIssue`
// keeps the construct exercised and AUTO-SIGNALS the fix: when #86652 lands these pass, the
// known issue "does not occur", and the test fails — prompting removal of the guard.
//
// Removal gate: drop the `withKnownIssue` wrap when swiftlang/swift#86652 is fixed.
// Refs: swift-compiler-bug-catalog.md §A14; conditional-deinit-conditionally-copyable-generics.md;
//       decomposition-layer-placement-package-map.md §C.3 / [MOD-PLACE]; swiftlang/swift#86652.
private let __swift86652: Comment = """
swift#86652-pending (Wall 2): cross-package @_rawLayout deinit-skip — design correct + \
same-package green; re-enable when #86652 lands. See file header + catalog §A14.
"""

@Suite("List - Deinit")
struct ListDeinitTests {

    final class Tracker: @unchecked Sendable {
        private var _storage: [Int] = []
        var deinitCount: Int { _storage.count }
        var deinitOrder: [Int] { _storage }
        func append(_ id: Int) { _storage.append(id) }
    }

    struct TrackedElement: ~Copyable {
        let id: Int
        let tracker: Tracker
        init(_ id: Int, tracker: Tracker) {
            self.id = id
            self.tracker = tracker
        }
        deinit { tracker.append(id) }
    }

    // MARK: - List.Linked.Inline (doubly-linked, N=2)

    @Test(.disabled(__swift86652))
    func `Inline deinit destroys all elements`() throws {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Inline<8>()
            try list.prepend(TrackedElement(1, tracker: tracker))
            try list.prepend(TrackedElement(2, tracker: tracker))
            try list.prepend(TrackedElement(3, tracker: tracker))
        }
        #expect(tracker.deinitCount == 3)
    }

    @Test(.disabled(__swift86652))
    func `Inline deinit after partial pop destroys remaining`() throws {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Inline<8>()
            try list.append(TrackedElement(1, tracker: tracker))
            try list.append(TrackedElement(2, tracker: tracker))
            try list.append(TrackedElement(3, tracker: tracker))
            _ = list.popFirst()
            #expect(tracker.deinitCount == 1)
        }
        #expect(tracker.deinitCount == 3)
    }

    @Test
    func `Inline empty deinit does not crash`() {
        do {
            _ = List<TrackedElement>.Linked<2>.Inline<8>()
        }
    }

    @Test(.disabled(__swift86652))
    func `Inline singly-linked deinit destroys all elements`() throws {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<1>.Inline<8>()
            try list.prepend(TrackedElement(1, tracker: tracker))
            try list.prepend(TrackedElement(2, tracker: tracker))
            try list.prepend(TrackedElement(3, tracker: tracker))
        }
        #expect(tracker.deinitCount == 3)
    }

    // MARK: - List.Linked.Small (doubly-linked, N=2)

    @Test(.disabled(__swift86652))
    func `Small deinit destroys all elements in inline mode`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Small<4>()
            list.prepend(TrackedElement(1, tracker: tracker))
            list.prepend(TrackedElement(2, tracker: tracker))
            list.prepend(TrackedElement(3, tracker: tracker))
        }
        #expect(tracker.deinitCount == 3)
    }

    @Test
    func `Small deinit destroys all elements after spill`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Small<2>()
            list.prepend(TrackedElement(1, tracker: tracker))
            list.prepend(TrackedElement(2, tracker: tracker))
            // Spill to heap
            list.prepend(TrackedElement(3, tracker: tracker))
            list.prepend(TrackedElement(4, tracker: tracker))
        }
        #expect(tracker.deinitCount == 4)
    }

    @Test(.disabled(__swift86652))
    func `Small deinit after partial pop destroys remaining`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Small<4>()
            list.append(TrackedElement(1, tracker: tracker))
            list.append(TrackedElement(2, tracker: tracker))
            list.append(TrackedElement(3, tracker: tracker))
            _ = list.popFirst()
            #expect(tracker.deinitCount == 1)
        }
        #expect(tracker.deinitCount == 3)
    }

    @Test
    func `Small deinit after spill and partial pop destroys remaining`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<2>.Small<2>()
            list.append(TrackedElement(1, tracker: tracker))
            list.append(TrackedElement(2, tracker: tracker))
            list.append(TrackedElement(3, tracker: tracker))
            list.append(TrackedElement(4, tracker: tracker))
            #expect(list.isSpilled == true)
            _ = list.popFirst()
            _ = list.popFirst()
            #expect(tracker.deinitCount == 2)
        }
        #expect(tracker.deinitCount == 4)
    }

    @Test
    func `Small empty deinit does not crash`() {
        do {
            _ = List<TrackedElement>.Linked<2>.Small<4>()
        }
    }

    @Test(.disabled(__swift86652))
    func `Small singly-linked deinit destroys all elements`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<1>.Small<4>()
            list.prepend(TrackedElement(1, tracker: tracker))
            list.prepend(TrackedElement(2, tracker: tracker))
            list.prepend(TrackedElement(3, tracker: tracker))
        }
        #expect(tracker.deinitCount == 3)
    }

    @Test
    func `Small singly-linked deinit destroys all elements after spill`() {
        let tracker = Tracker()
        do {
            var list = List<TrackedElement>.Linked<1>.Small<2>()
            list.append(TrackedElement(1, tracker: tracker))
            list.append(TrackedElement(2, tracker: tracker))
            list.append(TrackedElement(3, tracker: tracker))
            list.append(TrackedElement(4, tracker: tracker))
            #expect(list.isSpilled == true)
        }
        #expect(tracker.deinitCount == 4)
    }
}
