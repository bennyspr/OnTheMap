//
//  StudentLocationsMapViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class StudentLocationsMapViewController: TopViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  authUser.fbAccessToken != nil {
            
            let fbLogoutButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 80, height: 24))
            
            fbLogoutButton.delegate = self
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: fbLogoutButton)
            
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StudentLocationsMapViewController.handleLogoutButtonAction))
        }
        
        fetchStudents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueMapToPost" {
            
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
                        
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        
                        var annotations = [MKPointAnnotation]()
                        
                        for var student in self.dataSource.students {
                            
                            annotations.append(student.mapAnnotation)
                        }
                        
                        self.mapView.addAnnotations(annotations)
                        
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

// MARK: MKMapViewDelegate
extension StudentLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle! {
                
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
}

// MARK InformationPostingViewControllerDelegate
extension StudentLocationsMapViewController: InformationPostingViewControllerDelegate {
    
    func didSuccessFinishPostingLocation(controller withController: InformationPostingViewController) {
        
        fetchStudents()
    }
}

// MARK: FBSDKLoginButtonDelegate
extension StudentLocationsMapViewController: FBSDKLoginButtonDelegate {
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        handleLogoutButtonAction()
    }
    
}


