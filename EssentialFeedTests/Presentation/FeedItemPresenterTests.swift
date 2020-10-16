//
//  FeedItemPresenterTests.swift
//  EssentialFeedTests
//
//  Created by RN on 11/10/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed



class FeedItemPresenterTests: XCTestCase {
    func init_shouldNotPassAnyMessageToLoader() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.urlList, [])
    }

    func test_loadImage_shouldLoadImage() {
        let imageURL = URL(string: "https://a-image-url.jpeg")!
        let item = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: imageURL)

        let (sut, loader) = makeSUT(item: item)
        sut.loadImage(completion: nil)
        XCTAssertEqual(loader.urlList, [imageURL])
    }
    
    func test_cancelTaskShouldPassCancelMessage() {
        let imageURL = URL(string: "https://a-image-url.jpeg")!
        let item = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: imageURL)

        let (sut, loader) = makeSUT(item: item)
        sut.loadImage(completion: nil)
        sut.cancelTask()
        XCTAssertEqual(loader.messages[0].1.cancelMessageCount, 1)
    }
    
    func test_loadFeedShouldRetuenAssignedFeed() {
        let imageURL = URL(string: "https://a-image-url.jpeg")!
        let item = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: imageURL)

        let (sut, _) = makeSUT(item: item)
        XCTAssertEqual(sut.loadFeed(), item)
    }
    
    func makeSUT(item: FeedItem = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: URL(string: "https://a-image-url.jpeg")!)) -> (FeedItemPresenter, FeedImageLoaderSpy) {
        let imageLoader = FeedImageLoaderSpy()
        let presenter = FeedItemPresenter(feedItem: item, imageLoader: imageLoader)
        return (presenter, imageLoader)
    }
}

class FeedImageLoaderSpy: FeedImageDataLoader {

    var cancelMessageCount: Int = 0

    var urlList: [URL] {
        messages.map( { $0.0 } )
    }
    
    var messages: [(URL, FeedImageDataLoaderTaskSpy)] = []
    
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        let task = FeedImageDataLoaderTaskSpy()
        messages.append((url, task))
        return task
    }
    
    func cancel(at index: Int = 0) {
        messages[index].1.cancel()
        
    }
    
    func cancel() {
           
    }
}

class FeedImageDataLoaderTaskSpy: FeedImageDataLoaderTask {
    
    var cancelMessageCount: Int = 0
    func cancel() {
        cancelMessageCount += 1
    }
}
