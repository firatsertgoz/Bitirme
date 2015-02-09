

import UIKit
import CoreLocation


class ViewController: UIViewController {
    
    //region coordinates knwon
    //1den fazla adam, clustered bir sekilde mi duruyorlar
    //gps algoritmalari
    //capi 10m olan bir dairenin icindeler mi
    
    //implement
    
    
    //siniftaysan app'i ac
    
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
        // Do any additional setup after loading the view, typically from a nib.
        self.manager.delegate = self.locationDelegate
        self.locationDelegate.registerViewController(self)
        self.manager.requestAlwaysAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goButton(sender: AnyObject) {
        
        if CLLocationManager.locationServicesEnabled() {
            
            println("Location services are enabled")
            self.manager.startMonitoringVisits()
            self.manager.stopMonitoringVisits()
            self.manager.startUpdatingLocation()
            println(self.manager.delegate.debugDescription)
            
        }
    }
}

