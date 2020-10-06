//
//  Helper.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 09/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest

extension XCTestCase {

    var anyData: Data {
        return Data(count: 10)
    }
    
    var anyURL: URL {
        return URL(string: "http://a-given-url")!
    }

    var anyResponse: HTTPURLResponse {
        return HTTPURLResponse(url: anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    var anyError: NSError {
        return NSError(domain: "SomeError", code: 1, userInfo: nil)
    }

    func testMemorLeak(_ sut: AnyObject?, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak sut] in
            XCTAssertNil(sut, "This variable is creating a retain cycle", file: file, line: line)
        }
    }
}
