// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

extension ReduceDispatcherMacro: PeerMacro {
    private enum Visibility: String {
        case `private`, `fileprivate`, `internal`
    }
    
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
        
        let visibility = protocolVisibility(for: declaration)
        let visibilityString = visibility == .internal ? "" : "\(visibility.rawValue) "
        return [protocolDeclaration(name: name, visibility: visibilityString, functions: functions)]
    }
    
    private static func extractFunctionSignature(from enumMember: MemberBlockItemListSyntax.Element) throws -> String? {
        guard let enumCase = enumMember.decl.as(EnumCaseDeclSyntax.self)?.elements.first else { return nil }
        
        var parameters = try enumCase.parameterClause?.parameters.enumerated().compactMap { index, enumCaseParameter in
            try extractParameter(from: enumCaseParameter, at: index)
        } ?? []
        parameters.append("state: inout State")
        
        let functionName = enumCase.name.text
        return "func \(functionName)(\(parameters.joined(separator: ", "))) -> Effect<Action>"
    }
    
    private static func extractParameter(
        from enumCaseParameter: EnumCaseParameterListSyntax.Element,
        at indexInParent: Int
    ) throws -> String {
        let parameterName = MacroUtilities.extractName(from: enumCaseParameter, at: indexInParent)
        let parameterPrefix = enumCaseParameter.firstName == nil || enumCaseParameter.secondName != nil ? "_ " : ""
        
        return "\(parameterPrefix)\(parameterName): \(enumCaseParameter.type.trimmedDescription)"
    }
    
    private static func protocolDeclaration(name: String, visibility: String, functions: [String]) -> DeclSyntax {
        """
        \(raw: visibility)protocol \(raw: name)ActionDelegate {
            typealias State = \(raw: name).State
            typealias Action = \(raw: name).Action

            \(raw: functions.joined(separator: "\n"))
        }
        """
    }
    
    private static func protocolVisibility(for declaration: StructDeclSyntax) -> Visibility {
        for modifier in declaration.modifiers {
            if modifier.name.trimmedDescription == "private" {
                return .private
            } else if modifier.name.trimmedDescription == "fileprivate" {
                return .fileprivate
            } else if modifier.name.trimmedDescription == "internal" {
                return .internal
            }
        }
        return .internal
    }
}
