# List Linked Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The linked-list discipline over the `List` namespace: node-per-element storage with O(1)
prepend and append, built over an explicit storage **column** — a zero-cost move-only column
or a copy-on-write value-semantic column — parameterized over link count (singly- or
doubly-linked) and supporting noncopyable (`~Copyable`) elements.

---

## Quick Start

```swift
import List_Linked_Primitives

// Value-semantic (copy-on-write), doubly-linked — O(1) prepend / append / pop from either end.
var list = List<Int>.Value.Doubly()
list.append(10)
list.prepend(5)
list.append(20)                 // 5 → 10 → 20

let next = list.popFirst()      // 5
let tail = list.last            // 20
print(Array(list))              // [10, 20]   (the value-semantic column is a Sequence)

// Value semantics: a copy mutates independently (copy-on-write under the hood).
var copy = list
copy.append(99)
// list == [10, 20];  copy == [10, 20, 99]
```

The zero-cost **move-only** column carries `~Copyable` elements and avoids the CoW box
entirely — reach for it when you don't need copies:

```swift
struct FileHandle: ~Copyable { /* … */ }

var handles = List<FileHandle>.Singly()   // singly-linked, move-only
handles.append(FileHandle())
handles.forEach { handle in /* borrowing access */ }
let first = handles.popFirst()            // moved out
```

The fixed-capacity `Bounded` variant pre-allocates and reports overflow instead of growing:

```swift
var window = try List<Int>.Value.Singly.Bounded(capacity: 2)
try window.append(1)
try window.append(2)
// try window.append(3)  // throws .overflow
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
        // The umbrella — types, operations, and conformances.
        .product(name: "List Linked Primitives", package: "swift-list-linked-primitives"),
        // …or depend on just the type module, without the Copyable-gated conformances:
        // .product(name: "List Linked Primitive", package: "swift-list-linked-primitives"),
    ]
)
```

Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Columns and variants

`List.Linked` is generic over its storage **column** `S` — `List<Element>.Linked<S, N>` —
mirroring `Array<S>`. Copyability flows from the column: the move-only column is `~Copyable`
(zero-cost); the `Shared` column is `Copyable` when the element is, giving copy-on-write value
semantics. Convenience typealiases hide the verbose column spelling:

| Spelling | Column | Reach for it when |
|----------|--------|-------------------|
| `List<E>.Doubly` / `List<E>.Singly` | move-only (zero-cost) | `~Copyable` elements, or you never copy the list |
| `List<E>.Value.Doubly` / `List<E>.Value.Singly` | `Shared` copy-on-write | you want value semantics: `==`, hashing, `for`-in, independent copies |
| `… .Bounded` (e.g. `List<E>.Value.Doubly.Bounded`) | fixed capacity | a hard ceiling, with overflow caught as `.overflow` |

`N = 1` is singly-linked (O(1) `popFirst`, O(n) `popLast`); `N = 2` is doubly-linked (O(1) at
both ends). All columns carry noncopyable elements; only the `Value` (CoW) columns gain
`Equatable` / `Hashable` / `Sequence`, since value semantics flow from the column.

`==` and `hash` are front-to-back **sequence walks** (the generational slot layout is
non-canonical after removals), not raw store comparison — equal sequences compare equal
regardless of physical slot order.

---

## Architecture

The package ships as two libraries plus a test-support target. The type module carries the
value types and per-column construction; the umbrella adds the column-generic operations and
the `Copyable`-gated conformances, kept separate so they never constrain noncopyable use.

| Product | Target | Purpose |
|---------|--------|---------|
| `List Linked Primitive` | `Sources/List Linked Primitive/` | The type surface: `List.Linked<S, N>`, its `Bounded` variant, per-column construction, the column typealiases, and the error type. |
| `List Linked Primitives` | `Sources/List Linked Primitives/` | The umbrella — re-exports the type module and adds the seam-generic operations plus the `Equatable`, `Hashable`, and `Sequence` conformances (value-semantic column). |
| `List Linked Primitives Test Support` | `Tests/Support/` | Re-exports the package for test consumers. |

Built on the `List` namespace and `swift-buffer-linked-primitives`' `Buffer<S>.Linked<N>`
storage substrate. Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
