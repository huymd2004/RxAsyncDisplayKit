//
//  ASTableView+Rx.swift
//  Pods
//
//  Created by Lance Zhu on 2016-03-18.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

#if os(iOS)
    
import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import AsyncDisplayKit
    
extension ASTableView {
    
    /**
     Binds sequences of elements to table view rows.
     
     - parameter source: Observable sequence of items.
     - parameter cellFactory: Transform between sequence elements and view cells.
     - returns: Disposable object that can be used to unbind.
     */
    public func rx_itemsWithAsyncCellFactory<S: SequenceType, O: ObservableType where O.E == S>
        (source: O)
        -> (cellFactory: (ASTableView, Int, S.Generator.Element) -> ASCellNode)
        -> Disposable {
            return { cellFactory in
                let dataSource = RxASTableViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)
                
                return self.rx_itemsWithAsyncDataSource(dataSource)(source: source)
            }
    }
    
    /**
     Binds sequences of elements to table view rows.
     
     - parameter cellIdentifier: Identifier used to dequeue cells.
     - parameter source: Observable sequence of items.
     - parameter configureCell: Transform between sequence elements and view cells.
     - parameter cellType: Type of table view cell.
     - returns: Disposable object that can be used to unbind.
     */
    public func rx_itemsWithAsyncCellIdentifier<S: SequenceType, Cell: ASCellNode, O : ObservableType where O.E == S>
        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
        -> (source: O)
        -> (configureCell: (Int, S.Generator.Element, Cell) -> Void)
        -> Disposable {
            return { source in
                return { configureCell in
                    let dataSource = RxASTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
                        let indexPath = NSIndexPath(forItem: i, inSection: 0)
                        let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
                        configureCell(i, item, cell)
                        return cell
                    }
                    return self.rx_itemsWithAsyncDataSource(dataSource)(source: source)
                }
            }
    }
    
    /**
     Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
     
     - parameter dataSource: Data source used to transform elements to view cells.
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    public func rx_itemsWithAsyncDataSource<DataSource: protocol<RxASTableViewDataSourceType, ASTableViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
            return { source in
                return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxASTableViewDataSourceProxy, event) -> Void in
                    guard let tableView = self else {
                        return
                    }
                    dataSource.tableView(tableView, observedEvent: event)
                }
            }
    }
    
    public func haha<DataSource: ASTableViewDataSource>(dataSource: DataSource) {
        
    }
    
    public func test<DataSource: protocol<RxASTableViewDataSourceType, ASTableViewDataSource>>(dataSource: DataSource) {
        
        
    }
    /**
     Binds sequences of elements to table view rows using a custom reactive data used to perform the transformation.
     
     - parameter dataSource: Data source used to transform elements to view cells.
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    public func rxxxx_itemsWithDataSource<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        -> (source: O)
        -> Disposable  {
            return { source in
                return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxTableViewDataSourceProxy, event) -> Void in
                    guard let tableView = self else {
                        return
                    }
                    dataSource.tableView(tableView, observedEvent: event)
                }
            }
    }
}
    
// Replace extension methods implemented for UIScrollView
extension ASTableView {
    /**
     Reactive wrapper for `contentOffset`.
     */
    public var rx_asyncContentOffset: ControlProperty<CGPoint> {
        let proxy = proxyForObject(RxASTableViewDelegateProxy.self, self)
        
        let bindingObserver = UIBindingObserver(UIElement: self) { scrollView, contentOffset in
            scrollView.contentOffset = contentOffset
        }
        
        return ControlProperty(values: proxy.contentOffsetSubject, valueSink: bindingObserver)
    }
}
    
extension ASTableView {
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxASTableViewDelegateProxy(parentObject: self)
    }
    
    // MARK: - Data Source
    
    /**
     Factory method that enables subclasses to implement their own `rx_dataSource`.
     
     - returns: Instance of delegate proxy that wraps `dataSource`.
     */
    public func rx_createAsyncDataSourceProxy() -> RxASTableViewDataSourceProxy {
        return RxASTableViewDataSourceProxy(parentObject: self)
    }
    
    /**
     Reactive wrapper for `dataSource`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public override var rx_dataSource: DelegateProxy {
        return proxyForObject(RxASTableViewDataSourceProxy.self, self)
    }
    
    /**
     Installs data source as forwarding delegate on `rx_dataSource`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func rx_setAsyncDataSource(dataSource: ASTableViewDataSource)
        -> Disposable {
        let proxy = proxyForObject(RxASTableViewDataSourceProxy.self, self)
        
        return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }
    
    // MARK: - Delegate
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public override var rx_delegate: DelegateProxy {
        return proxyForObject(RxASTableViewDelegateProxy.self, self)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx_delegate`.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object.
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func rx_setAsyncDelegate(delegate: ASTableDelegate)
        -> Disposable {
            let proxy = proxyForObject(RxASTableViewDelegateProxy.self, self)
            return installDelegate(proxy, delegate: delegate, retainDelegate: false, onProxyForObject: self)
    }
}
    
#endif
