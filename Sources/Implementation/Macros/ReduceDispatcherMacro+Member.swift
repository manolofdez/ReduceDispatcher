// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

extension ReduceDispatcherMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else { return [] }

        guard let members = declaration.memberBlock.members.as(MemberBlockItemListSyntax.self) else { return [] }
        
        guard let actionDeclaration = MacroUtilities.findActionDeclaration(in: members) else { return [] }
        
        let cases: [String]
        do {
            cases = try actionDeclaration.memberBlock.members.compactMap { try extractCase(from: $0) }
        } catch {
            return []
        }
        
        let casesString = cases.joined()
        let switchString = """
                           switch action {
                           \(casesString)
                           }
                           """

        let actionDelegateType = "\(declaration.name.text)ActionDelegate"
        let result: String =
        """
        private struct Dispatch: Reducer {
            private let actionDelegate: \(actionDelegateType)
            
            init(_ actionDelegate: \(actionDelegateType)) {
                self.actionDelegate = actionDelegate
            }
            
            func reduce(into state: inout State, action: Action) -> Effect<Action> {
                \(casesString.count > 0 ? switchString : ".none")
            }
        }
        """
        
        return [DeclSyntax(stringLiteral: result)]
    }
    
    private static func extractCase(from enumMember: MemberBlockItemListSyntax.Element) throws -> String? {
        guard let enumCase = enumMember.decl.as(EnumCaseDeclSyntax.self)?.elements.first else { return nil }
        
        let parameterNames = enumCase.parameterClause?.parameters.enumerated().compactMap { index, enumCaseParameter in
            MacroUtilities.extractName(from: enumCaseParameter, at: index)
        } ?? []
        
        let enumCaseName = enumCase.name.text
        let functionName = "actionDelegate.\(enumCaseName)"
        
        guard parameterNames.count > 0 else {
            return "case .\(enumCaseName):  return \(functionName)(state: &state)"
        }
        
        var functionParameters: [String] = enumCase.parameterClause?.parameters.enumerated().compactMap { index, enumCaseParameter in
            let parameterName = MacroUtilities.extractName(from: enumCaseParameter, at: index)
            return enumCaseParameter.firstName == nil || enumCaseParameter.secondName != nil
                ? parameterName 
                : "\(parameterName): \(parameterName)"
        } ?? []
        functionParameters.append("state: &state")
        
        return """
               case let .\(enumCase.name.text)(\(parameterNames.joined(separator: ", "))):
               return \(functionName)(\(functionParameters.joined(separator: ", ")))
               """
    }
}
