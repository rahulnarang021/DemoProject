//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 25/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_requestedURLIsNotEmpty() {
        let sut = makeSUT()
        sut.remotedFeedLoader.load {_ in }
        XCTAssertFalse(sut.client.requestedURLs.isEmpty)
    }

    func test_requestedURLIsCorrect() {
        let client = HTTPClientSpy()
        let url: URL = URL(string: "https://dummy-url")!
        let sut = makeSUT(url: url, client: client)
        sut.remotedFeedLoader.load {_ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_requestedURLIsLoadedTwice() {
        let client = HTTPClientSpy()
        let url: URL = URL(string: "https://dummy-url")!
        let sut = makeSUT(url: url, client: client)
        sut.remotedFeedLoader.load {_ in }
        sut.remotedFeedLoader.load {_ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadWithNoConnectivityError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.noConnectivity), onAction: {
            let error = NSError(domain: "Dummy Error", code: 0, userInfo: nil)
            client.complete(withError: error)
        })
    }

    func test_loadWithHTTPStatusCodeNot200() {
        let (sut, client) = makeSUT()
        let sample = [199, 201, 300, 400, 500]
        sample.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData), onAction: {
                client.complete(withStatusCode: code, atIndex: index)
            })
        }
    }

    func test_loadDataWith200StatusCodeAndInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData), onAction: {
            let invalidJSON = Data(count: 10)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_loadDataWith200StatusCodeAndEmptyItems() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([]), onAction: {
            let emptyList: [String: Any] = ["items": []]
            let data = try! JSONSerialization.data(withJSONObject: emptyList, options: .prettyPrinted)
            client.complete(withStatusCode: 200, data: data)
        })
    }

    func test_loadDataWith200StatusCodeAndNonEmptyValidItems() {
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-image-url.jpeg")!)
        let item2 = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: URL(string: "https://a-image-url.jpeg")!)
        let item3 = FeedItem(id: UUID(), description: nil, location: "a location", imageURL: URL(string: "https://a-image-url.jpeg")!)
        let item4 = FeedItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://a-image-url.jpeg")!)

        let item1Dict: [String: Any?] = ["id": item1.id.uuidString, "image": item1.imageURL.absoluteString]
        let item2Dict: [String: Any?] = ["id": item2.id.uuidString, "description": item2.description, "image": item2.imageURL.absoluteString]
        let item3Dict: [String: Any?] = ["id": item3.id.uuidString, "location": item3.location, "image": item3.imageURL.absoluteString]
        let item4Dict: [String: Any?] = ["id": item4.id.uuidString, "description": item4.description, "location": item4.location, "image": item4.imageURL.absoluteString]

        let rootDict = ["items": [item1Dict, item2Dict, item3Dict, item4Dict]]
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([item1, item2, item3, item4]), onAction: {
            let data = try! JSONSerialization.data(withJSONObject: rootDict, options: .prettyPrinted)
            client.complete(withStatusCode: 200, data: data)
        })
    }

    func test_remoteFeedLoaderDoesnotInvokeBlockAfterDeallocation() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "https://a-dummy-url")!, client: client)
        var captureResult: [RemoteFeedLoader.ResultType] = []
        sut?.load(completion: { captureResult.append($0) })
        sut = nil
        client.complete(withStatusCode: 200)
        XCTAssertTrue(captureResult.isEmpty)
    }

    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://dummy-url")!, client: HTTPClientSpy = HTTPClientSpy()) -> (remotedFeedLoader: RemoteFeedLoader, client: HTTPClientSpy) {
        let sut = RemoteFeedLoader(url: url, client: client)
        testMemorLeak(sut)
        testMemorLeak(client)
        return (remotedFeedLoader: sut, client: client)
    }

    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.ResultType, onAction action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        sut.load {[expectedResult] receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError)
            default:
                XCTFail("Results are mismatched")
            }
        }
        action()
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            captureList.map { $0.url }
        }

        var captureList: [(url: URL, completion: (HTTPClientResultType) -> Void)] = []

        func get(url: URL, completion:@escaping (HTTPClientResultType) -> Void) {
            let message = (url, completion)
            captureList.append(message)
        }

        func complete(withError error: Error, atIndex index: Int = 0) {
            captureList[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), atIndex index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            captureList[index].completion(.success(data, response))
        }
    }

}
