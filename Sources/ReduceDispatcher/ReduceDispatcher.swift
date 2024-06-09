// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation

@attached(member, names: named(Dispatch))
@attached(peer, names: suffixed(ActionDelegate))
public macro ReduceDispatcher() = #externalMacro(
    module: "ReduceDispatcherImplementation",
    type: "ReduceDispatcherMacro"
)
