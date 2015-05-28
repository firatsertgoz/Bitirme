
import UIKit

class LogInViewController: UIViewController {
    
    let httpHelper = HTTPHelper()
    var courseDict:NSDictionary = NSDictionary()
    var jsonData : JSON?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed(sender: AnyObject) {
      
//        var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hide"), userInfo: nil, repeats: false)
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
        if count(self.emailTextField.text) > 0 &&
            count(self.passwordTextField.text) > 0 {
                  SwiftSpinner.show("Logging in", animated: true)
                makeSignInRequest(self.emailTextField.text, userPassword: self.passwordTextField.text)
        } else {
            SwiftSpinner.show("Some of the required parameters are missing", animated: false)
            var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hide"), userInfo: nil, repeats: false)
        }
    }
    
    func hide()
    {
        SwiftSpinner.hide()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = "Login"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let email =  KeychainAccess.passwordForAccount("email", service: "KeyChainService")
        let password = KeychainAccess.passwordForAccount("password", service: "KeyChainService")
        let auth_token = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService")
        
        if (email != nil && password != nil && auth_token != nil) {
            SwiftSpinner.show("Logging in", animated: true)
            makeSignInRequest(email!, userPassword: password!)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "su.jpg")!)
        self.passwordTextField.secureTextEntry = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCourseEntities() {
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("get_course_entities", method: "GET",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding);
        
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                //self.displayAlertMessage("Error", alertDescription: errorMessage)
                SwiftSpinner.show( errorMessage as String, animated: false)
                var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hide"), userInfo: nil, repeats: false)
                return
            }
            
            // save email and password in Keychain
            //save json to pass it to the next controller
            var jsonData = JSON(data:data)
            
            NSUserDefaults.standardUserDefaults().setObject(jsonData.object, forKey: "Schedule")
            println(jsonData)
            if(NSUserDefaults.standardUserDefaults().objectForKey("Schedule")==nil){
                println("it's nil")
            }
            
            var json = JSON(NSUserDefaults.standardUserDefaults().objectForKey("Schedule") as! NSArray)
            println(json)
        })
    }

    func makeSignInRequest(userEmail:String, userPassword:String) {
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest("signin", method: "POST",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        
        httpRequest.HTTPBody = "{\"email\":\"\(userEmail)\",\"password\":\"\(encrypted_password)\"}".dataUsingEncoding(NSUTF8StringEncoding);
        
        httpHelper.sendRequest(httpRequest, completion: {(data:NSData!, error:NSError!) in
            // Display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                //self.displayAlertMessage("Error", alertDescription: errorMessage)
                
                SwiftSpinner.show( errorMessage as String, animated: false)
                var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("hide"), userInfo: nil, repeats: false)
                return
            }
            var jsonerror:NSError?
            let responseDict = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments, error:&jsonerror) as! NSDictionary
            var stopBool : Bool
            
            // save API AuthToken and ExpiryDate in Keychain
            self.saveApiTokenInKeychain(responseDict)
            // save email and password in Keychain
            KeychainAccess.setPassword(userPassword, account: "password",service: "KeyChainService")
            KeychainAccess.setPassword(userEmail, account: "email",service: "KeyChainService")
            //save json to pass it to the next controller
            self.jsonData = JSON(data:data) 
            self.toTheNextView()
        })
    }
    
    func saveApiTokenInKeychain(tokenDict:NSDictionary) {
        // Store API AuthToken and AuthToken expiry date in KeyChain
        tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
            var myKey = dictKey.description
            var myObj = dictObj.description
            
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
        let errorAlert = UIAlertView(title:alertTitle as String, message:alertDescription as String, delegate:nil, cancelButtonTitle:"OK")
        errorAlert.show()
    }
    
    func toTheNextView(){
        
        getCourseEntities()
        
        if(self.jsonData!["student"]) {
        //init blesh
        Blesh.sharedInstance().initBleshWithAPIUser(
            "firat.sertgoz",
            APIKey: "Un6e27sSj2",
            integrationType: "M",
            integrationId: self.jsonData!["api_authtoken"].string,
            pushToken: "Push Notification Token",
            optionalKey: "Optional Key"
        )
     
        Blesh.sharedInstance().didCloseCampaignView =
            { (NSString valueType, NSString value) -> Void in
                println("Campaign closed")
                let parsed:[NSString] = value.componentsSeparatedByString(":")
                Attendance.registerBeaconInfo(parsed[0] as String,count:parsed[1].integerValue)
            }
        }
        
        //check whether the user is a student or an instructor
        if (self.jsonData!["instructor"]){
            //instructor UI
            let navController = self.navigationController as! CustomNavigationController
            navController.DashboardViewController_receivedJSON = self.jsonData!
            self.navigationController?.performSegueWithIdentifier("LoginToDashboard", sender: self)
        }
        
        else if (self.jsonData!["student"]){
            //student UI
            let navController = self.navigationController as! CustomNavigationController
            navController.CourseListViewController_receivedJSON = self.jsonData!
            self.navigationController?.performSegueWithIdentifier("LoginToCourseList", sender: self)
        }
    }
}
