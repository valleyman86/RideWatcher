//
//  ViewController.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/5/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit

class RideLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RideLogViewModelDelegate {

    @IBOutlet var logSwitch: UISwitch!
    @IBOutlet var tableView: UITableView!
    
    private var expandedIndexPath:IndexPath?
    private var settingButtonClicked = false
    private var authorizingLogger = false
    
    var viewModel:RideLogViewModel! {
        didSet {
            // We should only set the viewModels delegate once this view is ready to go.
            viewModel.viewDelegate = isViewLoaded ? self : nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the navbar image as the title. TODO: Maybe add support for this in the storyboard
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar"))
        
        // Observe for when app comes from background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        viewModel.viewDelegate = self
        
        // Rows should expand when clicked
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func logSwitchValueChanged(_ sender: UISwitch) {
        if (sender.isOn) {
            authorizingLogger = true
            viewModel.startLogging { (error:RideLogLogError?) in
                self.authorizingLogger = false
                if (error != nil) {
                    // If there is an error starting due to authorization issues we should let the user know
                    // these should be enabled.
                    let alertController = UIAlertController(
                        title: "Background Location Access Disabled",
                        message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
                        preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
                        self.logSwitch.isOn = false
                    })
                    
                    alertController.addAction(cancelAction)
                    
                    let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                        if let url = URL(string:UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.open(url) { (test:Bool) in
                                self.settingButtonClicked = true
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            viewModel.stopLogging()
        }
    }
    
    func applicationDidBecomeActive() {
        // Set the state of the toggle switch if something changed (privacy settings) in the background.
        
        if (settingButtonClicked) {
            viewModel.startLogging { (error:RideLogLogError?) in
                self.logSwitch.isOn = self.viewModel.isLoggingActive
                self.settingButtonClicked = false
            }
        } else if (!authorizingLogger) {
            // Lets set the switch if the state of logging as changed since we were away.
            logSwitch.isOn = viewModel.isLoggingActive
        }
    }
    
    // MARK: - RideLogViewModelDelegate
    
    func viewModelWillChangeContent(_ viewModel: RideLogViewModel) {
        debugPrint("UITableView:beginUpdates");
        tableView.beginUpdates()
    }
    
    func viewModel(_ viewModel: RideLogViewModel, didChange anObject: Any, at indexPath: IndexPath?, for type: RideLogChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                if let expandedIndexPath = expandedIndexPath, expandedIndexPath >= newIndexPath {
                    self.expandedIndexPath = IndexPath(row: expandedIndexPath.row + 1, section: expandedIndexPath.section)
                }
                
                debugPrint("UITableView:insertRows %@", newIndexPath)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                debugPrint("UITableView:reloadRows %@", indexPath)
                if let cell = tableView.cellForRow(at: indexPath) as? RideLogCell, let cellViewModel = viewModel.viewModelForIndexPath(indexPath) {
                    cell.configureWithViewModel(viewModel: cellViewModel)
                }
            }
        case .delete:
            if let indexPath = indexPath {
                if let expandedIndexPath = expandedIndexPath, expandedIndexPath > indexPath {
                    if (expandedIndexPath > indexPath) {
                        self.expandedIndexPath = IndexPath(row: expandedIndexPath.row - 1, section: expandedIndexPath.section)
                    } else if (expandedIndexPath == indexPath) {
                        self.expandedIndexPath = nil
                    }
                }
                
                debugPrint("UITableView:deleteRows %@", indexPath)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.expandedIndexPath = nil
                
                debugPrint("UITableView:deleteRows %@", indexPath)
                debugPrint("UITableView:moveRows %@", newIndexPath)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
    func viewModelDidChangeContent(_ viewModel: RideLogViewModel) {
        debugPrint("UITableView:endUpdates");
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RideLogCell", for: indexPath) as? RideLogCell {
            
            // Configure the cell...
            
            if let cellViewModel = viewModel.viewModelForIndexPath(indexPath) {
                cell.configureWithViewModel(viewModel: cellViewModel)
                if let expandedIndexPath = expandedIndexPath, expandedIndexPath == indexPath {
                    cell.expand()
                }
            }
            
            return cell
        }
        
        fatalError("RideLogCell can't be found.")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // We have to do set the expanded indexPath here and reload the cell because we are expecting the height to change.
        if let expandedIndexPath = expandedIndexPath, expandedIndexPath == indexPath {
            self.expandedIndexPath = nil // Collapse
            tableView.reloadRows(at: [expandedIndexPath], with: .fade)
        } else {
            if let expandedIndexPath = expandedIndexPath {
                self.expandedIndexPath = nil // Collapse
                tableView.reloadRows(at: [expandedIndexPath], with: .fade)
            }
            
            expandedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    
     // MARK: - Navigation
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
 
}

