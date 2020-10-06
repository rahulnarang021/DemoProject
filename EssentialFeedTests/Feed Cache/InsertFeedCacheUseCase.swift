//
//  CacheLoadFeederUseCase.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 08/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed

class InsertFeedCacheUseCaseTests: XCTestCase {

    func test_cacheFeedLoaderDoesnotCallAnyMethodOnInitialise() {
        let (_, store) = makeSUT { () -> Date in
            return Date()
        }
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_saveFeedFailedWithErrorWhenItsFinishedWithDeletionError() {
        let (sut, store) = makeSUT { () -> Date in
            return Date()
        }
        expect(sut, toCompleteWithError: anyError, when: {
             store.completeDeletionWithError(anyError)
        })
    }

    func test_doesnotCallSaveWhenItFailedWithInsertionError() {
        let (sut, store) = makeSUT { () -> Date in
            return Date()
        }
        sut.save([]) { _ in }
        store.completeDeletionWithError(anyError)
        XCTAssertEqual(store.receivedMessages, [.delete])
    }

    func test_saveFeedLoaderCallsDeleteAndSaveInOrderInSuccessCase() {
        let timestamp = Date()
        let (sut, store) = makeSUT { () -> Date in
            return timestamp
        }
        let (item, localItem) = uniqueItems()
        sut.save([item]) { _ in }
        store.completeDeleteOperationSuccefully()
        store.completeSaveOperationSuccefully()
        XCTAssertEqual(store.receivedMessages, [.delete, .save([localItem], timestamp)])
    }

    func test_saveLoadFeedFailedWithErrorWhenSavingOperationFailed() {
        let (sut, store) = makeSUT { () -> Date in
            return Date()
        }
        expect(sut, toCompleteWithError: anyError, when: {
             store.completeDeleteOperationSuccefully()
             store.completeSaveOperationWithError(error: anyError)
        })
    }

    func test_saveLoadFeedCompletedSuccesfully() {// write this method to test feed load
        let (sut, store) = makeSUT { () -> Date in
            return Date()
        }
        expect(sut, toCompleteWithError: nil, when: {
             store.completeDeleteOperationSuccefully()
             store.completeSaveOperationSuccefully()
        })
    }

    func test_doesnotDeliverAnyErrorOnceSutIsDeallocated() {
        let store: FeedStoreSpy = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, date: Date.init)
        var capturedError: Error?
        sut?.save([]) {error in
            capturedError = error
        }
        sut = nil
        store.completeDeletionWithError(anyError)
        XCTAssertNil(capturedError)
    }

    func test_doesnotDeliverAnyErrorOnceSutIsDeallocatedAfterDeletionCalled() {
        let store: FeedStoreSpy = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, date: Date.init)
        var capturedError: Error?
        sut?.save([]) {error in
            capturedError = error
        }
        store.completeDeleteOperationSuccefully()
        sut = nil
        store.completeSaveOperationWithError(error: anyError)
        XCTAssertNil(capturedError)
    }

    func expect(_ sut: LocalFeedLoader, toCompleteWithError error: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        var captureError: NSError?
        let exp = expectation(description: "Wait for save block to be executed")
        sut.save([]) {error in
            captureError = error as NSError?
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(captureError, error, file: file, line: line)
    }

    // MARK: - Helper Methods
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
