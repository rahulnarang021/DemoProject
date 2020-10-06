//
//  FeedItemController.swift
//  EssentialFeediOS
//
//  Created by rahul.narang on 25/09/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit


final class FeedItemController {
    
    private let feedImagePresenter: FeedImagePresenterProtocol
    
    var cell: FeedImageCell?
    init(feedImagePresenter: FeedImagePresenterProtocol) {
        self.feedImagePresenter = feedImagePresenter
    }
    
    func view(atIndexpath indexPath: IndexPath, tableView: UITableView) -> FeedImageCell {
        cell = tableView.dequeueReusableCell()
        let feedItem = feedImagePresenter.loadFeed()
        cell?.locationContainer.isHidden = (feedItem.location == nil)
        cell?.locationLabel.text = feedItem.location
        cell?.descriptionLabel.text = feedItem.description
        cell?.feedImageView.image = nil
        cell?.feedImageRetryButton.isHidden = true
        cell?.feedImageContainer.startShimmering()
        
        let loadImage = { [weak self] in
            guard let self = self else { return }
            self.feedImagePresenter.loadImage {[weak self] data in
                guard let self = self else { return }
                if let imageData: Data = data {
                    let image = UIImage(data: imageData) ?? nil
                    self.cell?.feedImageView.displayImageWithAnimation(image: image)
                }
                self.cell?.feedImageRetryButton.isHidden = (self.cell?.feedImageView.image != nil)
                self.cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cell?.onRetry = loadImage
        loadImage()
        return cell!
    }
    
    func loadImage() {
        feedImagePresenter.loadImage(completion: nil)
    }
    
    func cancelTask() {
        releaseCellForReuse()
        feedImagePresenter.cancelTask()
    }

    func releaseCellForReuse() {
        cell = nil
    }
}

