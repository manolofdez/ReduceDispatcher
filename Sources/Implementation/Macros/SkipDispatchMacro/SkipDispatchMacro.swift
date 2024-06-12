// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

public enum SkipDispatchMacro {}

extension SkipDispatchMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard declaration.as(EnumCaseDeclSyntax.self) != nil else {
            context.diagnose(error: .incorrectAttributeUsage, in: declaration)
            return []
        }
        
        return []
    }
}
