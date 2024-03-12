//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 08/01/2024.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject {
    
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: ImageCommentViewModel
    
    public init(viewModel: ImageCommentViewModel) {
        self.viewModel = viewModel
    }
}

extension ImageCommentCellController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = viewModel.username
        cell.dateLabel.text = viewModel.date
        cell.messageLabel.text = viewModel.message
        return cell
    }
}
