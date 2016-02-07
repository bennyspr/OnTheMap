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
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "handleLogoutButtonAction")
        }
        
        fetchStudents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueMapToPost" {
            
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        } else {
            
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            let app = UIApplication.sharedApplication()
            
            if let toOpen = view.annotation?.subtitle! {
                
                app.openURL(NSURL(string: toOpen)!)
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
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
        handleLogoutButtonAction()
    }
    
}


