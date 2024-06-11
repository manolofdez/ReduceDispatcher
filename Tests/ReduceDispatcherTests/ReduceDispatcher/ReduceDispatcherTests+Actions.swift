// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

extension ReduceDispatcherTests {
    
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
                        case let .child(value0):
                            return actionDelegate.child(value0, state: &state)
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
                        case let .didFinish(value0):
                            return actionDelegate.didFinish(value0, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func didFinish(_ value0: Result<String, Error>, state: inout State) -> Effect<Action>
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
                        case let .child(value0, action):
                            return actionDelegate.child(value0, action: action, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ value0: UUID, action: ChildReducer.Action, state: inout State) -> Effect<Action>
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
                        case let .child(value0):
                            return actionDelegate.child(value0, state: &state)
                        case .didAppear:
                            return actionDelegate.didAppear(state: &state)
                        case .enterBackground:
                            return actionDelegate.enterBackground(state: &state)
                        case let .updateText(value0, animated):
                            return actionDelegate.updateText(value0, animated: animated, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func child(_ value0: ChildReducer.Action, state: inout State) -> Effect<Action>
                func didAppear(state: inout State) -> Effect<Action>
                func enterBackground(state: inout State) -> Effect<Action>
                func updateText(_ value0: String, animated: Bool, state: inout State) -> Effect<Action>
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
    
    func testMacro_whenActionWithDictionaryAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateProjects([Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateProjects([Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .updateProjects(value0):
                            return actionDelegate.updateProjects(value0, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func updateProjects(_ value0: [Project.ID: Project], state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionWithMultipleNamelessAssociatedTypes_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateTitleAndProjects(String, [Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateTitleAndProjects(String, [Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .updateTitleAndProjects(value0, value1):
                            return actionDelegate.updateTitleAndProjects(value0, value1, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func updateTitleAndProjects(_ value0: String, _ value1: [Project.ID: Project], state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionWithExplicitlyAnonymousLabels_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateTitleAndProjects(_ title: String, _ project: [Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    case updateTitleAndProjects(_ title: String, _ project: [Project.ID: Project])
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .updateTitleAndProjects(title, project):
                            return actionDelegate.updateTitleAndProjects(title, project, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func updateTitleAndProjects(_ title: String, _ project: [Project.ID: Project], state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionNestedAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        case didTapContinue
                    }
                    case alert(Alert)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        case didTapContinue
                    }
                    case alert(Alert)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .alert(value0):
                            return actionDelegate.alert(value0, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func alert(_ value0: Action.Alert, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionDoubleNestedAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        enum NestedAlertAction {
                            case didTapContinue
                        }
                    }
                    case alert(Alert.NestedAlertAction)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        enum NestedAlertAction {
                            case didTapContinue
                        }
                    }
                    case alert(Alert.NestedAlertAction)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .alert(value0):
                            return actionDelegate.alert(value0, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func alert(_ value0: Action.Alert.NestedAlertAction, state: inout State) -> Effect<Action>
            }
            """
        }
    }
    
    func testMacro_whenActionGenericNestedAssociatedType_addsDispatchCorrectly() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        case didTapContinue
                    }
                    case alert(PresentationAction<Alert, State, Presentation<Alert>>)
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } expansion: {
            """
            struct ParentReducer: Reducer {
                struct State {}
                
                enum Action {
                    enum Alert {
                        case didTapContinue
                    }
                    case alert(PresentationAction<Alert, State, Presentation<Alert>>)
                }
                
                var body: some ReducerOf<Self> {}

                private struct Dispatch: Reducer {
                    private let actionDelegate: ParentReducerActionDelegate

                    init(_ actionDelegate: ParentReducerActionDelegate) {
                        self.actionDelegate = actionDelegate
                    }

                    func reduce(into state: inout State, action: Action) -> Effect<Action> {
                        switch action {
                        case let .alert(value0):
                            return actionDelegate.alert(value0, state: &state)
                        }
                    }
                }
            }

            protocol ParentReducerActionDelegate {
                typealias State = ParentReducer.State
                typealias Action = ParentReducer.Action

                func alert(_ value0: PresentationAction<Action.Alert, State, Presentation<Action.Alert>>, state: inout State) -> Effect<Action>
            }
            """
        }
    }
}
