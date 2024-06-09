// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ReduceDispatcherPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ReduceDispatcherMacro.self,
    ]
}
