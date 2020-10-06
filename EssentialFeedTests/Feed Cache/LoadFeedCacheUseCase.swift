//
//  LoadFeedCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 17/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedCacheUseCaseTests: XCTestCase {

    func test_initDoesNotCallGetMethod() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_loadFeedItemCallsLoadFeedOnStore() {
        let (sut, store) = makeSUT()
        sut.load {_ in }
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadFeedItemToFailWhenFeedStoreFailed() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(anyError), when: {
            store.completeLoadOperationWithError(error: anyError)
        })
    }

    func test_loadFeedItemReturnsEmptyItemsIfThereIsNoCachePresent() {
        let (sut, store) = makeSUT()
        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeLoadOperationWithEmptyFeed()
        })
    }

    func test_loadFeedItemReturnsResultWhenCacheIsLessThanItsExpiryTime() {
        let (sut, store) = makeSUT()
        let (feed, localFeed) = uniqueItems()
        let currentDate = Date()
        expect(sut, toCompleteWithResult: .success([feed]), when: {
            store.completeLoadOperation(withResult: [localFeed], timestamp: currentDate.minusCacheExpiry().addSeconds(1))
        })
    }

    func test_loadFeedItemDoesNotReturnsResultWhenCacheIsExactlyatExpiryTime() {
        let (sut, store) = makeSUT()
        let (_, localFeed) = uniqueItems()
        let currentDate = Date()
        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeLoadOperation(withResult: [localFeed], timestamp: currentDate.minusCacheExpiry())
        })
    }

    func test_loadFeedItemCallsDoesnotCallDeletetionInCaseOfFailure() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        store.completeLoadOperationWithError(error: anyError)
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadFeedItemDoesNotReturnsResultWhenCacheIsBeforeExpiry() {
        let (sut, store) = makeSUT()
        let (_, localFeed) = uniqueItems()
        let currentDate = Date()
        expect(sut, toCompleteWithResult: .success([]), when: {
            store.completeLoadOperation(withResult: [localFeed], timestamp: currentDate.minusCacheExpiry().addSeconds(-1))
        })
    }

    func test_loadFeedItemCallsDoesNotCallDeletetionInCaseOfCacheIsOfExpiryTime() {
        let (sut, store) = makeSUT()
        let currentDate = Date()
        sut.load { _ in }
        store.completeLoadOperation(withResult: [], timestamp: currentDate.minusCacheExpiry())
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadFeedItemCallsDoesNotCallDeletetionInCaseOfMoreThanExpiryTime() {
        let (sut, store) = makeSUT()
        let currentDate = Date()
        sut.load { _ in }
        store.completeLoadOperation(withResult: [], timestamp: currentDate.minusCacheExpiry().addSeconds(-1))
        XCTAssertEqual(store.receivedMessages, [.load])
    }

    func test_loadFeedDoesNotReturnAnyResultFeedStoreWhenItsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, date: Date.init)
        var captureResult: LocalFeedLoader.ResultType?
        sut?.load { result in
            captureResult = result
        }
        sut = nil
        store.completeLoadOperationWithError(error: anyError)
        XCTAssertNil(captureResult)
    }

    // MARK: - Helper Methods
    private func expect(_ sut: LocalFeedLoader, toCompleteWithResult expectedResult: LocalFeedLoader.ResultType, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load to complete")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeedItem), .success(expectedFeedItem)):
                XCTAssertEqual(receivedFeedItem, expectedFeedItem, file: file, line: line)

            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("Received \(receivedResult), expected \(expectedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (LocalFeedLoader, FeedStoreSpy) {
        let store: FeedStoreSpy = FeedStoreSpy()
        let localFeedLoader = LocalFeedLoader(store: store, date: currentDate)
        testMemorLeak(store)
        testMemorLeak(localFeedLoader)
        return (localFeedLoader, store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL)
    }

    private func uniqueItems() -> (FeedItem, LocalFeedItem) {
        let feedItem = FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL)
        let localItem = LocalFeedItem(id: feedItem.id, description: feedItem.description, location: feedItem.location, imageURL: feedItem.imageURL)
        return (feedItem, localItem)
    }
}
