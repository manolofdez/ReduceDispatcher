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
        
        let actionNestedTypes = extractNestedType(from: actionDeclaration.memberBlock.members)
        let functions = actionDeclaration.memberBlock.members.compactMap {
            extractFunctionSignature(from: $0, nestedTypes: actionNestedTypes)
        }
        
        let visibility = protocolVisibility(for: declaration)
        let visibilityString = visibility == .internal ? "" : "\(visibility.rawValue) "
        return [protocolDeclaration(name: name, visibility: visibilityString, functions: functions)]
    }
    
    private static func extractFunctionSignature(
        from enumMember: MemberBlockItemListSyntax.Element,
        nestedTypes: [String]
    ) -> String? {
        guard let enumCase = enumMember.decl.as(EnumCaseDeclSyntax.self)?.elements.first else { return nil }
        
        var parameters = enumCase.parameterClause?.parameters.enumerated().compactMap { index, enumCaseParameter in
            extractParameter(from: enumCaseParameter, at: index, nestedTypes: nestedTypes)
        } ?? []
        parameters.append("state: inout State")
        
        let functionName = enumCase.name.text
        return "func \(functionName)(\(parameters.joined(separator: ", "))) -> Effect<Action>"
    }
    
    private static func extractParameter(
        from enumCaseParameter: EnumCaseParameterListSyntax.Element,
        at indexInParent: Int,
        nestedTypes: [String]
    ) -> String {
        let parameterName = MacroUtilities.extractName(from: enumCaseParameter, at: indexInParent)
        let parameterPrefix = enumCaseParameter.firstName == nil || enumCaseParameter.secondName != nil ? "_ " : ""
        let parameterType = nestedTypes.contains(enumCaseParameter.type.trimmedDescription)
            ? "Action.\(enumCaseParameter.type.trimmedDescription)"
            : enumCaseParameter.type.trimmedDescription
        
        return "\(parameterPrefix)\(parameterName): \(parameterType)"
    }
    
    private static func extractNestedType(from members: MemberBlockItemListSyntax) -> [String] {
        var nestedTypes: [String] = []
        var evaluationList = [(parentType: String?.none, members: members)]
        var evaluationListIndex = 0
        
        while (evaluationListIndex < evaluationList.count) {
            let (parentType, members) = evaluationList[evaluationListIndex]
            
            members.forEach { member in
                let typeName: String
                let members: MemberBlockItemListSyntax
                
                if let declaration = member.decl.as(EnumDeclSyntax.self) {
                    typeName = declaration.name.text
                    members = declaration.memberBlock.members
                } else if let declaration = member.decl.as(StructDeclSyntax.self) {
                    typeName = declaration.name.text
                    members = declaration.memberBlock.members
                } else if let declaration = member.decl.as(ClassDeclSyntax.self) {
                    typeName = declaration.name.text
                    members = declaration.memberBlock.members
                } else if let declaration = member.decl.as(ActorDeclSyntax.self) {
                    typeName = declaration.name.text
                    members = declaration.memberBlock.members
                } else {
                    return
                }
                
                let typePrefix: String
                if let parentType = parentType {
                    typePrefix = "\(parentType)."
                } else {
                    typePrefix = ""
                }
                
                let nestedType = "\(typePrefix)\(typeName)"
                
                nestedTypes.append(nestedType)
                evaluationList.append((parentType: nestedType, members: members))
            }
            
            evaluationListIndex += 1
        }
        
        return nestedTypes
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
