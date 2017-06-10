//
//  RideLogCellTableViewCell.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit

class RideLogCell: UITableViewCell, RideLogCellViewModelDelegate {
    
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
//    var viewModel:RideLogCellViewModel!
    var viewModel:RideLogCellViewModel! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureWithViewModel(viewModel:RideLogCellViewModel) {
        self.viewModel = viewModel
        tripLabel.text = "Trip Started"
        update()
    }
    
    // MARK: - RideLogCellViewModelDelegate
    
    func update() {
        if let startAddress = viewModel.startAddress {
            tripLabel.text = startAddress + " › " + (viewModel.endAddress ?? "")
        } else {
            // Assuming here that a this cell exist because a trip started... Could just store this in the storyboard as a default value but I like seeing the example in the storyboard
            tripLabel.text = "Trip Started"
        }
        
        if let startTime = viewModel.startTime {
            timeLabel.text = startTime + " - " + (viewModel.endTime ?? "")
        }        
    }
}
