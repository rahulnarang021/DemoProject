//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by RAHUL on 17/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
