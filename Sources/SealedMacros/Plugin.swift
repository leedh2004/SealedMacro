import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SealedPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SealedMacro.self
    ]
}
