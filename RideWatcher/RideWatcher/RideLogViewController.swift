//
//  ViewController.swift
//  RideWatcher
//
//  Created by Joseph Gentry on 6/5/17.
//  Copyright © 2017 Joseph Gentry. All rights reserved.
//

import UIKit

class RideLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RideLogViewModelDelegate {

    @IBOutlet weak var logSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    // I kind of want the app to crash if this doesn't exist.
    var viewModel:RideLogViewModel! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add the navbar image as the title. TODO: Maybe add support for this in the storyboard
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navbar"))

//        gpsTracker.stopTimeThreshold = 5
//        gpsTracker.startTracker { (error:LocationDispatcher.AuthorizationError?) in
//            if (error != nil) {
//                print(error)
//            }
//        }
        viewModel.startLogging()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - RideLogViewModelDelegate
    
    func update() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RideLogCell", for: indexPath) as! RideLogCell
        
        // Configure the cell...
        
        if let cellViewModel = viewModel.viewModelForIndexPath(indexPath) {
            cell.configureWithViewModel(viewModel: cellViewModel)
        }
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
 
}

