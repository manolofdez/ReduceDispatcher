// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

extension ParentReducerTests {
    
    func testMacro_whenActionHasNoAssociatedTypes_addsDispatchCorrectly() throws {
        assertMacro {
            """
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
    
    func testMacro_whenActionHasNamelessAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
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
                            return actionDelegate.child(action, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ action: ChildReducer.Action, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionHasGenericAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case didFinish(Result<String, Error>)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case didFinish(Result<String, Error>)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .didFinish(result):
                            return actionDelegate.didFinish(result, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func didFinish(_ result: Result<String, Error>, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionHasMultipleNamedAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(id: UUID, action: ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(id: UUID, action: ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .child(id, action):
                            return actionDelegate.child(id: id, action: action, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(id: UUID, action: ChildReducer.Action, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionHasMixedNamedAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(UUID, action: ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(UUID, action: ChildReducer.Action)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .child(uUID, action):
                            return actionDelegate.child(uUID, action: action, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ uUID: UUID, action: ChildReducer.Action, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenMultipleActions_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                    case didAppear
                    case enterBackground
                    case updateText(String, animated: Bool)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case child(ChildReducer.Action)
                    case didAppear
                    case enterBackground
                    case updateText(String, animated: Bool)
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
                            return actionDelegate.child(action, state: &state)
                        case .didAppear:
                            return actionDelegate.didAppear(state: &state)
                        case .enterBackground:
                            return actionDelegate.enterBackground(state: &state)
                        case let .updateText(string, animated):
                            return actionDelegate.updateText(string, animated: animated, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ action: ChildReducer.Action, state: inout State) -> Effect<Action>
                func didAppear(state: inout State) -> Effect<Action>
                func enterBackground(state: inout State) -> Effect<Action>
                func updateText(_ string: String, animated: Bool, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenNoActions_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {}
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {}
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        .none
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action


            }
            """
        }
    }
}

