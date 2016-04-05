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
