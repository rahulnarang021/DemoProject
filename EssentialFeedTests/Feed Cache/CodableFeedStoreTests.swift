//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 01/07/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {

    private var testSpecificStoreUrl: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self))")
    }

    override func tearDown() {
        super.tearDown()
        clearDisk()
    }

    override func setUp() {
        super.setUp()
        clearDisk()
    }

    func clearDisk() {
        try? FileManager.default.removeItem(at: testSpecificStoreUrl)
    }

    func test_retrieveEmptyCacheReturnsEmptyResult() {
        let sut = makeSUT()
        self.loadCache(sut: sut, expectedResult: .empty)
    }

    func test_retrieveEmptyCacheTwiceReturnsEmpty() {
        let sut = makeSUT()
        self.loadCache(sut: sut, expectedResult: .empty)
        self.loadCache(sut: sut, expectedResult: .empty)
    }

    func test_operationsAreExecutedSerially() {
        let sut = makeSUT()
        let items = [uniqueItems().1]

        var operations: [XCTestExpectation] = []

        let op1 = expectation(description: "Wait for save cache to complete")
        sut.save(items, cacheDate: Date()) {_ in
            operations.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Wait for load cache to complete")
        sut.loadFeedItem {result	 in
            operations.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Wait for delete cache to complete")
        sut.delete(completion: {_ in
            operations.append(op3)
            op3.fulfill()
        })
        wait(for: [op1, op2, op3], timeout: 3.0)

        XCTAssertEqual([op1, op2, op3], operations)
    }
    
    func test_insertInEmptyStoreReturnsNonEmptyData() {
        let sut = makeSUT()
        let items = [uniqueItems().1]
        let currentDate = Date()

        let error = save(sut: sut, feed: items, timestamp: currentDate)
        XCTAssertNil(error, "Expected empty but got \(error!) instead")

        self.loadCache(sut: sut, expectedResult: .found(feed: items, cacheInterval: currentDate))
    }

    func test_insertInEmptyStoreReturnsNonEmptyDataTwiceWithNoSideEffects() {
        let sut = makeSUT()
        let items = [uniqueItems().1]
        let currentDate = Date()
        let error = save(sut: sut, feed: items, timestamp: currentDate)
        XCTAssertNil(error, "Expected empty but got \(error!) instead")

        self.loadCache(sut: sut, expectedResult: .found(feed: items, cacheInterval: currentDate))
        self.loadCache(sut: sut, expectedResult: .found(feed: items, cacheInterval: currentDate))
    }

    func test_retrieveMethodReturnsErrorWhenThereIsInValidData() {
        let url = testSpecificStoreUrl
        let sut = makeSUT(storeURL: url)
        insertInValidData(inUrl: url)
        loadCache(sut: sut, expectedResult: .failure(anyError))
    }

    func test_retrieveMethodReturnsErrorTwiceWhenThereIsInValidData() {
        let url = testSpecificStoreUrl
        let sut = makeSUT(storeURL: url)
        insertInValidData(inUrl: url)
        loadCache(sut: sut, expectedResult: .failure(anyError))
        loadCache(sut: sut, expectedResult: .failure(anyError))
    }

    func test_insertionOverriodeTheAlreadyInsertedValues() {
        let sut = makeSUT()
        let items = [uniqueItems().1]
        let currentDate = Date()
        let error = save(sut: sut, feed: items, timestamp: currentDate)
        XCTAssertNil(error, "Expected empty but got \(error!) instead")

        let latestDate = Date()
        let latestError = save(sut: sut, feed: items, timestamp: latestDate)
        XCTAssertNil(latestError, "Expected empty but got \(error!) instead")
        self.loadCache(sut: sut, expectedResult: .found(feed: items, cacheInterval: latestDate))

    }

    func test_fileSystemFailWhenInsertedInUnknownDirectory() {
        let url = URL(string: "/path/to/file")
        let sut = makeSUT(storeURL: url)
        let error = save(sut: sut, feed: [uniqueItems().1], timestamp: Date())
        XCTAssertNotNil(error)
    }

    func test_deleteEmptyCacheShouldNotReturnError() {
        let sut = makeSUT()
        let error = delete(sut: sut)
        XCTAssertNotNil(error)

        loadCache(sut: sut, expectedResult: .empty)
    }

    func test_deleteNonEmptyCacheShouldNotReturnError() {
        let sut = makeSUT()
        let saveError = save(sut: sut, feed: [uniqueItems().1], timestamp: Date())
        XCTAssertNil(saveError)

        let error = delete(sut: sut)
        XCTAssertNil(error)

        loadCache(sut: sut, expectedResult: .empty)
    }

    func test_deletetionOnUnknownPathShouldFailWithError() {
        let url = URL(string: "/path/to/file")
        let sut = makeSUT(storeURL: url)
        let error = delete(sut: sut)
        XCTAssertNotNil(error)
    }

    // MARK: Helper Methods
    func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let store = CodableFeedStore(storeURL: storeURL ?? self.testSpecificStoreUrl)
        testMemorLeak(store)
        return store
    }

    func insertInValidData(inUrl url: URL) {
        try? "Invalaid data".write(to: url, atomically: true, encoding: .utf8)
    }

    func save(sut: FeedStore, feed: [LocalFeedItem], timestamp: Date) -> Error? {
        var capturedError: Error?
        let exp = expectation(description: "Wait to save value in file")
        sut.save(feed, cacheDate: timestamp) {error in
            capturedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }

    func delete(sut: FeedStore) -> Error? {
        var capturedError: Error?
        let exp = expectation(description: "Wait to save value in file")
        sut.delete {error in
            capturedError = error
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }

    func loadCache(sut: FeedStore, expectedResult: LoadFeedCacheResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache result")
        sut.loadFeedItem { result in
            switch (result, expectedResult) {
            case (.empty, .empty):
                break
            case (.failure, .failure):
                break

            case let (.found(foundFeed, timeInterval), .found(expectedFeed, expectedTimeInterval)):
                XCTAssertEqual(foundFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(timeInterval, expectedTimeInterval, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult) result but got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func uniqueItems() -> (FeedItem, LocalFeedItem) {
        let feedItem = FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL)
        let localItem = LocalFeedItem(id: feedItem.id, description: feedItem.description, location: feedItem.location, imageURL: feedItem.imageURL)
        return (feedItem, localItem)
    }
}
