//
//  StudentLocationsListViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class StudentLocationsListViewController: TopViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if  authUser.fbAccessToken != nil {
            
            let fbLogoutButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 80, height: 24))
            
            fbLogoutButton.delegate = self
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fbLogoutButton)
            
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "handleLogoutButtonAction")
        }
        
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

    internal func handleLogoutButtonAction() {
        
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
        
        let request = ParseAPI(urlPath: .StudentLocation)
        
        request.urlParameters = [
            "limit": "100",
            "order": "-updatedAt"
        ]
        
        ConnectionManager().httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.loading.stopAnimating()
                
                if success {
                    
                    if let data = response as? JSON, let results = data["results"] as? JSONArray {
                        
                        self.dataSource.students = []
                        
                        if results.count > 0 {
                            
                            for data in results {
                                
                                self.dataSource.students.append(StudentInformation(dictionary: data))
                            }
                        }
                        
                        self.tableView.reloadData()
                        
                    } else {
                        
                        self.presentAlertView(message: "Sorry, there was a problem reading the result of the request. Please try again.")
                    }
                    
                } else if let message = errorMessage {
                    
                    self.presentAlertView(withTitle: "Error Message", message: message)
                    
                } else {
                    
                    self.presentAlertView(message: "Sorry, something went wrong.")
                }
            })
        })
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

// MARK: FBSDKLoginButtonDelegate
extension StudentLocationsListViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        handleLogoutButtonAction()
    }
    
}
