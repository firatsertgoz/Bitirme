

import UIKit

class CourseListViewController: UIViewController, UITableViewDelegate {
    
    var rowNumber = 0
    var json:JSON = JSON([])
    var selectedCourseId: Int?
    var responseDict:NSArray = NSArray()
    @IBOutlet weak var tableView: UITableView!
    var receivedJSON = JSON([])
    
    let httpHelper = HTTPHelper()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCourses()
        println(self.receivedJSON)
    }
    
    // Disable navigation bar
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.setHidesBackButton(true,animated:false)   //it hides
        self.navigationItem.title = "Course List"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowNumber
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CourseListRow")
        cell.selectionStyle = .None
        cell.textLabel?.text = self.json[indexPath.row]["name"].description
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let targetView = self.storyboard?.instantiateViewControllerWithIdentifier("DetailedCourseListView") as! DetailedCourseListViewController
        self.selectedCourseId = self.json[indexPath.row]["id"].int
        println("Json is:\n \(self.json.string)")
        println("selectedCourseId is \(self.selectedCourseId)")
        
        self.performSegueWithIdentifier("courseListRowSelected", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "courseListRowSelected") {
            let destinationVIew = segue.destinationViewController as! DetailedCourseListViewController
            destinationVIew.courseId = self.selectedCourseId
        }
    }
    
    func getCourses(){
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_courses", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                var jsonerror:NSError?
                self.json = JSON(data: data)
                self.rowNumber = self.json.count
                self.tableView.reloadData()
            }
        })
    }
}
