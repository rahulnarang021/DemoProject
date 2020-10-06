//
//  FeedItemParser.swift
//  EssentialFeed
//
//  Created by RAHUL on 27/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
final class FeedItemParser {
    class func parseData(_ data: Data?, _ response: HTTPURLResponse) throws -> [RemoteFeedItem]  {
        guard let data = data, response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        do {
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.items
        } catch {
            throw RemoteFeedLoader.Error.invalidData
        }
    }

    private struct Root: Decodable  {
        let items: [RemoteFeedItem]
    }
}
