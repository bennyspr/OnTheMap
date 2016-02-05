//
//  StudentLocationsMapViewController.swift
//  OnTheMap
//
//  Created by Benny on 1/10/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationsMapViewController: TopViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var dataSource = StudentsData.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchStudents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueMapToPost" {
            
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
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                var annotations = [MKPointAnnotation]()
                
                for var student in self.dataSource.students {
                    
                    annotations.append(student.mapAnnotation)
                }
                
                self.mapView.addAnnotations(annotations)
            }
        }
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


