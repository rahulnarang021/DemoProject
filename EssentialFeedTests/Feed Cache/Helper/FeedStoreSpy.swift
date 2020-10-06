//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 17/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import EssentialFeed

enum FeedStoreMessages: Equatable {
    case save([LocalFeedItem], Date)
    case load
    case delete
}
class FeedStoreSpy: FeedStore {

    var receivedMessages: [FeedStoreMessages] = []

    var loadFeedBlock: LoadCompletionBlock?
    var block: OperationCompletionBlock?

    func save(_ items: [LocalFeedItem], cacheDate: Date, completion:  @escaping OperationCompletionBlock) {
        receivedMessages.append(.save(items, cacheDate))
        block = completion
    }

    func delete(completion: @escaping OperationCompletionBlock) {
        receivedMessages.append(.delete)
        block = completion
    }

    func loadFeedItem(completion: @escaping LoadCompletionBlock) {
        receivedMessages.append(.load)
        loadFeedBlock = completion
    }

    func completeDeletionWithError(_ error: Error) {
        block?(error)
    }

    func completeSaveOperationWithError(error: Error?) {
        block?(error)
    }

    func completeDeleteOperationSuccefully() {
        block?(nil)
    }

    func completeSaveOperationSuccefully() {
        block?(nil)
    }

    func completeLoadOperationWithError(error: Error) {
        loadFeedBlock?(.failure(error))
    }

    func completeLoadOperationWithEmptyFeed() {
        loadFeedBlock?(.empty)
    }

    func completeLoadOperation(withResult result: [LocalFeedItem], timestamp: Date) {
        loadFeedBlock?(.found(feed: result, cacheInterval: timestamp))
    }
}
