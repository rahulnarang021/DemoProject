//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

final public class FeedViewController: UIViewController, UITableViewDataSourcePrefetching, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet public var tableView: UITableView!
    
	private var refreshController: RefreshViewController?
    var tableModel = [FeedItemController]() {
        didSet {
            self.tableView.reloadData()
        }
    }

    class func initializeController(refreshController: RefreshViewController) -> FeedViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let controller: FeedViewController = storyboard.instantiateViewController(identifier: String(describing: Self.self)) as! FeedViewController
        controller.refreshController = refreshController
        return controller
    }
    
	public override func viewDidLoad() {
		super.viewDidLoad()
        if let view = refreshController?.view {
            tableView.refreshControl = view
        }
		load()
	}
	
	@objc private func load() {
        refreshController?.refresh()
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellModel = tableModel[indexPath.row]
        return cellModel.view(atIndexpath: indexPath, tableView: tableView)
	}
	
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cancelTask(forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let cellModel = tableModel[indexPath.row]
            cellModel.loadImage()
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelTask)
	}
	
	private func cancelTask(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelTask()
	}
}
