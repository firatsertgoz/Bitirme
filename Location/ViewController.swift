

import UIKit
import CoreLocation
import AVFoundation


class ViewController: UIViewController , AVCaptureMetadataOutputObjectsDelegate
 {
    
    //region coordinates knwon
    //1den fazla adam, clustered bir sekilde mi duruyorlar
    //gps algoritmalari
    //capi 10m olan bir dairenin icindeler mi
    
    //implement
    
    
    //siniftaysan app'i ac
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
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
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        
        if (error != nil) {
            // If any error occurs, simply log the description of it and don't continue any more.
            println("\(error?.localizedDescription)")
            return
        }
        
        // Initialize the captureSession object.
        captureSession = AVCaptureSession()
        // Set the input device on the capture session.
        captureSession?.addInput(input as AVCaptureInput)
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

