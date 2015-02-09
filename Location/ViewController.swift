

import UIKit
import CoreLocation

class ViewController: UIViewController,QRCodeReaderDelegate
 {
    
    //region coordinates knwon
    //1den fazla adam, clustered bir sekilde mi duruyorlar
    //gps algoritmalari
    //capi 10m olan bir dairenin icindeler mi
    
    //implement
    
    
    //siniftaysan app'i ac
    
    lazy var reader: QRCodeReader = QRCodeReader(cancelButtonTitle: "Cancel")
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(reader: QRCodeReader, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReader) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func scanAction(sender: AnyObject) {
        reader.modalPresentationStyle = .FormSheet
        reader.delegate               = self
        
        reader.completionBlock = { (result: String?) in
            println(result)
        }
        
        presentViewController(reader, animated: true, completion: nil)
    }
    
    
    
    
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
            
        }
    }
}

