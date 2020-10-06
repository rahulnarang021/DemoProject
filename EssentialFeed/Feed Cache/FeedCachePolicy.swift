//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by RAHUL on 29/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation

struct FeedCachePolicy {

    static private let calendar = Calendar(identifier: .gregorian)
    static private var maxCacheAgeInDays: Int {
        return -7
    }

    static func validate(_ timestamp: Date, currentDate: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: currentDate) else {
            return false
        }
        return maxCacheAge <= timestamp
    }
}
