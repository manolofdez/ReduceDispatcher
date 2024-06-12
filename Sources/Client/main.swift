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
        @SkipDispatch
        case enterBackground
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.child, action: \.child, child: { ChildReducer() })
        
        Dispatch(self)
    }
}

extension ParentReducer: ParentReducerActionDelegate {
    func child(_ action: ChildReducer.Action, state: inout State) -> Effect<Action> {
        .none
    }
    
    func didAppear(state: inout State) -> Effect<Action> {
        .none
    }
    
    func updateText(_ string: String, animated: Bool, state: inout State) -> Effect<Action> {
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
