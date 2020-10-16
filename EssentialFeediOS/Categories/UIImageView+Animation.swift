//
//  UIImageView+Animation.swift
//  EssentialFeediOS
//
//  Created by RN on 02/10/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import UIKit

extension UIImageView {
    func displayImageWithAnimation(image: UIImage?) {
        self.image = image
        guard image != nil else { return }
        self.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}

