//
//  RefreshableTableViewModel.swift
//  RxRefreshableTable
//
//  Created by Lance Zhu on 2016-03-14.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

public struct CellData {
    
}

public class RxTableViewModel {
    
    // MARK: - Outputs
    //    public let
    
    // MARK: - Properties
    // MARK: Dependencies
//    private let businessService: IBusinessService
//    private let userService: IUserService
//    private let geoLocationService: IGeoLocationService
//    //    private let userDefaultsService: IUserDefaultsService
//    private let imageService: IImageService
//    private let participationService: IParticipationService
//    
//    public init(
//        dependency: (
//        businessService: IBusinessService,
//        userService: IUserService,
//        geoLocationService: IGeoLocationService,
//        //        userDefaultsService: IUserDefaultsService,
//        imageService: IImageService,
//        participationService: IParticipationService
//        )
//        ) {
//            self.businessService = dependency.businessService
//            self.userService = dependency.userService
//            self.geoLocationService = dependency.geoLocationService
//            //        self.userDefaultsService = dependency.userDefaultsService
//            self.imageService = dependency.imageService
//            self.participationService = dependency.participationService
//    }
}

private let 启动无限scrolling参数 = 0.4


//public final class FeaturedListViewModel : IFeaturedListViewModel, ICollectionDataSource {
//
//    public typealias Payload = FeaturedBusinessViewModel
//
//    // MARK: - Inputs
//
//    // MARK: - Outputs
//    public let collectionDataSource = ReactiveArray<FeaturedBusinessViewModel>()
//
//    // MARK: - Properties
//    // MARK: Services
//    private let businessService: IBusinessService
//    private let userService: IUserService
//    private let geoLocationService: IGeoLocationService
//    private let userDefaultsService: IUserDefaultsService
//    private let imageService: IImageService
//    private let participationService: IParticipationService
//
//    // MARK: Variables
//    public weak var navigator: FeaturedListNavigator!
//    private var numberOfBusinessesLoaded = 0
//
//    // MARK: - Initializers
//    public init(businessService: IBusinessService, userService: IUserService, geoLocationService: IGeoLocationService, userDefaultsService: IUserDefaultsService, imageService: IImageService, participationService: IParticipationService) {
//        self.businessService = businessService
//        self.userService = userService
//        self.geoLocationService = geoLocationService
//        self.userDefaultsService = userDefaultsService
//        self.imageService = imageService
//        self.participationService = participationService
//    }
//
//    // MARK: - API
//    /**
//    Retrieve featured business with pagination enabled.
//    */
//
//    public func fetchMoreData() -> SignalProducer<Void, NSError> {
//        return fetchBusinesses(false)
//            .map { _ in }
//    }
//
//    public func refreshData() -> SignalProducer<Void, NSError> {
//        return fetchBusinesses(true)
//            .map { _ in }
//    }
//
//    public func predictivelyFetchMoreData(targetContentIndex: Int) -> SignalProducer<Void, NSError> {
//        // if there are still plenty of data for display, don't fetch more businesses
//        if Double(targetContentIndex) < Double(collectionDataSource.count) - Double(Constants.PAGINATION_LIMIT) * Double(启动无限scrolling参数) {
//            return SignalProducer<Void, NSError>.empty
//        }
//            // else fetch more data
//        else {
//            return fetchBusinesses(false)
//                .map { _ in }
//        }
//    }
//
//    public func pushSocialBusinessModule(section: Int) {
//        navigator.pushSocialBusiness(collectionDataSource.array[section].business)
//    }
//
//    // MARK: - Others
//
//    /**
//    Fetch featured businesses. If `refresh` is `true`, the function will replace the original list with new data, effectively refreshing the list. If `refresh` is `false`, the function will get data continuously like pagination.
//
//    - parameter refresh: A `Boolean` value indicating whether the function should `refresh` or `get more like pagination`.
//
//    - returns: A signal producer.
//    */
//    private func fetchBusinesses(refresh: Bool = false) -> SignalProducer<[FeaturedBusinessViewModel], NSError> {
//        let query = Business.query()
//        // TODO: temporarily disabled until we have more featured businesses
//        //        query.whereKey(Business.Property.Featured.rawValue, equalTo: true)
//        query.limit = Constants.PAGINATION_LIMIT
//        query.includeKey(Business.Property.address)
//        if refresh {
//            // don't skip any content if we are refresh the list
//            query.skip = 0
//        }
//        else {
//            query.skip = numberOfBusinessesLoaded
//        }
//
//        return businessService.findBy(query)
//            .map { $.shuffle($0) }
//            .on(next: { businesses in
//
//                if refresh {
//                    // set numberOfBusinessesLoaded to the number of businesses fetched
//                    self.numberOfBusinessesLoaded = businesses.count
//                }
//                else {
//                    // increment numberOfBusinessesLoaded
//                    self.numberOfBusinessesLoaded += businesses.count
//                }
//            })
//            .map { businesses -> [FeaturedBusinessViewModel] in
//
//                // map the business models to viewmodels
//                return businesses.map { business in
//                    let cellViewModel = FeaturedBusinessViewModel(userService: self.userService, geoLocationService: self.geoLocationService, imageService: self.imageService, participationService: self.participationService, business: business)
//
//                    cellViewModel.calculateEta()
//                        .start()
//
//                    return cellViewModel
//                }
//            }
//            .on(
//                next: { viewmodels in
//                    if refresh && viewmodels.count > 0 {
//                        // ignore old data
//                        self.collectionDataSource.replaceAll(viewmodels)
//                    }
//                    else if !refresh && viewmodels.count > 0 {
//                        // save the new data with old ones
//                        self.collectionDataSource.appendContentsOf(viewmodels)
//                    }
//                },
//                failed: { FeaturedLogError($0.description) }
//        )
//    }
//}