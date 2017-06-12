//
//  RideLogCellTableViewCell.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/9/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit
import MapKit

class RideLogCell: UITableViewCell, RideLogCellViewModelDelegate, MKMapViewDelegate {
    
    @IBOutlet var tripLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet var mapViewBottomViewContraint: NSLayoutConstraint! // contraint used for expanding the cell
    
    var mapView:MKMapView? = nil
    
    var viewModel:RideLogCellViewModel! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mapViewBottomViewContraint.isActive = false
    }
    
    override func prepareForReuse() {
        
        // Default the cell to collapse state.
        collapse()
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
    
    /// Expand the cell and create a new mapview
    public func expand() {
        // We create the map view on expand so that we dont have a bunch of hidden mapviews taking up memory.
        mapView = MKMapView()
        if let mapView = mapView {
            mapView.delegate = self
            mapView.isZoomEnabled = false;
            mapView.isScrollEnabled = false;
            mapView.isUserInteractionEnabled = false;
            mapView.translatesAutoresizingMaskIntoConstraints = false
            mapViewContainer.addSubview(mapView)
            mapView.leadingAnchor.constraint(equalTo: mapViewContainer.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: mapViewContainer.trailingAnchor).isActive = true
            mapView.topAnchor.constraint(equalTo: mapViewContainer.topAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: mapViewContainer.bottomAnchor).isActive = true
        }
        
        mapViewBottomViewContraint.isActive = true
        
        update()
    }
    
    /// Collapse the cell and remove the map view.
    public func collapse() {
        mapViewContainer.subviews.first?.removeFromSuperview()
        mapViewBottomViewContraint.isActive = false
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
        
        // Add the path to the mapview
        if let mapView = mapView, let tripPath = viewModel.tripPath {
            mapView.removeOverlays(mapView.overlays)
            mapView.add(tripPath)
            mapView.setVisibleMapRect(tripPath.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: false)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
}
