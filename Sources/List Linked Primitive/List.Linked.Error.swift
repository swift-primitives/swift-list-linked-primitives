@_documentation(visibility: public)
public enum __ListLinkedError: Swift.Error, Sendable, Equatable {

    case invalidCapacity

    case overflow
}

extension __ListLinked where Element: ~Copyable, S: ~Copyable {

    public typealias Error = __ListLinkedError
}

extension __ListLinked.Bounded where Element: ~Copyable, S: ~Copyable {

    public typealias Error = __ListLinkedError
}
