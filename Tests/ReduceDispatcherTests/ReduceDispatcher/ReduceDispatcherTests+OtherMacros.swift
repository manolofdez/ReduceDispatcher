// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

extension ParentReducerTests {
    
    func testMacro_whenDeclaresMacrosBelow_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            @Reducer
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            @Reducer
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
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
                        case .didAppear:
                            return actionDelegate.didAppear(state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func didAppear(state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenDeclaresMacrosAbove_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @Reducer
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            @Reducer
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
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
                        case .didAppear:
                            return actionDelegate.didAppear(state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func didAppear(state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenUsingReducerMacro_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @Reducer
            @ReduceDispatcher
            struct ParentReducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            @Reducer
            struct ParentReducer {
                struct State {}
                
                enum Action {
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
                        case .didAppear:
                            return actionDelegate.didAppear(state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func didAppear(state: inout State) -> Effect<Action>
            }
            """
        }
    }
}
