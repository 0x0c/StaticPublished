import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


// MARK: - StaticPublishedMacro

public struct StaticPublishedMacro: PeerMacro, AccessorMacro {
    public enum ConformanceError: Error, CustomStringConvertible {
        case variableIsNotStatic
        case variableIsNotVar

        // MARK: Public

        public var description: String {
            switch self {
            case .variableIsNotStatic:
                return "@StaticPublisher can only be attached to static variable."
            case .variableIsNotVar:
                return "@StaticPublisher can not be attached to let."
            }
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed else {
            return []
        }

        guard property.modifiers.contains(where: {
            $0.name.tokenKind == .keyword(SwiftSyntax.Keyword.static)
        }) else {
            throw ConformanceError.variableIsNotStatic
        }
        guard property.bindingSpecifier.tokenKind == .keyword(SwiftSyntax.Keyword.var) else {
            throw ConformanceError.variableIsNotVar
        }

        return [
            """
            didSet {
                _\(identifier)Subject.send(\(identifier))
            }
            """
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let property = declaration.as(VariableDeclSyntax.self),
            let binding = property.bindings.first,
            let annotation = binding.typeAnnotation,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmed else {
            return []
        }
        return [
            "private static let _\(identifier)Subject = PassthroughSubject<\(annotation.type.trimmed), Never>()",
            "static let \(identifier)Publisher = _\(identifier)Subject.eraseToAnyPublisher()"
        ]
    }
}

// MARK: - StaticPublishedPlugin

@main
struct StaticPublishedPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StaticPublishedMacro.self
    ]
}
