//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 08/01/2024.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: NSObject, CellController {
    
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: ImageCommentViewModel
    
    public init(viewModel: ImageCommentViewModel) {
        self.viewModel = viewModel
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.usernameLabel.text = viewModel.username
        cell.dateLabel.text = viewModel.date
        cell.messageLabel.text = viewModel.message
        return cell
    }
    
    public func preload() {}
    
    public func cancelLoad() {}
}
