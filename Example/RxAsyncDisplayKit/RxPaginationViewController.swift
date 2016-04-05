//
//  RefreshableTableViewController
//  RxAsyncDisplayKit
//
//  Created by Lance Zhu on 03/14/2016.
//  Copyright (c) 2016 Lance Zhu. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxDataSources
import RxCocoa
import RxSwift
import RxAsyncDisplayKit

class RepositoryCell : ASCellNode {
    
    let nameText = ASTextNode()
    let urlText = ASTextNode()
    
    init(name: String, url: String) {
        super.init()
        
        
        nameText.name = "Name"
        nameText.attributedString = NSAttributedString(string: name, attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(15),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ])
        nameText.flexShrink = true
        nameText.maximumNumberOfLines = 1
        nameText.truncationMode = NSLineBreakMode.ByCharWrapping
        addSubnode(nameText)

        urlText.name = "URL"
        urlText.attributedString = NSAttributedString(string: url, attributes: [
            NSFontAttributeName: UIFont.systemFontOfSize(13),
            NSForegroundColorAttributeName: UIColor.blackColor()
            ])
        urlText.flexShrink = true
        urlText.maximumNumberOfLines = 2
        urlText.truncationMode = NSLineBreakMode.ByTruncatingTail
        addSubnode(urlText)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.verticalStackLayoutSpec()
        stack.spacing = 3
        stack.justifyContent = .Start
        stack.alignItems = .Start
        stack.setChildren([nameText, urlText])
        stack.sizeRange = ASRelativeSizeRange(
            min: ASRelativeSize(
                width: ASRelativeDimension(type: .Percent, value: 1.0),
                height: ASRelativeDimension(type: .Points, value: constrainedSize.min.height * 0.3)
            ),
            max: ASRelativeSize(
                width: ASRelativeDimension(type: .Percent, value: 1.0),
                height: ASRelativeDimension(type: .Points, value: constrainedSize.max.height * 0.6)
            )
        )
        
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: 2,
                left: 4,
                bottom: 2,
                right: 4
            ),
            child: ASStaticLayoutSpec(children: [stack])
        )
    }
}

class RxPaginationViewController: _BaseViewController, ASTableViewDelegate {
    static let startLoadingOffset: CGFloat = 20.0
    
    static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: ASTableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    private lazy var tableView: ASTableView = {
        let searchBarBounds = self.searchBar.bounds
        let convertedSearchBarOrigin = self.view.convertPoint(searchBarBounds.origin, fromCoordinateSpace: self.searchBar)
        
        let tableView = ASTableView(
            frame: CGRect(
                x: convertedSearchBarOrigin.x,
                y: convertedSearchBarOrigin.y + searchBarBounds.height,
                width: self.view.bounds.width,
                height: self.view.bounds.height - convertedSearchBarOrigin.y - searchBarBounds.height
            ),
            style: UITableViewStyle.Grouped,
            asyncDataFetching: true
        )

        // makes the gap between table view and navigation bar go away
        tableView.tableHeaderView = UITableViewHeaderFooterView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: CGFloat.min))
        // makes the gap at the bottom of the table view go away
        tableView.tableFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: CGFloat.min))

        tableView.separatorStyle = .None

        return tableView
    }()
    
    private let dataSource = RxASTableViewSectionedReloadDataSource<SectionModel<String, Repository>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
