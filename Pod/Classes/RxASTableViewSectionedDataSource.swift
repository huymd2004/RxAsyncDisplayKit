//
//  RxASTableViewSectionedDataSource.swift
//  Pods
//
//  Created by Lance Zhu on 03/14/2016.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxDataSources
import AsyncDisplayKit

/**
 * `undefined()` pretends to be able to produce a value of any type `T` which can
 * be very useful whilst writing a program. It happens that you need a value
 * (which can be a function as well) of a certain type but you can't produce it
 * just yet. However, you can always temporarily replace it by `undefined()`.
 *
 * Inspired by Haskell's
 * [undefined](http://hackage.haskell.org/package/base-4.7.0.2/docs/Prelude.html#v:undefined).
 *
 * Invoking `undefined()` will crash your program.
 *
 * Some examples:
 *
 *  - `let x : String = undefined()`
 *  - `let f : String -> Int? = undefined("string to optional int function")`
 *  - `return undefined() /* in any function */`
 *  - `let x : String = (undefined() as Int -> String)(42)`
 *  - ...
 *
 * What a crash looks like:
 *
 * `fatal error: undefined: main.swift, line 131`
 
 - parameter hint: Hint message
 - parameter file: Optional file name
 - parameter line: Optional line number
 
 - returns: Inferred calling type.
 */
func undefined<T>(hint: String="", file: StaticString=__FILE__, line: UInt=__LINE__) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}

//public struct SectionModel<Section, ItemType> : SectionModelType, CustomStringConvertible {
//    public typealias Item = ItemType
//    public var model: Section
//    
//    public var items: [Item]
//    
//    public init(model: Section, items: [Item]) {
//        self.model = model
//        self.items = items
//    }
//    
//    public init(original: SectionModel, items: [Item]) {
//        self.model = original.model
//        self.items = items
//    }
//    
//    public var description: String {
//        get {
//            return "\(self.model) > \(items)"
//        }
//    }
//}

// objc monkey business
public class _RxASTableViewSectionedDataSource: NSObject, ASTableViewDataSource {
    
    
    func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _numberOfSectionsInTableView(tableView)
    }
    
    func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tableView(tableView, numberOfRowsInSection: section)
    }
    
    func _tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return undefined("Call `tableView:nodeForRowAtIndexPath:` instead!")
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return _tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _tableView(tableView, titleForHeaderInSection: section)
    }
    
    func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _tableView(tableView, titleForFooterInSection: section)
    }
    
    func _tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _tableView(tableView, canEditRowAtIndexPath: indexPath)
    }
    
    func _tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    func _sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
    }
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return _sectionIndexTitlesForTableView(tableView)
    }
    
    func _tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return _tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }
    
    // MARK: ASTableDataSource Methods
    
    func _tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return (nil as ASCellNode?)!
    }
    
    /**
     * Similar to -tableView:cellForRowAtIndexPath:.
     *
     * @param tableView The sender.
     *
     * @param indexPath The index path of the requested node.
     *
     * @returns a node for display at this indexpath. This will be called on the main thread and should not implement reuse (it will be called once per row). Unlike UITableView's version, this method
     * is not called when the row is about to display.
     */
    public func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        return _tableView(tableView, nodeForRowAtIndexPath: indexPath)
    }
    
    //    func _tableView(tableView: ASTableView, nodeBlockForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNodeBlock {
    //        return (nil as ASCellNodeBlock?)!
    //    }
    //
    //    /**
    //     * Similar to -tableView:nodeForRowAtIndexPath:
    //     * This method takes precedence over tableView:nodeForRowAtIndexPath: if implemented.
    //     * @param tableView The sender.
    //     *
    //     * @param indexPath The index path of the requested node.
    //     *
    //     * @returns a block that creates the node for display at this indexpath.
    //     *   Must be thread-safe (can be called on the main thread or a background
    //     *   queue) and should not implement reuse (it will be called once per row).
    //     */
    //    public func tableView(tableView: ASTableView, nodeBlockForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNodeBlock {
    //        return _tableView(tableView, nodeBlockForRowAtIndexPath: indexPath)
    //    }
}

//public class RxASTableViewSectionedDataSource<S: SectionModelType>: _ASTableViewSectionedDataSource, SectionedViewDataSourceType {
public class RxASTableViewSectionedDataSource<S: SectionModelType>: _RxASTableViewSectionedDataSource {

    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (RxASTableViewSectionedDataSource<S>, ASTableView, NSIndexPath, I) -> ASCellNode
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    public var sectionModels: [S] {
        return _sectionModels.map { $0.model }
    }
    
    public func sectionAtIndex(section: Int) -> S {
        return self._sectionModels[section].model
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self._sectionModels[indexPath.section].items[indexPath.item]
    }
    
    public func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        return itemAtIndexPath(indexPath)
    }
    
    public func setSections(sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    
    public var configureCell: CellFactory! = nil
    
    public var titleForHeaderInSection: ((RxASTableViewSectionedDataSource<S>, section: Int) -> String?)?
    public var titleForFooterInSection: ((RxASTableViewSectionedDataSource<S>, section: Int) -> String?)?
    
    public var canEditRowAtIndexPath: ((RxASTableViewSectionedDataSource<S>, indexPath: NSIndexPath) -> Bool)?
    public var canMoveRowAtIndexPath: ((RxASTableViewSectionedDataSource<S>, indexPath: NSIndexPath) -> Bool)?
    
    public var sectionIndexTitles: ((RxASTableViewSectionedDataSource<S>) -> [String]?)?
    public var sectionForSectionIndexTitle:((RxASTableViewSectionedDataSource<S>, title: String, index: Int) -> Int)?
    
    public var rowAnimation: UITableViewRowAnimation = .Automatic
    
    public override init() {
        super.init()
        self.configureCell = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }
            
            return (nil as ASCellNode!)!
        }
    }
    
    // UITableViewDataSource
    
    override func _numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    override func _tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    override func _tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(self, section: section)
    }
    
    override func _tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(self, section: section)
    }
    
    override func _tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canEditRowAtIndexPath?(self, indexPath: indexPath) ??
            super._tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    override func _tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return canMoveRowAtIndexPath?(self, indexPath: indexPath) ??
            super._tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    override func _sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return sectionIndexTitles?(self) ?? super._sectionIndexTitlesForTableView(tableView)
    }
    
    override func _tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return sectionForSectionIndexTitle?(self, title: title, index: index) ??
            super._tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }
    
    // MARK: ASTableDataSource Methods
    
    override func _tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, tableView, indexPath, itemAtIndexPath(indexPath))
    }
}
