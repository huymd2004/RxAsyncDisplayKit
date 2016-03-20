//
//  RxASTableViewDataSourceProxy.swift
//  Pods
//
//  Created by Lance Zhu on 2016-03-18.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import Foundation

#if os(iOS)
    
import Foundation
import UIKit
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
    
let asTableViewDataSourceNotSet = ASTableViewDataSourceNotSet()

class ASTableViewDataSourceNotSet : NSObject, ASTableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

/**
 For more information take a look at `DelegateProxyType`.
 */
public class RxASTableViewDataSourceProxy : DelegateProxy, ASTableViewDataSource, DelegateProxyType {
    
    /**
     Typed parent object.
     */
    public weak private(set) var tableView: ASTableView?
    
    private weak var _requiredMethodsDataSource: ASTableViewDataSource? = asTableViewDataSourceNotSet
    
    /**
     Initializes `RxTableViewDataSourceProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! ASTableView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: delegate
    
    /**
    Required delegate method implementation.
    */
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (_requiredMethodsDataSource ?? asTableViewDataSourceNotSet).numberOfSectionsInTableView?(tableView) ?? 1
    }
    
    /**
     Required delegate method implementation.
     */
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource ?? asTableViewDataSourceNotSet).tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return (_requiredMethodsDataSource ?? asTableViewDataSourceNotSet).tableView(tableView, nodeForRowAtIndexPath: indexPath)
    }
    
    // MARK: proxy
    
    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let tableView = (object as! ASTableView)
        
        return castOrFatalError(tableView.rx_createAsyncDataSourceProxy())
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _ppointer(&dataSourceAssociatedTag)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let tv: ASTableView = castOrFatalError(object)
        tv.asyncDataSource = castOptionalOrFatalError(delegate)
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let tv: ASTableView = castOrFatalError(object)
        return tv.asyncDataSource
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: ASTableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? asTableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
    
    // MARK: Pointer
    
    class func _ppointer(p: UnsafePointer<Void>) -> UnsafePointer<Void> {
        return p
    }
}
    
#endif
