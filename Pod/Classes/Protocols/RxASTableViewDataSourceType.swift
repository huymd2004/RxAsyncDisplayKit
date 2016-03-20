//
//  RxASTableViewDataSourceType.swift
//  Pods
//
//  Created by Lance Zhu on 03/14/2016.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

#if os(iOS)
    
import Foundation
import UIKit
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
#endif
    
/**
 Marks data source as `UITableView` reactive data source enabling it to be used with one of the `bindTo` methods.
 */
public protocol RxASTableViewDataSourceType /*: ASTableViewDataSource*/ {
    
    /**
     Type of elements that can be bound to table view.
     */
    typealias Element
    
    /**
     New observable sequence event observed.
     
     - parameter tableView: Bound table view.
     - parameter observedEvent: Event
     */
    func tableView(tableView: ASTableView, observedEvent: Event<Element>) -> Void
}
    
#endif
