//
//  FeedCacheExtensionHelper.swift
//  EssentialFeedTests
//
//  Created by RAHUL on 29/06/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import EssentialFeed

extension Date {

    func minusCacheExpiry() -> Date {
        return self.addDays(-7)
    }
    
    func addDays(_ days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func addSeconds(_ seconds: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .second, value: seconds, to: self)!
    }
}
