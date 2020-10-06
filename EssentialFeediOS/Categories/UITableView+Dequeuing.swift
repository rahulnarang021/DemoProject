//
//  UITableView+Dequeuing.swift
//  EssentialFeediOS
//
//  Created by RN on 02/10/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        return self.dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
    }
}
