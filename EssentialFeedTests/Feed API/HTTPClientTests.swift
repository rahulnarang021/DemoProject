//
//  HTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 31/05/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

class HTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolSpy.startInterceptingRequest()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolSpy.stopInterceptingRequest()
    }

    func test_getFromURL_isCallingTheCorrectURL() {
        let url = anyURL
        URLProtocolSpy.stubRequest(error: anyError)
        URLProtocolSpy.observer = { request in
            XCTAssertEqual(request.url!, url)
        }
        let exp = expectation(description: "Wait for request to be completed")

        makeSUT().get(url: url) {_ in
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let error = anyError
        XCTAssertEqual(error, resultErrorFor(data: nil, response: nil, error: error)! as NSError)
    }

    func test_getFromURL_forInvalidPaths() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyResponse, error: anyError))
    }

    func test_getFromURL_successCase() {
        let data = anyData
        let response = anyResponse
        let values = resultValuesFor(data: data, response: response, error: nil)
        XCTAssertEqual(values!.0, data)
        XCTAssertEqual(values!.1!.statusCode, response.statusCode)
        XCTAssertEqual(values!.1!.url, response.url!)
    }

    // MARK: - Helper Methods
    private func resultErrorFor(data: Data?, response: HTTPURLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolSpy.stubRequest(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for request to be completed")
        var capturedError: Error?
        makeSUT().get(url: anyURL) { result in
            switch result {
            case .failure(let failedError):
                capturedError = failedError
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedError
    }

    private func resultValuesFor(data: Data?, response: HTTPURLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (Data?, HTTPURLResponse?)? {
        URLProtocolSpy.stubRequest(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for request to be completed")
        var capturedValues: (data: Data?, response: HTTPURLResponse?)?
        makeSUT().get(url: anyURL) { result in
            switch result {
            case let .success(data, response):
                capturedValues = (data: data, response: response)

            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return capturedValues
    }

    private func makeSUT() -> HTTPClient {
        return HTTPSessionClient()
    }

    private class URLProtocolSpy: URLProtocol {
        static private var stub: Stub?
        static var observer: ((URLRequest) -> Void)?
        private struct Stub {
            var data: Data?
            var response: HTTPURLResponse?
            var error: Error?
        }

        class func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolSpy.self)
        }

        class func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolSpy.self)
            stub = nil
            observer = nil
        }

        class func stubRequest(data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }


        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = URLProtocolSpy.observer {
                client?.urlProtocolDidFinishLoading(self)
                requestObserver(request)
                return
            }
            if let data = URLProtocolSpy.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolSpy.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolSpy.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}