//        let tableView = self.tableView
//        let searchBar = self.searchBar
        
        dataSource.configureCell = { (dataSource: RxASTableViewSectionedDataSource<SectionModel<String, Repository>>, tableView, indexPath, repository) in
            let cell = RepositoryCell(name: repository.name, url: repository.url)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { (dataSource, sectionIndex) in
            let section = dataSource.sectionAtIndex(sectionIndex)
            return section.items.count > 0 ? "Repositories (\(section.items.count))" : "No repositories found"
        }
        
        
        let loadNextPageTrigger = tableView.rx_asyncContentOffset
            .flatMap { offset -> Observable<Void> in
                RxPaginationViewController.isNearTheBottomEdge(offset, self.tableView)
                    ? Observable.just()
                    : Observable.empty()
            }
        
        let searchResult = searchBar.rx_text.asDriver()
            .throttle(0.3)
            .distinctUntilChanged()
            .flatMapLatest { query -> Driver<RepositoriesState> in
                if query.isEmpty {
                    return Driver.just(RepositoriesState.empty)
                } else {
                    return GitHubSearchRepositoriesAPI.sharedAPI.search(query, loadNextPageTrigger: loadNextPageTrigger)
                        .asDriver(onErrorJustReturn: RepositoriesState.empty)
                }
        }
        
        searchResult
            .map {
                $0.serviceState
            }
            .drive(navigationController!.rx_serviceState)
            .addDisposableTo(disposeBag)
        
        searchResult
            .map {
                [SectionModel(model: "Repositories", items: $0.repositories)]
            }
            .drive(tableView.rx_itemsWithAsyncDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        searchResult
            .filter { $0.limitExceeded }
            .driveNext { n in
                showAlert("Exceeded limit of 10 non authenticated requests per minute for GitHub API. Please wait a minute. :(\nhttps://developer.github.com/v3/#rate-limiting")
            }
            .addDisposableTo(disposeBag)
        
        // dismiss keyboard on scroll
        tableView.rx_asyncContentOffset
            .subscribe { _ in
                if self.searchBar.isFirstResponder() {
                    _ = self.searchBar.resignFirstResponder()
                }
            }
            .addDisposableTo(disposeBag)
        
        // so normal delegate customization can also be used
        tableView.rx_setAsyncDelegate(self)
            .addDisposableTo(disposeBag)
        
//         activity indicator in status bar
//         {
        GitHubSearchRepositoriesAPI.sharedAPI.activityIndicator
            .drive(UIApplication.sharedApplication().rx_networkActivityIndicatorVisible)
            .addDisposableTo(disposeBag)
//         }
    }
    
    // MARK: Table view delegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    deinit {
        // I know, I know, this isn't a good place of truth, but it's no
        self.navigationController?.navigationBar.backgroundColor = nil
    }
}

