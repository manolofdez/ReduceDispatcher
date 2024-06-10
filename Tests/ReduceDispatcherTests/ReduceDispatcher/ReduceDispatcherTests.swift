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
    
    func testMacro_whenReducerHasVisibility_addsActionDelegateWithCorrectVisibility() throws {
        assertMacro {
            """
            @ReduceDispatcher
            fileprivate struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            fileprivate struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .child(action):
                            return actionDelegate.reduceChild(action, into: &state)
                        }
                    }
                }
            }

            fileprivate protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceChild(_ action: ChildReducer.Action, into state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenReducerConformanceIsSpecifiedAlongOthers_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer, ParentReducerActionDelegate {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
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
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .child(action):
                            return actionDelegate.reduceChild(action, into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceChild(_ action: ChildReducer.Action, into state: inout State) -> Effect<Action>
            }
            """
        }
    }
}
