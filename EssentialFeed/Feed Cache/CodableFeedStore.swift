//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by RAHUL on 03/07/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
public class CodableFeedStore: FeedStore {

    private struct CodableFeedItem: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let imageURL: URL

        var local: LocalFeedItem {
            return LocalFeedItem(id: id, description: description, location: location, imageURL: imageURL)
        }

        init(_ localFeed: LocalFeedItem) {
            self.id = localFeed.id
            self.description = localFeed.description
            self.location = localFeed.location
            self.imageURL = localFeed.imageURL
        }
    }
    private struct CodableFeedTime: Codable {
        let feedItem: [CodableFeedItem]
        let cacheTime: Date
    }

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    public func loadFeedItem(completion: @escaping LoadCompletionBlock) {
        queue.async {
            guard let data = try? Data(contentsOf: self.storeURL) else {
                completion(.empty)
                return
            }
            let decoder = JSONDecoder()
            do {
                let object = try decoder.decode(CodableFeedTime.self, from: data)
                completion(.found(feed: object.feedItem.map({ $0.local }), cacheInterval: object.cacheTime))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func save(_ items: [LocalFeedItem], cacheDate: Date, completion:  @escaping OperationCompletionBlock) {
        queue.async {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(CodableFeedTime(feedItem: items.map({ CodableFeedItem($0) }), cacheTime: cacheDate))
            do {
                try data.write(to: self.storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func delete(completion: @escaping OperationCompletionBlock) {
        queue.async {
            do {
                try FileManager.default.removeItem(at: self.storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