//public class RxTableViewController: _BaseViewController {
//    
//    // MARK: - UI Controls
//    private lazy var tableView: ASTableView = {
//        let tableView = ASTableView(frame: self.view.bounds, style: UITableViewStyle.Grouped, asyncDataFetching: true)
//        
//        // makes the gap between table view and navigation bar go away
//        tableView.tableHeaderView = UITableViewHeaderFooterView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: CGFloat.min))
//        // makes the gap at the bottom of the table view go away
//        tableView.tableFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.size.width, height: CGFloat.min))
//        
//        tableView.separatorStyle = .None
//        //        tableView.asyncDataSource = self
////        tableView.rx
//        
//        return tableView
//    }()
//    
//    
//    // MARK: - Properties
//    public var startLoadingOffset: CGFloat = 20.0
//    
//    private let dataSource = RxASTableViewSectionedReloadDataSource<SectionModel<String, CellData>>()
//    //    private var pre
//    
//    // MARK: - Setups
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //        title = "推荐"
//        //        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        //        navigationController?.navigationBar.barTintColor = UIColor.x_PrimaryColor()
//        //        navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        
//        view.opaque = true
//        //        view.backgroundColor = UIColor.x_FeaturedTableBG()
//        
//        view.addSubview(tableView)
//        
//        //        let tableView = self.tableView
//        
//        dataSource.configureCell = { (dataSource: RxASTableViewSectionedDataSource<SectionModel<String, CellData>>, tableView, indexPath, cellViewModel) in
//            return ASCellNode()
//        }
//        
//        //        let loadNextPageTrigger = tableView.rx_contentOffset
//        //            .flatMap { offset in
//        //                self.isNearTheBottomEdge(offset, self.tableView)
//        //                    ? Observable.just()
//        //                    : Observable.empty()
//        //            }
//        //        tableView.asyncDelegate
////        tableView.rx_setDataSource(self)
////            .addDisposableTo(disposeBag)
////        tableView.rx_setAsyncDelegate(self)
////            .addDisposableTo(disposeBag)
//        tableView.rx_setDelegate(self)
//            .addDisposableTo(disposeBag)
//    }
//    
//    public override func viewWillLayoutSubviews() {
//        self.tableView.frame = self.view.bounds
//    }
//    
//    public override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    public override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        
//        //        viewmodel.fetchMoreData()
//        //            .start()
//        
//        
//        //        compositeDisposable += singleSectionInfiniteTableViewManager.reactToDataSource(targetedSection: 0)
//        //            .takeUntilViewWillDisappear(self)
//        //            .logLifeCycle(LogContext.Featured, signalName: "viewmodel.collectionDataSource.producer")
//        //            .start()
//        
//        
//        
//        //        // create a signal associated with `tableView:didSelectRowAtIndexPath:` form delegate `UITableViewDelegate`
//        //        // when the specified row is now selected
//        //        compositeDisposable += rac_signalForSelector(Selector("tableView:didSelectRowAtIndexPath:"), fromProtocol: UITableViewDelegate.self).toSignalProducer()
//        //            // forwards events from producer until the view controller is going to disappear
//        //            .takeUntilViewWillDisappear(self)
//        //            .map { ($0 as! RACTuple).second as! NSIndexPath }
//        //            .logLifeCycle(LogContext.Featured, signalName: "tableView:didSelectRowAtIndexPath:")
//        //            .startWithNext { [weak self] indexPath in
//        //                self?.viewmodel.pushSocialBusinessModule(indexPath.row)
//        //        }
//        
//        /**
//        Assigning UITableView delegate has to happen after signals are established.
//        
//        - tableView.delegate is assigned to self somewhere in UITableViewController designated initializer
//        
//        - UITableView caches presence of optional delegate methods to avoid -respondsToSelector: calls
//        
//        - You use -rac_signalForSelector:fromProtocol: and RAC creates method implementation for you in runtime. But UITableView knows nothing about this implementation, it still thinks that there's no such method
//        
//        The solution is to reassign delegate after all your -rac_signalForSelector:fromProtocol: calls:
//        */
//        //        tableView.asyncDelegate = nil
//        //        tableView.asyncDelegate = self
//    }
//    
//    deinit {
//        //        singleSectionInfiniteTableViewManager.cleanUp()
//        //        compositeDisposable.dispose()
//    }
//    
//    // MARK: - Bindings
//    
//    //    public func bindToViewModel(viewmodel: IFeaturedListViewModel) {
//    //        self.viewmodel = viewmodel
//    //
//    //    }
//    
//    
//    private func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
//        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
//    }
//}
//
////extension RxTableViewController : ASTableViewDataSource, ASTableViewDelegate {
////    /**
////     Tells the data source to return the number of rows in a given section of a table view. (required)
////
////     - parameter tableView: The table-view object requesting this information.
////     - parameter section:   An index number identifying a section in tableView.
////
////     - returns: The number of rows in section.
////     */
////    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//////        return viewmodel.collectionDataSource.count
////        return 10
////    }
////
////    public func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
//////        let cell = FeaturedListCellNode(viewmodel: viewmodel.collectionDataSource.array[indexPath.row])
////
//////        return cell
////        return ASCellNode()
////    }
////}
//
//extension RxTableViewController: ASTableViewDelegate {
//    //    /**
//    //     Tells the delegate when the user finishes scrolling the content.
//    //
//    //     - parameter scrollView:          The scroll-view object where the user ended the touch..
//    //     - parameter velocity:            The velocity of the scroll view (in points) at the moment the touch was released.
//    //     - parameter targetContentOffset: The expected offset when the scrolling action decelerates to a stop.
//    //     */
//    //    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//    //        // make sure the scrollView instance is the same instance as tha tableView in this class.
//    ////        if tableView === scrollView {
//    ////            predictiveScrolling(tableView, withVelocity: velocity, targetContentOffset: targetContentOffset, predictiveScrollable: viewmodel as! FeaturedListViewModel)
//    ////        }
//    //    }
//}
