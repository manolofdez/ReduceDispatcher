// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import XCTest
import ComposableArchitecture
import ReduceDispatcher
import MacroTesting

final class DispatchTests: XCTestCase {
    
    @MainActor
    func testDispatchReducer_callsTheAppropriateFunctionAndUpdatesTheState() async {
        let store = TestStore(initialState: .init(), reducer: { TestReducer() })
        
        await store.send(.didStartTest) {
            $0.functionCalled.append("reduceDidStartTest")
        }
    }
    
    @MainActor
    func testDispatchReducer_handlesEffectsCorrectly() async {
        let store = TestStore(initialState: .init(), reducer: { TestReducer() })
        
        await store.send(.sendTestEffect) {
            $0.functionCalled.append("sendTestEffect")
        }
        
        await store.receive(.testEffect) {
            $0.functionCalled.append("testEffect")
        }
    }
    
}

@ReduceDispatcher
fileprivate struct TestReducer: Reducer, TestReducerActionDelegate {
    struct State: Equatable {
        var functionCalled: [String] = []
    }
    
    enum Action {
        case didStartTest
        case sendTestEffect
        case testEffect
    }
    
    var body: some ReducerOf<Self> {
        Dispatch(self)
    }
    
    func reduceDidStartTest(into state: inout State) -> Effect<Action> {
        state.functionCalled.append("reduceDidStartTest")
        return .none
    }
    
    func reduceSendTestEffect(into state: inout State) -> Effect<Action> {
        state.functionCalled.append("sendTestEffect")
        return .send(.testEffect)
    }
    
    func reduceTestEffect(into state: inout State) -> Effect<Action> {
        state.functionCalled.append("testEffect")
        return .none
    }
}
