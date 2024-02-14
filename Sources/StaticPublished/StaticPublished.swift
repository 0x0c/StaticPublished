// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(accessor, names: named(didSet))
@attached(peer, names: arbitrary)
public macro StaticPublished() = #externalMacro(module: "StaticPublishedMacros", type: "StaticPublishedMacro")
