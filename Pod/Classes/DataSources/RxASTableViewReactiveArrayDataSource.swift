//
//  RxASTableViewReactiveArrayDataSource.swift
//  Pods
//
//  Created by Lance Zhu on 03/14/2016.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//
//

#if os(iOS)
    
import Foundation
import UIKit
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
    
// objc monkey business
class _RxASTableViewReactiveArrayDataSource
    : NSObject
, ASTableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }
    
    func _tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        rxAbstractMethod()
    }
    
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return _tableView(tableView, nodeForRowAtIndexPath: indexPath)
    }
}


class RxASTableViewReactiveArrayDataSourceSequenceWrapper<S: SequenceType>
    : RxASTableViewReactiveArrayDataSource<S.Generator.Element>
, RxASTableViewDataSourceType {
    typealias Element = S
    
    override init(cellFactory: CellFactory) {
        super.init(cellFactory: cellFactory)
    }
    
    func tableView(tableView: ASTableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, sectionModels in
            let sections = Array(sectionModels)
            tableViewDataSource.tableView(tableView, observedElements: sections)
            }.on(observedEvent)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxASTableViewReactiveArrayDataSource<Element>
    : _RxASTableViewReactiveArrayDataSource
, SectionedViewDataSourceType {
    typealias CellFactory = (ASTableView, Int, Element) -> ASCellNode
    
    var itemModels: [Element]? = nil
    
    func modelAtIndex(index: Int) -> Element? {
        return itemModels?[index]
    }
    
    func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.ItemsNotYetBound(object: self)
        }
        return item
    }
    
    let cellFactory: CellFactory
    
    init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels?.count ?? 0
    }
    
    override func _tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return cellFactory(tableView, indexPath.item, itemModels![indexPath.row])
    }
    
    // reactive
    
    func tableView(tableView: ASTableView, observedElements: [Element]) {
        self.itemModels = observedElements
        
        tableView.reloadData()
    }
}
    
#endif
