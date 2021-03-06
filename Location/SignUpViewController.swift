//
//  SignUpViewController.swift
//  Location
//
//  Created by Baris Can Vural on 2/22/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    let httpHelper = HTTPHelper()

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBAction func signUpPressed(sender: AnyObject) {
        
        // Code to hide the keyboards for text fields
        if self.nameTextField.isFirstResponder() {
            self.nameTextField.resignFirstResponder()
        }
        
        if self.emailTextField.isFirstResponder() {
            self.emailTextField.resignFirstResponder()
        }
        
        if self.passwordTextField.isFirstResponder() {
            self.passwordTextField.resignFirstResponder()
        }
        
        // start activity indicator
       // self.activityIndicatorView.hidden = false
        
        // validate presence of all required parameters
        if count(self.nameTextField.text) > 0 && count(self.emailTextField.text) > 0
            && count(passwordTextField.text) > 0 {
                makeSignUpRequest(self.nameTextField.text, userEmail: self.emailTextField.text,
                    userPassword: self.passwordTextField.text)
        } else {
            self.displayAlertMessage("Parameters Required", alertDescription:
                "Some of the required parameters are missing")
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func makeSignUpRequest(userName:String, userEmail:String, userPassword:String) {
        // 1. Create HTTP request and set request header
        let httpRequest = httpHelper.buildRequest("signup", method: "POST",
            authType: HTTPRequestAuthType.HTTPBasicAuth)
        
        // 2. Password is encrypted with the API key
        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        
        // 3. Send the request Body
        httpRequest.HTTPBody = "{\"full_name\":\"\(userName)\",\"email\":\"\(userEmail)\",\"password\":\"\(encrypted_password)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // 4. Send the request
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                
                return
            }
            //self.displaSigninView()
            self.displayAlertMessage("Success", alertDescription: "Account has been created")
        })
    }
    
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        // hide activityIndicator view and display alert message
        //self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle as String, message:alertDescription as String, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    override func viewDidLoad() {
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
