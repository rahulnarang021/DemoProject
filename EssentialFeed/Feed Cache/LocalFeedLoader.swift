//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by RAHUL on 10/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    let store: FeedStore
    var currentDate: () -> Date
    public init(store: FeedStore, date: @escaping () -> Date) {
        self.store = store
        self.currentDate = date
    }
}

extension LocalFeedLoader {
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.delete {[weak self] error in
            guard let `self` = self else { return }
            if let operationError = error {
                completion(operationError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }

    private func cache(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        self.store.save(items.toLocalModels(), cacheDate: self.currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias ResultType = FeedLoaderResult
    public func load(completion: @escaping (ResultType) -> Void) {
         store.loadFeedItem {[weak self] result in
                   guard let self = self else { return }
                   switch result {
                   case .failure(let error):
                       completion(.failure(error))
                   case let .found(feed: localFeed, cacheInterval: timestamp) where FeedCachePolicy.validate(timestamp, currentDate: self.currentDate()):
                       completion(.success(localFeed.toModels()))
                   case .found:
                       completion(.success([]))
                   case .empty:
                       completion(.success([]))
                   }
               }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.loadFeedItem {[weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                self.store.delete { _ in }
            case let .found(feed: _, cacheInterval: timestamp) where !FeedCachePolicy.validate(timestamp, currentDate: self.currentDate()):
                self.store.delete { _ in }
            case .found, .empty:
                break
            }
        }
    }
}

public enum LoadFeedCacheResult {
    case empty
    case found(feed: [LocalFeedItem], cacheInterval: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias OperationCompletionBlock = (Error?) -> Void
    typealias LoadCompletionBlock = (LoadFeedCacheResult) -> Void
    func save(_ items: [LocalFeedItem], cacheDate: Date, completion:  @escaping OperationCompletionBlock)
    func delete(completion: @escaping OperationCompletionBlock)
    func loadFeedItem(completion: @escaping LoadCompletionBlock)
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedItem] {
        return map({ FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)})
    }
}


private extension Array where Element == FeedItem {
    func toLocalModels() -> [LocalFeedItem] {
        return map({ LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)})
    }
}
