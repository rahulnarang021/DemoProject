import Foundation
public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol FeedImagePresenterProtocol {
    func loadImage(completion: ((Data?) -> Void)?)
    func loadFeed() -> FeedItem
    func cancelTask()
}

public class FeedItemPresenter: FeedImagePresenterProtocol {
    
    private let feedItem: FeedItem
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?

    public init(feedItem: FeedItem, imageLoader: FeedImageDataLoader) {
        self.feedItem = feedItem
        self.imageLoader = imageLoader
    }
    
    public func loadImage(completion: ((Data?) -> Void)?) {
        self.task = self.imageLoader.loadImageData(from: self.feedItem.imageURL) { result in
            let data = try? result.get()
            completion?(data)
        }
    }
    
    public func cancelTask() {
        task?.cancel()
        task = nil
    }
    
    public func loadFeed() -> FeedItem {
        return feedItem
    }

}
