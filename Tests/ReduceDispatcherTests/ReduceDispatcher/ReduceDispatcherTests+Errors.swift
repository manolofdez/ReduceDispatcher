// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

extension ReduceDispatcherTests {
    
    // MARK: Peer
    
    func testMacro_whenAssignedToNonStruct_notifiesError() throws {
        assertMacro {
            """
            @ReduceDispatcher
            class ParentReducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } diagnostics: {
            """
            @ReduceDispatcher
            ┬────────────────
            ╰─ 🛑 The ReduceDispatcher macro needs to be applied to a struct
            class ParentReducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        }
    }
    
    func testMacro_whenAssignedToNonReducer_notifiesError() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer {
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        } diagnostics: {
            """
            @ReduceDispatcher
            struct ParentReducer {
                   ┬────────────
                   ╰─ 🛑 The ReduceDispatcher macro requires conformance to Reducer in the declaration
                struct State {}
                
                enum Action {
                    case didAppear
                }
                
                var body: some ReducerOf<Self> {}
            }
            """
        }
    }
    
    func testMacro_whenActionIsTypealiased_notifiesError() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                typealias Action = MyAction
                
                var body: some ReducerOf<Self> {}
            }
            """
        } diagnostics: {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
                
                typealias Action = MyAction
                ┬──────────────────────────
                ╰─ 🛑 ReduceDispatcher requires the Action enum be nested inside the Reducer
                
                var body: some ReducerOf<Self> {}
            }
            """
        }
    }
    
    func testMacro_whenActionIsDefinedSeparately_notifiesError() throws {
        assertMacro {
            """
            @ReduceDispatcher
            struct ParentReducer: Reducer {
                struct State {}
            }
            
            extension ParentReducer {
                enum Action {}
            
                var body: some ReducerOf<Self> {}
            }
            """
        } diagnostics: {
            """
            @ReduceDispatcher
            ┬────────────────
            ╰─ 🛑 ReduceDispatcher requires the Action enum be nested inside the Reducer
            struct ParentReducer: Reducer {
                struct State {}
            }

            extension ParentReducer {
                enum Action {}

                var body: some ReducerOf<Self> {}
            }
            """
        }
    }
}
