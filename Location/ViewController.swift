

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    let httpHelper = HTTPHelper()
    
    @IBOutlet weak var textLabel: UILabel!
    
    lazy var manager: CLLocationManager = {
        var instance = CLLocationManager()
        return instance
        }()
    
    lazy var locationDelegate: LocationDelegate = {
        var instance = LocationDelegate()
        return instance
        }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.manager.delegate = self.locationDelegate // tell the manager its delegate
        self.locationDelegate.registerManager(self.manager) //tell the delegate that this is the manager we are working on
        self.locationDelegate.registerViewController(self)
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.manager.requestAlwaysAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goButton(sender: AnyObject) {
        if CLLocationManager.locationServicesEnabled() {
            println("Location services are enabled")
            self.manager.startUpdatingLocation()
        }
    }
}

