//
//  ValidateCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 19/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed

class ValidateCacheUseCase: XCTestCase {

    func test_cacheFeedLoaderDoesnotCallAnyMethodOnInitialise() {
           let (_, store) = makeSUT()
           XCTAssertEqual(store.receivedMessages, [])
    }

    func test_loadRetrieveMethodOnValidateCache() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadRetrieveMethodCallsDeletionWhenFailedWithError() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        store.completeLoadOperationWithError(error: anyError)
        XCTAssertEqual(store.receivedMessages, [.load, .delete])
    }

    func test_loadRetrieveMethodDoesNotCallsDeletionWhenCacheIsLessThanExpiryDate() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        let currentDate = Date()
        store.completeLoadOperation(withResult: [], timestamp: currentDate.minusCacheExpiry().addSeconds(1))
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadRetrieveMethodCallsDeletionWhenCacheIsMoreThanExpiryDate() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        let currentDate = Date()
        store.completeLoadOperation(withResult: [], timestamp: currentDate.minusCacheExpiry().addSeconds(-1))
        XCTAssertEqual(store.receivedMessages, [.load, .delete])
    }

    func test_loadRetrieveMethodCallsDeletionWhenCacheIsLessThanExpiryDate() {
        let (sut, store) = makeSUT()
        sut.validateCache()
        let currentDate = Date()
        store.completeLoadOperation(withResult: [], timestamp: currentDate.minusCacheExpiry())
        XCTAssertEqual(store.receivedMessages, [.load, .delete])
    }

    func test_loadRetrievalDoesnotCallDeletionWhenLocalFeedLoaderIsNil() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, date: Date.init)
        sut?.validateCache()
        sut = nil
        store.completeLoadOperationWithError(error: anyError)
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    // MARK: - Helper Methods
    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store: FeedStoreSpy = FeedStoreSpy()
        let localFeedLoader = LocalFeedLoader(store: store, date: currentDate)
        testMemorLeak(store)
        testMemorLeak(localFeedLoader)
        return (localFeedLoader, store)
    }

}
