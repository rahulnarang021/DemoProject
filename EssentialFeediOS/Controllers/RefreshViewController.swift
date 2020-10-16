//
//  RefreshViewController.swift
//  EssentialFeediOS
//
//  Created by rahul.narang on 25/09/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import EssentialFeed

protocol FeedLoadPresenter {
    func load()
}

final class RefreshViewController: NSObject, LoadingView {
    
    var presenter: FeedLoadPresenter?
    
    func notifyLoad(viewModel: FeedViewModel) {
        if viewModel.isLoading {
            self.view.beginRefreshing()
        } else {
            self.view.endRefreshing()
        }
    }
    
    lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
        
    @objc func refresh() {
        self.presenter?.load()
    }
}
