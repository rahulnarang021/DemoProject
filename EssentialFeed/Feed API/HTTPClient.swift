//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by RAHUL on 27/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation

public enum HTTPClientResultType {
    case success(Data?, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(url: URL, completion:@escaping (HTTPClientResultType) -> Void)
}
