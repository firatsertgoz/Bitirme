

import Foundation
import CoreLocation


class LocationDelegate: NSObject, CLLocationManagerDelegate{
    
    var viewController: ViewController?
    var numOfLocationUpdates = 0;
    var manager : CLLocationManager!
    
    func registerViewController(controller: ViewController){
        self.viewController = controller
    }
    
    func registerManager(manager : CLLocationManager){
        self.manager = manager
    }
    
    //protocol functions
    
    /*
    *  locationManager:didUpdateLocations:
    *
    *  Discussion:
    *    Invoked when new locations are available.  Required for delivery of
    *    deferred locations.  If implemented, updates will
    *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
    *
    *    locations is an array of CLLocation objects in chronological order.
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println("inside didUpdateLocations,num:\(numOfLocationUpdates)")
        numOfLocationUpdates++
        if numOfLocationUpdates==5{
            println("Now waiting..")
            self.manager.stopUpdatingLocation()
           NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("restartMonitoring"), userInfo: nil, repeats: false)
        }
        
        var location = locations[0] as! CLLocation
        
        println("Latitude: \((location.coordinate.latitude))")
        println("Longitude: \((location.coordinate.longitude))")
        self.viewController?.textLabel.text = "\((location.coordinate.latitude))" + ", \((location.coordinate.longitude))"
        
    }
    
    func restartMonitoring() {
        self.numOfLocationUpdates = 0
        self.manager.startUpdatingLocation()
    }
    
    /*
    *  locationManager:didVisit:
    *
    *  Discussion:
    *    Invoked when the CLLocationManager determines that the device has visited
    *    a location, if visit monitoring is currently started (possibly from a
    *    prior launch).
    */
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        
        println("inside did visit")
        
        
        if visit!.departureDate.isEqualToDate(NSDate.distantFuture() as! NSDate) {
            // User has arrived, but not left, the location
            
            if (visit != nil) {
                println("visit isn't null")
                println(visit.coordinate.latitude)
                println(visit.coordinate.longitude)
            } else {
                println("visit is null")
            }
            
        } else {
            println("visit is complete")
            // The visit is complete
        }
    }
    
    /*
    *  locationManager:didFailWithError:
    *
    *  Discussion:
    *    Invoked when an error has occurred. Error types are defined in "CLError.h".
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Inside didFailWithError")
        //println(error.description)
        
    }
    
    /*
    *  locationManager:monitoringDidFailForRegion:withError:
    *
    *  Discussion:
    *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
    */
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("Inside monitoringDidFailForRegion")
        println(error.description)
    }
    
}















