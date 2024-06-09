// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

extension ReduceDispatcherMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(error: .invalidRootNodeType, in: node)
            return []
        }
        
        let name = declaration.name.text
        
        guard MacroUtilities.conformsToReducer(declaration: declaration) else {
            context.diagnose(error: .reducerConformanceNotFound, in: declaration.name)
            return []
        }
        
        guard let members = declaration.memberBlock.members.as(MemberBlockItemListSyntax.self) else { return [] }
        
        guard let actionDeclaration = MacroUtilities.findActionDeclaration(in: members) else {
            let actionNode = members.first {
                $0.trimmedDescription.contains(" Action ")
            }?.as(Syntax.self)
            context.diagnose(error: .nestedActionRequired, in: actionNode ?? Syntax(node))
            return []
        }
        
        let functions: [String]
        do {
            functions = try actionDeclaration.memberBlock.members.compactMap { try extractFunctionSignature(from: $0) }
        } catch {
            context.diagnose(error: error, in: actionDeclaration.memberBlock)
            return []
        }
        
        return [protocolDeclaration(name: name, functions: functions)]
    }
    
    private static func extractFunctionSignature(from enumMember: MemberBlockItemListSyntax.Element) throws -> String? {
        guard let enumCase = enumMember.decl.as(EnumCaseDeclSyntax.self)?.elements.first else { return nil }
        
        var parameters = try enumCase.parameterClause?.parameters.compactMap { enumCaseParameter in
            try extractParameter(from: enumCaseParameter)
        } ?? []
        parameters.append("into state: inout State")
        
        let functionName = "reduce\(enumCase.name.text.uppercasingFirst())"
        return "func \(functionName)(\(parameters.joined(separator: ", "))) -> Effect<Action>"
    }
    
    private static func extractParameter(from enumCaseParameter: EnumCaseParameterListSyntax.Element) throws -> String {
        let parameterName = try MacroUtilities.extractName(from: enumCaseParameter)
        let parameterPrefix = enumCaseParameter.firstName == nil ? "_ " : ""
        
        return "\(parameterPrefix)\(parameterName): \(enumCaseParameter.type.trimmedDescription)"
    }
    
    private static func protocolDeclaration(name: String, functions: [String]) -> DeclSyntax {
        """
        protocol \(raw: name)ActionDelegate {
            typealias State = \(raw: name).State
            typealias Action = \(raw: name).Action

            \(raw: functions.joined(separator: "\n"))
        }
        """
    }
}
