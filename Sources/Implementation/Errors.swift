// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation

public enum ExpansionError: Error {
    case invalidRootNodeType
    case reducerConformanceNotFound
    case nestedActionRequired
    case incorrectAttributeUsage
}
