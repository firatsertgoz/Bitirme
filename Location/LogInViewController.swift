

import UIKit


class LogInViewController: UIViewController {
    
    let httpHelper = HTTPHelper()
    var courseDict:NSDictionary = NSDictionary()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    
    @IBOutlet weak var passwordTextField: UITextField!

    
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        // resign the keyboard for text fields
        if self.emailTextField.isFirstResponder() {
            self.emailTextField.resignFirstResponder()
        }
        
        if self.passwordTextField.isFirstResponder() {
            self.passwordTextField.resignFirstResponder()
        }
        
        // display activity indicator
        //self.activityIndicatorView.hidden = false
        
        // validate presense of required parameters
        if countElements(self.emailTextField.text) > 0 &&
            countElements(self.passwordTextField.text) > 0 {
                makeSignInRequest(self.emailTextField.text, userPassword: self.passwordTextField.text)
        } else {
            self.displayAlertMessage("Parameters Required",
                alertDescription: "Some of the required parameters are missing")
        }
        
        
        
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        passwordTextField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        

    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func makeSignInRequest(userEmail:String, userPassword:String) {
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("signin", method: "POST",
            authType: HTTPRequestAuthType.HTTPBasicAuth)
        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        
        httpRequest.HTTPBody = "{\"email\":\"\(self.emailTextField.text)\",\"password\":\"\(encrypted_password)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                self.displayAlertMessage("Error", alertDescription: errorMessage)
                
                return
            }
            
            // hide activity indicator and update userLoggedInFlag
           // self.activityIndicatorView.hidden = true
           // self.updateUserLoggedInFlag()
            
            var jsonerror:NSError?
            let responseDict = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as NSDictionary
            var stopBool : Bool
            
            // save API AuthToken and ExpiryDate in Keychain
            self.saveApiTokenInKeychain(responseDict)
            self.segueToCourseListViewController()
        })
    }
    
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
        // Store API AuthToken and AuthToken expiry date in KeyChain
        tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
            var myKey = dictKey.description
            var myObj = dictObj.description
            println(myKey+" "+myObj)
            if myKey == "api_authtoken" {
                KeychainAccess.setPassword(myObj, account: "Auth_Token", service: "KeyChainService")
            }
            
            if myKey == "authtoken_expiry" {
                KeychainAccess.setPassword(myObj, account: "Auth_Token_Expiry", service: "KeyChainService")
            }
        })
    }
    
    func displayAlertMessage(alertTitle:NSString, alertDescription:NSString) -> Void {
        // hide activityIndicator view and display alert message
        //self.activityIndicatorView.hidden = true
        let errorAlert = UIAlertView(title:alertTitle, message:alertDescription, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
        func segueToCourseListViewController()
    {
        let afterLogin = self.storyboard?.instantiateViewControllerWithIdentifier("afterLogin") as CourseListViewController
        self.navigationController!.pushViewController(afterLogin, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
