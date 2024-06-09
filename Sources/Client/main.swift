import ReduceDispatcher
import ComposableArchitecture

@Reducer
@ReduceDispatcher
struct ParentReducer {
    
    struct State {
        var child: ChildReducer.State
    }
    
    enum Action {
        case updateText(String, animated: Bool)
        case child(ChildReducer.Action)
        case didAppear
        case enterBackground
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.child, action: \.child, child: { ChildReducer() })
        
        Dispatch(self)
    }
}

extension ParentReducer: ParentReducerActionDelegate {
    func reduceChild(_ action: ChildReducer.Action, into state: inout State) -> Effect<Action> {
        .none
    }
    
    func reduceDidAppear(into state: inout State) -> Effect<Action> {
        .none
    }
    
    func reduceEnterBackground(into state: inout State) -> Effect<Action> {
        .none
    }
    
    func reduceUpdateText(_ string: String, animated: Bool, into state: inout State) -> Effect<Action> {
        .none
    }
}

struct ChildReducer: Reducer {
    struct State {}
    enum Action {
        case updateText(String)
        case updateIsEnabled(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            return .none
        }
    }
}
