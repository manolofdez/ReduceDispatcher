// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftSyntax
import SwiftSyntaxMacros

extension MacroExpansionContext {
    func diagnose(error: Error, in node: some SyntaxProtocol) {
        diagnose(DiagnosticUtilities.diagnostic(for: error, in: node))
    }
    
    func diagnose(error: ExpansionError, in node: some SyntaxProtocol) {
        diagnose(DiagnosticUtilities.diagnostic(for: error, in: node))
    }
}
