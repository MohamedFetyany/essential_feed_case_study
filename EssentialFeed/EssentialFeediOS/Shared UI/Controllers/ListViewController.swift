//
//  ListViewController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 03/04/2023.
//

import UIKit
import EssentialFeed

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

public extension CellController {
    func preload() {}
    func cancelLoad() {}
}

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
    
    private var loadingController = [IndexPath: CellController]()
    
    private var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
    private var onViewIsAppearing: ((ListViewController) -> Void)?
        
    public var onRefresh: (() -> Void)?
    
    @IBOutlet private(set) public var errorView: ErrorView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ cellControllers:[CellController]) {
        loadingController = [:]
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefrehing: viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(for: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(for: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(for: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }
    
    private func cellController(for indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingController[indexPath] = controller
        return controller
    }
    
    private func cancelCellController(for indexPath: IndexPath) {
        loadingController[indexPath]?.cancelLoad()
        loadingController[indexPath] = nil
    }
}

