//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Benny on 2/1/16.
//  Copyright © 2016 Benny Rodriguez. All rights reserved.
//

import UIKit
import MapKit

protocol InformationPostingViewControllerDelegate: class {
    
    func didSuccessFinishPostingLocation(controller withController: InformationPostingViewController)
}

class InformationPostingViewController: TopViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var webLinkTextField: UITextField!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var findSubmitButton: UIButton!
    
    let textViewPlaceholder = "Enter Your Location Here"
    
    let textFieldPlaceholder = "What is your associated link?"
    
    var viewLayoutCurrentStatus: InformationPostStatus = .Find
    
    var selectedPointLocation: CLLocationCoordinate2D!
    
    var updateStudentInfo = false
    
    weak var delegate: InformationPostingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureColorsAndStyles()
        
        configureViewLayoutByStatus(.Find)
        
        if authUser.studentInformation == nil {
            
            loading.startAnimating()
            
            authUser.queryingForLocation({ (success, message) -> Void in
                
                self.loading.stopAnimating()
                
                if success && message == nil {
                    
                    self.configureViewLayoutByStatus(.Find)
                    
                    self.presentAlertView(message: "You can update your information.")
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    fileprivate func configureColorsAndStyles() {
    
        findSubmitButton.layer.cornerRadius = 8.0
        
        findSubmitButton.setTitleColor(.customSteelBlueColor(), for: UIControlState())
        
        topLabel.textColor = .customSteelBlueColor()
        
        bottomLabel.textColor = .customSteelBlueColor()
        
        middleView.backgroundColor = .customSteelBlueColor()
        
        textView.textColor = .customLightGrayColor()
        
        textView.tintColor = .customLightGrayColor()
        
        webLinkTextField.tintColor = .customLightGrayColor()
    }
    
    fileprivate func searchForLocation(_ query: String) {
        
        loading.startAnimating()
        
        CLGeocoder().geocodeAddressString(query.trim()) { (placemarks, error) in
            
            DispatchQueue.main.async(execute: { () -> Void in
            
                self.loading.stopAnimating()
            
                if let placemarks = placemarks, placemarks.count > 0  {
                    
                    let placePin = placemarks[0]
                    
                    let point = MKPointAnnotation()
                
                    point.coordinate = placePin.location!.coordinate
                
                    self.selectedPointLocation = point.coordinate
                
                    self.mapView.addAnnotation(point)
                
                    self.mapView.centerCoordinate = point.coordinate
                
                    self.mapView.selectAnnotation(point, animated: true)
                    
                    self.configureViewLayoutByStatus(.Submit)
                    
                } else if let error = error {
                    
                    self.presentAlertView(withTitle: "Error", message: error.localizedDescription)
                    
                } else {
                    
                    self.presentAlertView(message: "Sorry, unable to find location.")
                }
            })
        }
    }
    
    fileprivate func configureViewLayoutByStatus(_ status: InformationPostStatus) {
        
        viewLayoutCurrentStatus = status
        
        switch status {
            
        case .Find:
            
            cancelButton.setTitleColor(.customDarkBlueColor(), for: UIControlState())
            
            topView.backgroundColor = .customLightGrayColor()
            
            topLabel.text = "Where are you"
            
            webLinkTextField.textColor = .customDarkBlueColor()
            
            webLinkTextField.isEnabled = false
            
            webLinkTextField.text = "studying"
            
            bottomLabel.text = "today?"
            
            mapView.isHidden = true
            
            middleView.isHidden = false
            
            bottomView.backgroundColor = .customLightGrayColor()
            
            if let student = authUser.studentInformation {
                
                textView.text = student.mapString
                
            } else {
            
                textView.text = textViewPlaceholder
            }
            
            findSubmitButton.setTitle("Find on the Map", for: UIControlState())
            
            break
            
        case .Submit:
            
            cancelButton.setTitleColor(.white, for: UIControlState())
            
            topView.backgroundColor = .customSteelBlueColor()
            
            topLabel.text = ""
            
            webLinkTextField.textColor = .white
            
            webLinkTextField.isEnabled = true
            
            webLinkTextField.attributedPlaceholder = NSAttributedString(string: textFieldPlaceholder, attributes:[
                
                NSForegroundColorAttributeName : UIColor.customLightGrayColor()
            ])
            
            if let student = authUser.studentInformation {
                
                webLinkTextField.text = student.mediaURL
                
//                mapView.addAnnotation(student.mapAnnotation)
//                
//                mapView.centerCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude!), longitude: CLLocationDegrees(student.longitude!))
//                
//                mapView.selectAnnotation(student.mapAnnotation, animated: true)
                
                findSubmitButton.setTitle("Update", for: UIControlState())
                
            } else {
                
                webLinkTextField.text = ""
                
                findSubmitButton.setTitle("Submit", for: UIControlState())
            }
            
            bottomLabel.text = ""
            
            mapView.isHidden = false
            
            middleView.isHidden = true
            
            bottomView.backgroundColor = .customWhiteColorWithAlpha(0.3)
            
            break
        }
    }
    
    fileprivate func createStudentInformation(_ completion: @escaping (Bool, String?)->Void) {
        
        let request = ParseAPI(urlPath: .StudentLocation, httpMethod: .POST)
        
        request.json = jsonFromView()
        
        connectionManager.httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if success {
                    
                    if let data = response as? JSON, let objectId = data["objectId"] as? String {
                        
                        if var student = self.authUser.studentInformation {
                            
                            student.objectId = objectId
                            
                        } else {
                            
                            self.authUser.studentInformation = StudentInformation(dictionary: request.json!)
                            
                            self.authUser.studentInformation?.objectId = objectId
                        }
                        
                        completion(true, nil)
                        
                    } else {
                        
                        completion(false, "Sorry, there was a problem reading the result of the request. Please try again.")
                    }
                    
                } else if let message = errorMessage {
                    
                    completion(false, message)
                    
                } else {
                    
                    completion(false, "Sorry, something went wrong.")
                }
            })
        })
    }
    
    fileprivate func updateStudentInformation(_ completion: @escaping (Bool, String?)->Void) {
        
        let request = ParseAPI(urlPath: .StudentLocation, nextValuesForPath: [authUser.studentInformation!.objectId : .None], httpMethod: .PUT)
        
        request.json = jsonFromView()
        
        connectionManager.httpRequest(requestAPI: request, completion: { (response, success, errorMessage) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if success {
                    
                    /* {
                    "updatedAt":"2015-03-11T02:56:49.997Z"
                    } */
                    
                    if let data = response as? JSON, let _ = data["updatedAt"] as? String {
                        
                        completion(true, nil)
                        
                    } else {
                        
                        completion(false, "Sorry, there was a problem reading the result of the request. Please try again.")
                    }
                    
                } else if let message = errorMessage {
                    
                    completion(false, message)
                    
                } else {
                    
                    completion(false, "Sorry, something went wrong.")
                }
            })
        })
    }
    
    fileprivate func jsonFromView() -> NSDictionary {
        
        return [
            "uniqueKey": (authUser.accountKey != nil ? authUser.accountKey : "")!,
            "firstName": (authUser.firstName != nil ? authUser.firstName : "")!,
            "lastName": (authUser.lastName != nil ? authUser.lastName : "")!,
            "mapString": textView.text.trim(),
            "mediaURL": (webLinkTextField.text != nil ? webLinkTextField.text?.trim() : "")!,
            "latitude": Float(selectedPointLocation.latitude),
            "longitude": Float(selectedPointLocation.longitude)
        ]
    }

    @IBAction func handleCancelButtonAction(_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleFindSubmitButtonAction(_ sender: AnyObject) {
        
        switch viewLayoutCurrentStatus {
            
        case .Find:
            
            let location = textView.text.trim()
            
            if location == "" || location == textViewPlaceholder {
                
                presentAlertView(message: "Must Enter a Location.")
                
            } else {
                
                searchForLocation(textView.text)
            }
            
            break
            
        case .Submit:
            
            let link = webLinkTextField.text?.trim()
            
            if link == "" || link == textFieldPlaceholder {
                
                presentAlertView(message: "Must Enter a Link.")
                
            } else if let _ = authUser.studentInformation {
                
                updateStudentInformation({ (complete, errorMessage) -> Void in
                    
                    if complete {
                        
                        self.dismiss(animated: true, completion: { () -> Void in
                            
                            self.delegate?.didSuccessFinishPostingLocation(controller: self)
                        })
                        
                    } else if let message = errorMessage {
                        
                        self.presentAlertView(withTitle: "Error", message: message)
                        
                    } else {
                        
                        self.presentAlertView(message: "Sorry, there was a problem updating your location. Please try again.")
                        
                        self.configureViewLayoutByStatus(.Find)
                    }
                })
                
            } else {
                
                createStudentInformation({ (complete, errorMessage) -> Void in
                    
                    if complete {
                        
                        self.dismiss(animated: true, completion: { () -> Void in
                            
                            self.delegate?.didSuccessFinishPostingLocation(controller: self)
                        })
                        
                    } else if let message = errorMessage {
                        
                        self.presentAlertView(withTitle: "Error", message: message)
                        
                    } else {
                        
                        self.presentAlertView(message: "Sorry, there was a problem saving the location. Please try again.")
                        
                        self.configureViewLayoutByStatus(.Find)
                    }
                })
            }
            
            break
        }
    }
}

// MARK: UITextViewDelegate
extension InformationPostingViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == "") {
            
            textView.text = textViewPlaceholder
            
            textView.textColor = .customLightGrayColor()
        }
        
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if (textView.text == textViewPlaceholder) {
            
            textView.text = ""
            
            textView.textColor = .white
        }
        
        textView.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
}

// MARK: UITextFieldDelegate
extension InformationPostingViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.text == "" {
        
            textField.placeholder = nil
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == "" {
            
            textField.placeholder = textFieldPlaceholder
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
}

