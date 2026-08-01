// List.Linked.Reversed.swift
// Tag namespace for __ListLinked's borrowing `reversed` accessor.

extension __ListLinked where Element: ~Copyable, S: ~Copyable {
    /// Tag namespace for the borrowing `reversed` accessor.
    public enum Reversed {}
}
