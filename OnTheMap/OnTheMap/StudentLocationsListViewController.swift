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
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StudentLocationsListViewController.handleLogoutButtonAction))
        }
        
        if dataSource.students.count == 0 {
            
            fetchStudents()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueListToPost" {
            
            let controller = segue.destination as! InformationPostingViewController
            
            controller.delegate = self
        }
    }

    internal func handleLogoutButtonAction() {
        
        loading.startAnimating()
        
        Authentication.logout { (complete, errorMessage) -> Void in
            
            self.loading.stopAnimating()
            
            if complete {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleRefreshBarButtonItemAction(_ sender: AnyObject) {
        
        fetchStudents()
    }
    
    fileprivate func fetchStudents() {
        
        loading.startAnimating()
        
        let request = ParseAPI(urlPath: .StudentLocation)
        
        request.urlParameters = [
            "limit": "100" as AnyObject,
            "order": "-updatedAt" as AnyObject
        ]
        
        ConnectionManager().httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let student = dataSource.students[indexPath.row]
        
        cell.textLabel?.text = student.fullName()
        
        cell.detailTextLabel?.text = student.mediaURL
        
        cell.imageView?.image = UIImage(named: "pin")!
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
}


// MARK UITableViewDelegate
extension StudentLocationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let url = dataSource.students[indexPath.row].mediaURL {
        
            UIApplication.shared.openURL(URL(string: url)!)
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

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        handleLogoutButtonAction()
    }
    
}
