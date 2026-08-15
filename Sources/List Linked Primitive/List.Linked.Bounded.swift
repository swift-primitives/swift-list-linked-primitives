// List.Linked.Bounded.swift
// A fixed-capacity linked list — allocates storage upfront and throws on overflow.

public import Buffer_Linked_Primitive
public import Index_Primitives

extension __ListLinked where Element: ~Copyable, S: ~Copyable {
    /// A fixed-capacity linked list — allocates storage upfront and throws on overflow.
    ///
    /// Use when capacity is known or in contexts requiring predictable memory behavior
    /// (embedded, real-time). Shares the same storage column `S` as its enclosing carrier.
    ///
    /// - Important: This hand-written type is the ratified **W3-blocked residual** of
    ///   `adt-tower.md` §9.6 item 4: the [DS-028] capacity ALIAS (the column-preserving
    ///   `__ListLinked<S.Bounded>` form, law 2) is inexpressible while the linked discipline's
    ///   seam (`Store.Generational.`Protocol``) vends neither `Store.Direct` nor a `Bounded`
    ///   capacity-twin column (W1.5 conformed `Buffer.Linear` + `Buffer.Ring` only; linked op
    ///   generalization is wave W3, §9.1). It migrates to the capacity alias when W3 lands the
    ///   linked twin — do not extend this type in the interim.
    @frozen
    public struct Bounded: ~Copyable {
        /// The backing linked buffer over the storage column.
        @usableFromInline
        package var _buffer: Buffer<S>.Linked<N>

        /// The maximum number of elements the list can hold.
        public let capacity: Index_Primitives.Index<Element>.Count

        @inlinable
        package init(
            _buffer: consuming Buffer<S>.Linked<N>,
            capacity: Index_Primitives.Index<Element>.Count
        ) {
            self._buffer = _buffer
            self.capacity = capacity
        }
    }
}

/// `__ListLinked.Bounded` is `Copyable` exactly when its column is — the S5 chain.
extension __ListLinked.Bounded: Copyable where S: Copyable, Element: ~Copyable {}

/// Sendable via the column's own discipline.
/// `S: ~Copyable` is restated (M1/[MEM-COPY-004]) so the conformance reaches the move-only column.
extension __ListLinked.Bounded: @unchecked Sendable
where S: Sendable, S: ~Copyable, Element: ~Copyable {}
