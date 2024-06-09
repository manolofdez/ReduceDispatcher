// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

#if canImport(ReduceDispatcherImplementation)
import ReduceDispatcherImplementation
#endif

final class ParentReducerTests: XCTestCase {
    
    override func invokeTest() {
        withMacroTesting(macros: [
            ReduceDispatcherMacro.self
        ]) {
            super.invokeTest()
        }
    }
}
