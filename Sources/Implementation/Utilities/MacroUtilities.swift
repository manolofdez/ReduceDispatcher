// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftSyntax

struct MacroUtilities {
    static func findActionDeclaration(in members: MemberBlockItemListSyntax) -> EnumDeclSyntax? {
        members
            .lazy
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }
            .first { $0.name.text == "Action" }
    }
    
    static func extractName(
        from enumCaseParameter: EnumCaseParameterListSyntax.Element,
        at indexInParent: Int
    ) -> String {
        enumCaseParameter.secondName?.text ?? enumCaseParameter.firstName?.text ?? "value\(indexInParent)"
    }
    
    static func conformsToReducer(declaration: StructDeclSyntax) -> Bool {
        declaration.inheritanceClause?.inheritedTypes.contains { $0.type.trimmedDescription == "Reducer" } == true
            || declaration.attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "Reducer" } == true
    }
}
