import Foundation
import SwiftSyntax

extension EnumDeclSyntax {

    var allCases: [EnumCaseDeclSyntax] {
        self.memberBlock.members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
    }

    var allCaseElements: [EnumCaseElementSyntax] {
        self.allCases.flatMap { $0.elements }
    }

    var allCaseIdentifiers: [TokenSyntax] {
        allCaseElements.map(\.identifier)
    }

    var allCaseAssociatedType: [TypeSyntax] {
        allCaseElements.compactMap(\.associatedValue?.type)
    }

    var accessLevel: AccessLevel {
        modifiers?.lazy.compactMap({ AccessLevel(rawValue: $0.name.text) }).first ?? .internal
    }

}

extension EnumCaseParameterClauseSyntax {
    var type: TypeSyntax? {
        self.parameterList.compactMap { $0.as(EnumCaseParameterSyntax.self) }.first?.type
    }
}
