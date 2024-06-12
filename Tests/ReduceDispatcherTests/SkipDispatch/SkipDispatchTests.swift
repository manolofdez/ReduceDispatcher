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

final class SkipDispatchTests: XCTestCase {
    
    override func invokeTest() {
        withMacroTesting(macros: [
            ReduceDispatcherMacro.self,
            SkipDispatchMacro.self
        ]) {
            super.invokeTest()
        }
    }
    
    func testMacro_whenAppliedToAnEnumCase_itsNotAddedToTheProtocolOrDispatched() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                    @SkipDispatch
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .child(value0):
                            return actionDelegate.child(value0, state: &state)
                        case .didAppear:
                            return .none
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ value0: ChildReducer.Action, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenAppliedToNonEnumCase_fails() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                @SkipDispatch
                enum Action {
                    case child(ChildReducer.Action)
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } diagnostics: {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                @SkipDispatch
                ╰─ 🛑 SkipDispatch can only be used in enum case
                enum Action {
                    case child(ChildReducer.Action)
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        }
    }
}
