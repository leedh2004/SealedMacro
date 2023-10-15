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
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw SealedMacro.Error.invalidArgument
        }

        let typeKey = arguments.first(where: { $0.label?.text == "typeKey" })?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.description ?? "type"

        let allCaseNames = enumDecl.allCaseIdentifiers.map(\.text)
        let allCaseAssociatedTypes = enumDecl.allCaseAssociatedType.map(\.description)

        guard allCaseNames.count == allCaseAssociatedTypes.count else {
            throw SealedMacro.Error.shouldAllCaseHasAssociatedType
        }

        let cases = zip(allCaseNames, allCaseAssociatedTypes)

        let decodeSyntax: DeclSyntax = """
        \(raw: enumDecl.accessLevel.initalizerModifier) init(from decoder: Decoder) throws {
            let typeContainer = try decoder.container(keyedBy: \(raw: enumDecl.name.text)TypeCodingKey.self)
            let type = try typeContainer.decode(\(raw: enumDecl.name.text)Type.self, forKey: .\(raw: typeKey))
            let container = try decoder.singleValueContainer()
            switch type {
            \(raw: cases.map { "case .\($0.0):\n        self = .\($0.0)(try container.decode(\($0.1).self))" }.joined(separator: "\n    "))
            }
        }
        """

        let encodeSyntax: DeclSyntax = """
            \(raw: enumDecl.accessLevel.initalizerModifier) func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                \(raw: cases.map(\.0).map { "case .\($0)(let \($0)): try container.encode(\($0))" }.joined(separator: "\n        "))
                }
                var typeContainer = encoder.container(keyedBy: \(raw: enumDecl.name.text)TypeCodingKey.self)
                switch self {
                \(raw: cases.map { "case .\($0.0): try typeContainer.encode(\(enumDecl.name.text)Type.\($0.0), forKey: .\(typeKey))" }.joined(separator: "\n        "))
                }
            }
        """

        let typeSyntaxes: [DeclSyntax] = (try? typeSyntax(of: node, providingPeersOf: declaration)) ?? []

        return [
            decodeSyntax,
            encodeSyntax
        ] + typeSyntaxes
    }

    private static func typeSyntax(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclGroupSyntax
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw SealedMacro.Error.shouldBeEnum
        }
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let typeParseRule = arguments.first(where: { $0.label?.text == "typeParseRule" }).map(\.expression.description) else {
            throw SealedMacro.Error.invalidArgument
        }
        let typeKey = arguments.first(where: { $0.label?.text == "typeKey" })?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.description ?? "type"

        let declTypeSyntax: DeclSyntax = """
        private enum \(raw: enumDecl.name.text)TypeCodingKey: String, CodingKey {
            case \(raw: typeKey)
        }
        """

        let allCaseNames = enumDecl.allCaseIdentifiers.map(\.text)
        let allCasesParsingKey: [String]

        guard let typeRule = TypeParseRule(rawValue: typeParseRule) else {
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
        private enum \(raw: enumDecl.name.text)Type: String, CodingKey, Codable {
            \(raw: cases.map { "case \($0.0) = \"\($0.1)\"" }.joined(separator: "\n    "))
        }
        """

        return [
            declTypeSyntax,
            parseTypeSyntax
        ]
    }
}
