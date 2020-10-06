//
//  HTTPSessionClient.swift
//  EssentialFeed
//
//  Created by RAHUL on 01/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
public class HTTPSessionClient: HTTPClient {
    var session: URLSession
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    private struct UnexpectedError: Error {

    }
    public func get(url: URL, completion:@escaping (HTTPClientResultType) -> Void) {
        session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let unwrappedData = data, let unwrappedResponse = response as? HTTPURLResponse {
                completion(.success(unwrappedData, unwrappedResponse))
            }
            else {
                completion(.failure(UnexpectedError()))
            }
        }.resume()
    }
}
