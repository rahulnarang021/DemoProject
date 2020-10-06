//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by RAHUL on 24/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation

public typealias FeedLoaderResult = Result<[FeedItem], Error>
public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}
