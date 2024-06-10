// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftSyntax

struct MacroUtilities {
    static func findActionDeclaration(in members: MemberBlockItemListSyntax) -> EnumDeclSyntax? {
        members
            .lazy
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }
            .first { $0.name.text == "Action" }
    }
    
    
    static func extractVariableNameFromType(_ type: TypeSyntax) -> String? {
        type.as(MemberTypeSyntax.self)?.name.text
            ?? type.as(IdentifierTypeSyntax.self)?.name.text
    }
    
    static func extractName(from enumCaseParameter: EnumCaseParameterListSyntax.Element) throws -> String {
        let parameterName: String
        
        if let firstName = enumCaseParameter.firstName?.text {
            parameterName = firstName
        } else if let typeName: String = MacroUtilities.extractVariableNameFromType(enumCaseParameter.type) {
            parameterName = "\(typeName.lowercasingFirst())"
        } else {
            throw ReduceDispatcherMacro.Error.unsupportedParameter(node: Syntax(enumCaseParameter))
        }
        
        return parameterName
    }
    
    static func conformsToReducer(declaration: StructDeclSyntax) -> Bool {
        declaration.inheritanceClause?.inheritedTypes.contains { $0.type.trimmedDescription == "Reducer" } == true
            || declaration.attributes.contains { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "Reducer" } == true
    }
}
