//
//  CustomNavigationController.swift
//  Location
//
//  Created by Baris Can Vural on 3/23/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    
    var DashboardViewController_selectedCourseId : Int?;
    var CourseListViewController_receivedJSON = JSON([]);
    var DashboardViewController_receivedJSON = JSON([]);
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "DashboardToDetailed") {
            
            let destinationView = segue.destinationViewController as DetailedDashboardViewController
            destinationView.courseId = DashboardViewController_selectedCourseId
        }
            
        else if (segue.identifier == "LoginToCourseList"){
            //to the student UI
            let destinationView = segue.destinationViewController as CourseListViewController
            destinationView.receivedJSON = self.CourseListViewController_receivedJSON
            
        } else if (segue.identifier == "LoginToDashboard"){
            //to the instructor UI
            let destinationView = segue.destinationViewController as DashboardViewController
            destinationView.receivedJSON = self.DashboardViewController_receivedJSON
        }
        
        
        
        
        
    }
    

}
