// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacroExpansion

struct DiagnosticUtilities {
    static func diagnostic(for error: Error, in node: some SyntaxProtocol) -> Diagnostic {
        if let error = error as? ExpansionError {
            return diagnostic(for: error, in: node)
        } else {
            return Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("Unknown error")
            )
        }
    }
    
    static func diagnostic(for error: ExpansionError, in node: some SyntaxProtocol) -> Diagnostic {
        switch error {
        case .invalidRootNodeType:
            return Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("The ReduceDispatcher macro needs to be applied to a struct")
            )
        case .reducerConformanceNotFound:
            return Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("The ReduceDispatcher macro requires conformance to Reducer in the declaration")
            )
        case .nestedActionRequired:
            return Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("ReduceDispatcher requires the Action enum be nested inside the Reducer")
            )
        case .incorrectAttributeUsage:
            return Diagnostic(
                node: node,
                message: MacroExpansionErrorMessage("SkipDispatch can only be used in enum case")
            )
        }
    }
    
}
