# List Linked Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The **linked-list discipline** over the `List` namespace: node-per-element storage with O(1) prepend and append, in four capacity flavours — growable, bounded, inline, and small-buffer-optimized — parameterized over link count (singly- or doubly-linked) and supporting noncopyable (`~Copyable`) elements.

---

## Quick Start

```swift
import List_Linked_Primitives

// Doubly-linked, growable — O(1) prepend and append, O(1) pop from either end.
var readyQueue = List<Int>.Linked<2>()
readyQueue.append(10)
readyQueue.prepend(5)
readyQueue.append(20)
// readyQueue: 5 → 10 → 20

let next = readyQueue.popFirst()    // 5
let tail = readyQueue.last          // 20

// Reversed traversal (doubly-linked only).
readyQueue.reversed.forEach { priority in
    print(priority)                 // 20, 10
}

// Small-buffer optimization — stays inline up to the compile-time capacity,
// then spills to the heap automatically.
var recentEvents = List<Int>.Linked<2>.Small<4>()
for event in [1, 2, 3, 4] { recentEvents.append(event) }
print(recentEvents.isSpilled)       // false — still inline
recentEvents.append(5)
print(recentEvents.isSpilled)       // true — spilled to heap
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-list-linked-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        // The umbrella — the whole package.
        .product(name: "List Linked Primitives", package: "swift-list-linked-primitives"),
        // …or depend on just the type module, without conformances:
        // .product(name: "List Linked Primitive", package: "swift-list-linked-primitives"),
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3
and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux toolchain).

---

## Variants

| Type | Storage | Reach for it when |
|------|---------|-------------------|
| `List<Element>.Linked<N>` | heap, growable | the size isn't known up front |
| `List<Element>.Linked<N>.Bounded` | heap, fixed maximum | there is a hard capacity ceiling and overflow must be caught |
| `List<Element>.Linked<N>.Inline<capacity>` | inline, fixed | the maximum is small and known at compile time; zero allocation |
| `List<Element>.Linked<N>.Small<inlineCapacity>` | inline → heap | usually small, occasionally larger (SBO) |

Set `N = 1` for a singly-linked list (O(1) `popFirst`, O(n) `popLast`) or `N = 2` for a doubly-linked
list (O(1) operations at both ends). Every variant is generic over `Element`, including noncopyable
element types.

---

## Architecture

Each variant ships as **two modules**: a lean type module (`List Linked Primitive`) that carries the
value types and storage operations, and a conformances module (`List Linked Primitives`) that adds
`Sequence`, `Collection`, `Equatable`, and `Hashable` conformances — kept separate so they never
constrain noncopyable use. Importing `List Linked Primitives` (the umbrella) brings the whole
package; importing `List Linked Primitive` brings only the types and operations, without the
`Copyable`-gated conformances.

---

## Related Packages

- `swift-list-primitives` — the `List` namespace and shared list vocabulary.
- `swift-buffer-linked-primitives` — the linked storage substrate used by this package.

---

## License

Apache License 2.0. See [LICENSE](LICENSE.md) for details.
