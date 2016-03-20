//
//  RxASTableViewDelegateProxy.swift
//  Pods
//
//  Created by Lance Zhu on 2016-03-18.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

#if os(iOS)
import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
    
/**
 For more information take a look at `DelegateProxyType`.
 */
public class RxASTableViewDelegateProxy : RxTableViewDelegateProxy, ASTableViewDelegate {
    
    private var _contentOffsetSubject: ReplaySubject<CGPoint>?
    
    /**
     Typed parent object.
     */
    public weak private(set) var asTableView: ASTableView?
    
    /**
     Optimized version used for observing content offset changes.
     */
    internal var contentOffsetSubject: Observable<CGPoint> {
        if _contentOffsetSubject == nil {
            let replaySubject = ReplaySubject<CGPoint>.create(bufferSize: 1)
            _contentOffsetSubject = replaySubject
            replaySubject.on(.Next(self.scrollView?.contentOffset ?? CGPointZero))
        }
        
        return _contentOffsetSubject!
    }

    
    /**
     Initializes `RxASTableViewDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.asTableView = (parentObject as! ASTableView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate proxy
    
    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let asTableView = (object as! ASTableView)
        
        return castOrFatalError(asTableView.rx_createDelegateProxy())
//        let scrollView = (object as! UIScrollView)
//        
//        return castOrFatalError(scrollView.rx_createDelegateProxy())
    }
    
//    /**
//     For more information take a look at `DelegateProxyType`.
//     */
//    public override class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
//        rxFatalError("ASTableView uses asyncDelegate, not UITableView's delegate property. Must call `setCurrentAsyncDelegate:object`.")
//    }
//    
//    /**
//     For more information take a look at `DelegateProxyType`.
//     */
//    public override class func currentDelegateFor(object: AnyObject) -> AnyObject? {
//        rxFatalError("ASTableView uses asyncDelegate, not UITableView's delegate property. Must call `setCurrentAsyncDelegate:object`.")
//    }
    
    public override class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let tv: ASTableView = castOrFatalError(object)
        tv.asyncDelegate = castOptionalOrFatalError(delegate)
    }
    
    public override class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let tv: ASTableView = castOrFatalError(object)
        return tv.asyncDelegate
    }
}
    
#endif
