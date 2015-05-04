
import UIKit
import Charts

class CourseListViewController: UIViewController, UITableViewDelegate,ChartViewDelegate {
    
    var rowNumber = 0
    var json:JSON = JSON([])
    var selectedCourseId: Int?
    var responseDict:NSArray = NSArray()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    var receivedJSON = JSON([])
    
    let httpHelper = HTTPHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCourses()
        println(self.receivedJSON)

        tableView.rowHeight = 150
    
        studentImage.image = studentImage.image?.roundCornersToCircle(border: 10, color: UIColor.grayColor())
        greetingLabel.text = "Welcome, "+receivedJSON["first_name"].stringValue
        
        
        
    }
   func makeAttendanceRequest(ceId:Int){
        var httpHelper = HTTPHelper()
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("attend", method: "POST", authType: HTTPRequestAuthType.HTTPTokenAuth)
        httpRequest.HTTPBody = "{\"course_entity_id\":\"\(ceId)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = httpHelper.getErrorMessage(error)
            }
            else {
                var jsonerror:NSError?
                var response = JSON(data: data)
                println("Attendance response")
                println(response)
            }
        })
    }
    
    // Disable navigation bar
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated);
        self.navigationItem.setHidesBackButton(true,animated:false)   //it hides
       //self.navigationItem.title = "Course List"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNumber
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        var cell:CourseListCell = self.tableView.dequeueReusableCellWithIdentifier("CourseListCell") as! CourseListCell
        cell.selectionStyle = .None
        
        cell.courseLabel?.text = self.json[indexPath.row]["course"]["name"].stringValue
        setPieChartOptions(cell.pieChart,centerText: self.json[indexPath.row]["attendance_percentage"].stringValue as String)
    
        return cell
    }
    func setPieChartOptions(pie:PieChartView,centerText:String){
        
        pie.delegate = self
        pie.usePercentValuesEnabled = true
        pie.holeTransparent = true
        pie.holeRadiusPercent = 0.97
        pie.transparentCircleRadiusPercent = 0.55
        pie.drawHoleEnabled = true
        pie.descriptionText = ""
        pie.rotationAngle = 0
        pie.rotationEnabled = true
        pie.userInteractionEnabled = false
        pie.animate(xAxisDuration: 1.5,yAxisDuration:1.5)
        
        var colors :NSMutableArray = NSMutableArray()
        colors.addObjectsFromArray(ChartColorTemplates.colorful())
        colors.addObjectsFromArray(ChartColorTemplates.joyful())
        
       // var color:UIColor = ChartColorTemplates.colorful()[3]
        var color :UIColor = UIColor(red: 255/255 , green: 3/255, blue: 3/255, alpha: 1)
        var color2:UIColor = UIColor(red: 206/255 , green: 216/255, blue: 222/255, alpha: 1)
        var c = [color,color2]
        
        pie.centerText = "%"+centerText
        
        var entry : BarChartDataEntry = BarChartDataEntry(value: centerText.floatValue, xIndex: 0)
        
        var complement : BarChartDataEntry = BarChartDataEntry(value:100 - centerText.floatValue, xIndex:1)
        var yValues = [entry,complement]
        
        var dataSet : PieChartDataSet = PieChartDataSet(yVals: yValues)
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        pie.legend.enabled = false
        var data : ChartData = ChartData(xVals: ["",""], dataSet: dataSet)
        dataSet.colors = c
        pie.data = data
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let targetView = self.storyboard?.instantiateViewControllerWithIdentifier("DetailedCourseListView") as! DetailedCourseListViewController
        self.selectedCourseId = self.json[indexPath.row]["course"]["id"].int
        self.performSegueWithIdentifier("courseListRowSelected", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "courseListRowSelected") {
            let destinationView = segue.destinationViewController as! DetailedCourseListViewController
            destinationView.courseId = self.selectedCourseId
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
                println("In get courses:")
                println(self.json)
                self.rowNumber = self.json.count
                self.tableView.reloadData()
            }
        })
    }
 
}

class CourseListCell: UITableViewCell {
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
}



