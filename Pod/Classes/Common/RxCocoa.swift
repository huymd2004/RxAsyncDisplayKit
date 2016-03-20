//
//  RxCocoa.swift
//  Pods
//
//  Created by Lance Zhu on 2016-03-18.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

// MARK: Error binding policies

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        rxFatalError(error)
    #else
        print(error)
    #endif
}

// MARK: Abstract methods

@noreturn func rxAbstractMethodWithMessage(message: String) {
    rxFatalError(message)
}

@noreturn func rxAbstractMethod() {
    rxFatalError("Abstract method")
}

// MARK: casts or fatal error

// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrFatalError<T>(value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

// MARK: Error messages

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

// MARK: Shared with RxSwift

#if !RX_NO_MODULE
    
    @noreturn func rxFatalError(lastMessage: String) {
        // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
        fatalError(lastMessage)
    }
    
#endif