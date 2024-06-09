// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntax

public enum ReduceDispatcherMacro {
    public enum Error: Swift.Error {
        case invalidRootNodeType
        case reducerConformanceNotFound
        case nestedActionRequired
        case unsupportedParameter(node: Syntax)
    }
}
