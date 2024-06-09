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
                            actionDelegate.reduceDidAppear(into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceDidAppear(into state: inout State) -> Effect<Action>
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
                            actionDelegate.reduceChild(action, into: &state)
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
                            actionDelegate.reduceDidFinish(result, into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceDidFinish(_ result: Result<String, Error>, into state: inout State) -> Effect<Action>
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
                            actionDelegate.reduceChild(id: id, action: action, into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceChild(id: UUID, action: ChildReducer.Action, into state: inout State) -> Effect<Action>
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
                            actionDelegate.reduceChild(uUID, action: action, into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceChild(_ uUID: UUID, action: ChildReducer.Action, into state: inout State) -> Effect<Action>
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
                            actionDelegate.reduceChild(action, into: &state)
                        case .didAppear:
                            actionDelegate.reduceDidAppear(into: &state)
                        case .enterBackground:
                            actionDelegate.reduceEnterBackground(into: &state)
                        case let .updateText(string, animated):
                            actionDelegate.reduceUpdateText(string, animated: animated, into: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func reduceChild(_ action: ChildReducer.Action, into state: inout State) -> Effect<Action>
                func reduceDidAppear(into state: inout State) -> Effect<Action>
                func reduceEnterBackground(into state: inout State) -> Effect<Action>
                func reduceUpdateText(_ string: String, animated: Bool, into state: inout State) -> Effect<Action>
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

