//
//  RxPaginatedASTableViewSectionedReloadDataSource.swift
//  Pods
//
//  Created by Lance Zhu on 03/14/2016.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import AsyncDisplayKit

public class RxASTableViewSectionedReloadDataSource<S: SectionModelType> : RxASTableViewSectionedDataSource<S>, RxASTableViewDataSourceType {
    public typealias Element = [S]
    
    public override init() {
        super.init()
    }
    
    public func tableView(tableView: ASTableView, observedEvent: Event<Element>) {
        ASDKUIBindingObserver(UIElement: self) { dataSource, element in
            dataSource.setSections(element)
            tableView.reloadData()
            }.on(observedEvent)
    }
}
