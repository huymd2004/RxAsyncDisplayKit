//
//  DelegateProxyType.swift
//  Pods
//
//  Created by Lance Zhu on 2016-03-18.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif


func installDelegate<P: DelegateProxyType>(proxy: P, delegate: AnyObject, retainDelegate: Bool, onProxyForObject object: AnyObject) -> Disposable {
    weak var weakDelegate: AnyObject? = delegate
    
    assert(proxy.forwardToDelegate() === nil, "There is already a delegate set -> `\(proxy.forwardToDelegate())` for object -> `\(object)`.\nMaybe delegate was already set in `xib` or `storyboard` and now it's being overwritten in code.")
    
    proxy.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    
    // refresh properties after delegate is set
    // some views like UITableView cache `respondsToSelector`
    P.setCurrentDelegate(nil, toObject: object)
    P.setCurrentDelegate(proxy, toObject: object)
    
    assert(proxy.forwardToDelegate() === delegate, "Setting of delegate failed")
    
    return AnonymousDisposable {
        MainScheduler.ensureExecutingOnScheduler()
        
        let delegate: AnyObject? = weakDelegate
        
        assert(delegate == nil || proxy.forwardToDelegate() === delegate, "Delegate was changed from time it was first set. Current \(proxy.forwardToDelegate()), and it should have been \(proxy)")
        
        proxy.setForwardToDelegate(nil, retainDelegate: retainDelegate)
    }
}

extension ObservableType {
    func subscribeProxyDataSourceForObject<P: DelegateProxyType>(object: AnyObject, dataSource: AnyObject, retainDataSource: Bool, binding: (P, Event<E>) -> Void)
        -> Disposable {
            let proxy = proxyForObject(P.self, object)
            let disposable = installDelegate(proxy, delegate: dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
            
            let subscription = self.asObservable()
                // source can't ever end, otherwise it will release the subscriber
                .concat(Observable.never())
                .subscribe { [weak object] (event: Event<E>) in
                    
                    // FIXME: may be don't need this due to work being done on background thread in ASDK???
//                    MainScheduler.ensureExecutingOnScheduler()
                    
                    if let object = object {
                        assert(proxy === P.currentDelegateFor(object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(P.currentDelegateFor(object))")
                    }
                    
                    binding(proxy, event)
                    
                    switch event {
                    case .Error(let error):
                        bindingErrorToInterface(error)
                        disposable.dispose()
                    case .Completed:
                        disposable.dispose()
                    default:
                        break
                    }
            }
            
            return StableCompositeDisposable.create(subscription, disposable)
    }
}
