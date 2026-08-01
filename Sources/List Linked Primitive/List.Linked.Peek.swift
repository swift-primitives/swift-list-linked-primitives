// List.Linked.Peek.swift
// Tag namespace for __ListLinked's borrowing `peek` accessor.

extension __ListLinked where Element: ~Copyable, S: ~Copyable {
    /// Tag namespace for the borrowing `peek` accessor.
    public enum Peek {}
}
