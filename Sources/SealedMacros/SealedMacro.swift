import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SealedMacro { }

extension SealedMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw SealedMacro.Error.shouldBeEnum
        }

        let allCaseNames = enumDecl.allCaseIdentifiers.map(\.text)
        let allCaseAssociatedTypes = enumDecl.allCaseAssociatedType.map(\.description)

        guard allCaseNames.count == allCaseAssociatedTypes.count else {
            throw SealedMacro.Error.shouldAllCaseHasAssociatedType
        }

        let cases = zip(allCaseNames, allCaseAssociatedTypes)
        let declSyntax: DeclSyntax = """
        \(raw: enumDecl.accessLevel.initalizerModifier) init(from decoder: Decoder) throws {
            let typeContainer = try decoder.container(keyedBy: \(raw: enumDecl.identifier.text)TypeCodingKey.self)
            let type = try typeContainer.decode(\(raw: enumDecl.identifier.text)Type.self, forKey: .type)
            let container = try decoder.singleValueContainer()
            switch type {
            \(raw: cases.map { "case .\($0.0):\n        self = .\($0.0)(try container.decode(\($0.1).self))" }.joined(separator: "\n    "))
            }
        }
        """

        return [
            declSyntax
        ]
    }
}

extension SealedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw SealedMacro.Error.shouldBeEnum
        }
        guard let argument = node.argument?.as(TupleExprElementListSyntax.self)?.first else {
            throw SealedMacro.Error.invalidArgument
        }

        let declTypeSyntax: DeclSyntax = """
        private enum \(raw: enumDecl.identifier.text)TypeCodingKey: String, CodingKey {
            case type
        }
        """

        let allCaseNames = enumDecl.allCaseIdentifiers.map(\.text)
        let allCasesParsingKey: [String]

        guard let typeRule = TypeParseRule(rawValue: argument.expression.description) else {
            throw SealedMacro.Error.invalidArgument
        }

        switch typeRule {
        case .upperCase:
            allCasesParsingKey = allCaseNames.map { $0.uppercased() }
        case .lowerCase:
            allCasesParsingKey = allCaseNames.map { $0.lowercased() }
        case .lowerCamelCase:
            allCasesParsingKey = allCaseNames.map { $0.lowerCamelCased() }
        case .upperCamelCase:
            allCasesParsingKey = allCaseNames.map { $0.upperCamelCased() }
        case .lowerSnakeCase:
            allCasesParsingKey = allCaseNames.map { $0.lowerSnakeCased() }
        case .mixSnakeCase:
            allCasesParsingKey = allCaseNames.map { $0.mixedSnakeCased() }
        case .upperSnakeCase:
            allCasesParsingKey = allCaseNames.map { $0.upperSnakeCased() }
        case .lowerKebabCase:
            allCasesParsingKey = allCaseNames.map { $0.lowerKebabCased() }
        case .mixedKebabCase:
            allCasesParsingKey = allCaseNames.map { $0.mixedKebabCased() }
        case .upperKebabCase:
            allCasesParsingKey = allCaseNames.map { $0.upperKebabCased() }
        case .sameAsCaseName:
            allCasesParsingKey = allCaseNames.map { $0 }
        }

        let cases = zip(allCaseNames, allCasesParsingKey)
        let parseTypeSyntax: DeclSyntax = """
        private enum \(raw: enumDecl.identifier.text)Type: String, CodingKey, Codable {
            \(raw: cases.map { "case \($0.0) = \"\($0.1)\"" }.joined(separator: "\n    "))
        }
        """

        return [
            declTypeSyntax,
            parseTypeSyntax
        ]
    }
}

extension SealedMacro: ConformanceMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [("Codable", nil)]
    }
}
