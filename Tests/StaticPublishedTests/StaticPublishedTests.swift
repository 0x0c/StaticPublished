import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(StaticPublishedMacros)
import StaticPublishedMacros

let testMacros: [String: Macro.Type] = [
    "StaticPublisher": StaticPublishedMacro.self,
]
#endif

final class StaticPublisherTests: XCTestCase {
    func testMacro() throws {
        #if canImport(StaticPublishedMacros)
        assertMacroExpansion(
            """
            @StaticPublished
            static var input: Int = 0
            """, expandedSource:
            """

            static var input: Int = 0 {
                didSet {
                    _inputSubject.send(input)
                }
            }

            private static let _inputSubject = PassthroughSubject<Int, Never>()

            static let inputPublisher = _inputSubject.eraseToAnyPublisher()
            """, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
