//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by RAHUL on 25/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation

public typealias LoadFeedResult = (FeedLoaderResult) -> Void
public final class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public typealias ResultType = FeedLoaderResult
    public enum Error: Swift.Error, Equatable {
        case noConnectivity
        case invalidData
    }

    public func load(completion: @escaping LoadFeedResult) {
        client.get(url: url) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let data, let response):
                do {
                    let items = try FeedItemParser.parseData(data, response)
                    completion(.success(items.toModels()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(_):
                completion(.failure(Error.noConnectivity))
            }
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map({ FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)})
    }
}
