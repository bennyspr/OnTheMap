//
//  StudentLocationsListViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit

class StudentLocationsListViewController: TopViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = StudentsData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if dataSource.students.count == 0 {
            
            fetchStudents()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueListToPost" {
            
            let controller = segue.destinationViewController as! InformationPostingViewController
            
            controller.delegate = self
        }
    }

    @IBAction func handleLogoutButtonAction(sender: AnyObject) {
        
        loading.startAnimating()
        
        Authentication.logout { (complete, errorMessage) -> Void in
            
            self.loading.stopAnimating()
            
            if complete {
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func handleRefreshBarButtonItemAction(sender: AnyObject) {
        
        fetchStudents()
    }
    
    private func fetchStudents() {
        
        loading.startAnimating()
        
        dataSource.fetchStudents { (finish, errorMessage) -> Void in
            
            self.loading.stopAnimating()
            
            if finish {
                
                self.tableView.reloadData()
            }
        }
    }
}

// MARK UITableViewDataSource
extension StudentLocationsListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let student = dataSource.students[indexPath.row]
        
        cell.textLabel?.text = student.fullName()
        
        cell.detailTextLabel?.text = student.mediaURL
        
        cell.imageView?.image = UIImage(named: "pin")!
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
}


// MARK UITableViewDelegate
extension StudentLocationsListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let url = dataSource.students[indexPath.row].mediaURL {
        
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        }
    }
}

// MARK InformationPostingViewControllerDelegate
extension StudentLocationsListViewController: InformationPostingViewControllerDelegate {
    
    func didSuccessFinishPostingLocation(controller withController: InformationPostingViewController) {
        
        fetchStudents()
    }
}
