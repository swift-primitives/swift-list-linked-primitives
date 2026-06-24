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

public import List_Primitives
public import Memory_Heap_Primitives
public import Storage_Contiguous_Primitives
public import Index_Primitives
public import Buffer_Linked_Primitive
internal import Buffer_Linked_Primitives

extension List where Element: ~Copyable {

    /// A linked list with N links per node.
    ///
    /// `Linked<N>` is the canonical linked list type where N specifies the number
    /// of links per node:
    ///
    /// - `Linked<1>`: Singly-linked (forward link only)
    /// - `Linked<2>`: Doubly-linked (forward + backward links)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Singly-linked list (with tail pointer)
    /// var singly = List<Int>.Linked<1>()
    /// singly.prepend(1)     // O(1)
    /// singly.append(2)      // O(1) - uses tail pointer
    /// singly.popFirst()     // O(1)
    /// singly.popLast()      // O(n) - must traverse to find prev
    ///
    /// // Doubly-linked list
    /// var doubly = List<Int>.Linked<2>()
    /// doubly.prepend(1)     // O(1)
    /// doubly.append(2)      // O(1)
    /// doubly.popFirst()     // O(1)
    /// doubly.popLast()      // O(1)
    /// ```
    ///
    /// ## Variants
    ///
    /// - ``Linked``: Dynamically-growing with amortized O(1) operations (this type)
    /// - ``Linked/Bounded``: Fixed-capacity, throws on overflow
    ///
    /// ## Arena-Based Storage
    ///
    /// Uses arena-based storage where all nodes are stored contiguously. Nodes
    /// reference each other by index rather than pointer, improving cache locality.
    ///
    /// ## Move-Only Support
    ///
    /// Both the list and its elements can be `~Copyable`:
    ///
    /// ```swift
    /// struct FileHandle: ~Copyable { ... }
    /// var handles = List<FileHandle>.Linked<2>()
    /// handles.prepend(FileHandle())
    /// ```
    ///
    /// ## Copy-on-Write
    ///
    /// When `Element` is `Copyable`, `Linked` uses copy-on-write semantics:
    /// copies share storage until mutation.
    // WHY: Category D — structural Sendable workaround; the type is
    // WHY: structurally value-safe but the compiler cannot synthesize
    // WHY: Sendable due to a stored pointer / generic parameter shape.
    @safe
    public struct Linked<let N: Int>: ~Copyable {

        @usableFromInline
        package var _buffer: Buffer<Storage<Element>.Contiguous<Memory.Heap<Element>>>.Linked<N>

        // Tag enums for Property.Borrow accessors [PATTERN-022]
        public enum Peek {}
        public enum Reversed {}

        // MARK: - Variants (declared here for ~Copyable propagation)

        /// A fixed-capacity linked list.
        ///
        /// `Linked.Bounded` allocates storage upfront and throws on overflow.
        /// Use this variant when capacity is known or in contexts requiring
        /// predictable memory behavior (embedded, real-time).
        ///
        /// ## Example
        ///
        /// ```swift
        /// var list = try List<Int>.Linked<2>.Bounded(capacity: 10)
        /// try list.prepend(1)
        /// try list.append(2)
        /// list.popFirst()  // Optional(1)
        /// ```
        // WHY: Category D — structural Sendable workaround; the type is
        // WHY: structurally value-safe but the compiler cannot synthesize
        // WHY: Sendable due to a stored pointer / generic parameter shape.
        @safe
        public struct Bounded: ~Copyable {
            @usableFromInline
            package var _buffer: Buffer<Storage<Element>.Contiguous<Memory.Heap<Element>>>.Linked<N>

            // Tag enums for Property.Borrow accessors [PATTERN-022]
            public enum Peek {}
            public enum Reversed {}

            /// The maximum number of elements the list can hold.
            public let capacity: Index_Primitives.Index<Element>.Count

            /// Creates a list with the specified capacity.
            ///
            /// - Parameter capacity: Maximum number of elements. Must be non-negative.
            /// - Throws: ``Bounded/Error/invalidCapacity`` if capacity is negative.
            @inlinable
            public init(capacity: Index_Primitives.Index<Element>.Count) throws(__ListLinkedBoundedError) {
                guard capacity > .zero else {
                    throw .invalidCapacity
                }
                self._buffer = try! .create(capacity: capacity.retag())
                self.capacity = capacity
            }
        }

        // MARK: - Init

        /// Creates an empty linked list.
        ///
        /// Allocates an initial pool with capacity 4.
        @inlinable
        public init() {
            precondition(N >= 1 && N <= 2, "Linked<N> requires N in 1...2")
            self._buffer = try! .create(capacity: 4)
        }

        /// Creates a list with reserved capacity.
        ///
        /// Pre-allocates storage for the specified number of elements.
        ///
        /// - Parameter capacity: Number of elements to reserve space for. Must be positive.
        /// - Throws: ``Linked/Error/invalidCapacity`` if capacity is not positive.
        @inlinable
        public init(reservingCapacity capacity: Int) throws(List<Element>.Linked<N>.Error) {
            precondition(N >= 1 && N <= 2, "Linked<N> requires N in 1...2")
            guard capacity > 0 else {
                throw .invalidCapacity
            }
            self._buffer = try! .create(capacity: capacity)
        }
    }
}

// MARK: - Conditional Copyable

/// `List.Linked` is `Copyable` when its elements are `Copyable`.
extension List.Linked: Copyable where Element: Copyable {}

/// `List.Linked.Bounded` is `Copyable` when its elements are `Copyable`.
extension List.Linked.Bounded: Copyable where Element: Copyable {}

// MARK: - Sendable

/// Sendable conformance for `List.Linked`.
///
/// ## Safety Invariant
///
/// `List.Linked<N>` is `~Copyable` (conditionally `Copyable` when
/// `Element: Copyable` via COW). Under the `~Copyable` path the list is
/// a single owner; under COW the backing arena storage handles its own
/// aliasing via reference counting. Sending across isolation boundaries
/// is sound because either ownership is unique (moved) or the COW backing
/// preserves value semantics.
///
/// ## Intended Use
///
/// - Transferring a prepared linked list to a worker thread.
/// - Handing off a linked list of `~Copyable` resources across actors.
/// - Pipeline stages where each stage owns the list in turn.
///
/// ## Non-Goals
///
/// - Does not synchronize mutation — single-owner semantics are required.
/// - Does not provide lock-free list operations.
/// - Not suitable as a shared concurrent queue.
extension List.Linked: @unsafe @unchecked Sendable where Element: Sendable {}

/// Sendable conformance for `List.Linked.Bounded`.
///
/// ## Safety Invariant
///
/// `List.Linked.Bounded` is `~Copyable` (conditionally `Copyable` when
/// `Element: Copyable`). The fixed capacity is pre-allocated; transfer
/// across threads moves the full buffer under unique ownership.
///
/// ## Intended Use
///
/// - Transferring a bounded linked list to a consumer with predictable
///   memory behavior.
/// - Handing off bounded resource queues between phases of a pipeline.
///
/// ## Non-Goals
///
/// - Not a concurrent bounded queue; external synchronization required.
extension List.Linked.Bounded: @unsafe @unchecked Sendable where Element: Sendable {}
