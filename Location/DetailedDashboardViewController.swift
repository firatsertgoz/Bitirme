
import UIKit
import Charts

class DetailedDashboardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,ChartViewDelegate{
    
    var rowNumber = 0;
    let httpHelper = HTTPHelper()
    var courseId : Int!
    var GraphOption = 0
    var termStartDate : String!
    
    var names : NSMutableArray = []
    
    var overallJson: JSON?
    var monthJson: JSON?
    var weekJson: JSON?
    var dayJSON: JSON?
    
    var atendeesData : JSON?
    var graphDataOverall : JSON?
    var graphDataMonth : JSON?
    var graphDataWeek : JSON?
    var graphDataDay : JSON?
    
    var atendeesArr : [Dictionary<String, AnyObject>] = []
    var graphOverallArr : [Dictionary<String, AnyObject>] = []
    var graphMonthArr:[Dictionary<String, AnyObject>] = []
    var graphWeekArr : [Dictionary<String, AnyObject>] = []
    var graphDayArr : [Dictionary<String, AnyObject>] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerCtrl: TableHeaderViewController!
    var graph: HorizontalBarChartView!
    var overallBtn: UIButton!
    var monthBtn: UIButton!
    var weekBtn: UIButton!
    var dayBtn: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Attendance"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerViewSetup()
        setGraphSettings()
        tableView.separatorInset.right = tableView.separatorInset.left
        
        println("Term start date:\(self.termStartDate)")
        get_attendees()
        overallClicked()
    }
    func headerViewSetup(){
        headerCtrl = TableHeaderViewController(viewController:self)
        graph = headerCtrl.graph
        overallBtn = headerCtrl.overallBtn
        monthBtn = headerCtrl.monthBtn
        weekBtn = headerCtrl.weekBtn
        dayBtn = headerCtrl.dayBtn
        tableView.tableHeaderView = headerCtrl.mainView
        
        overallBtn.addTarget(self, action: "overallClicked", forControlEvents: UIControlEvents.TouchUpInside)
        monthBtn.addTarget(self, action: "monthClicked", forControlEvents: UIControlEvents.TouchUpInside)
        weekBtn.addTarget(self, action: "weekClicked", forControlEvents: UIControlEvents.TouchUpInside)
        dayBtn.addTarget(self, action: "dayClicked", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func overallClicked(){
        btnSelected(overallBtn,state: true)
        btnSelected(monthBtn,state: false)
        btnSelected(weekBtn,state: false)
        btnSelected(dayBtn,state: false)
        
        if(graphOverallArr.count==0){
            get_attendance_count_for_graph(0)
        } else {
            drawGraph(0)
            tableView.reloadData()
        }
    }
    func monthClicked(){
        btnSelected(overallBtn,state: false)
        btnSelected(monthBtn,state: true)
        btnSelected(weekBtn,state: false)
        btnSelected(dayBtn,state: false)
        if(graphMonthArr.count==0){
        get_attendance_count_for_graph(1)
        } else {
            drawGraph(1)
            tableView.reloadData()
        }
    }
    func weekClicked(){
        btnSelected(overallBtn,state: false)
        btnSelected(monthBtn,state: false)
        btnSelected(weekBtn,state: true)
        btnSelected(dayBtn,state: false)
        println("weekClicked")
        if(graphWeekArr.count==0){
            get_attendance_count_for_graph(2)
        } else {
            drawGraph(2)
            tableView.reloadData()
        }
    }
    
    func dayClicked(){
        btnSelected(overallBtn,state: false)
        btnSelected(monthBtn,state: false)
        btnSelected(weekBtn,state: false)
        btnSelected(dayBtn,state: true)
        
        println("dayClicked")
        if(graphDayArr.count==0){
            get_attendance_count_for_graph(3)
        } else {
            drawGraph(3)
            tableView.reloadData()
        }
        
    }
    
    func btnSelected(btn:UIButton,state:Bool){
        if(state){ //selected
            btn.backgroundColor = self.view.tintColor
            btn.selected = true
        } else {
            btn.backgroundColor = UIColor.whiteColor()
            btn.selected = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNumber
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:DetailedDashboardCell = self.tableView.dequeueReusableCellWithIdentifier("DetailedDashboardCell") as! DetailedDashboardCell
        cell.selectionStyle = .None //don't highlight when selected
        
        if(overallBtn.selected==true){
            cell.nameLabel?.text = self.overallJson![indexPath.row]["name"].stringValue
            cell.percentageLabel?.text = "%" + self.overallJson![indexPath.row]["attendance_percentage"].stringValue
        } else if(monthBtn.selected==true){
            cell.nameLabel?.text = self.monthJson![indexPath.row]["name"].stringValue
            cell.percentageLabel?.text = "%" + self.monthJson![indexPath.row]["attendance_percentage"].stringValue
        } else if(weekBtn.selected==true){
            cell.nameLabel?.text = self.weekJson![indexPath.row]["name"].stringValue
            cell.percentageLabel?.text = "%" + self.weekJson![indexPath.row]["attendance_percentage"].stringValue
        } else {
            cell.nameLabel?.text = self.dayJSON![indexPath.row]["name"].stringValue
            cell.percentageLabel?.text = "%" + self.dayJSON![indexPath.row]["attendance_percentage"].stringValue
        }
        
        
        return cell
    }
    
    func get_attendance_count_for_graph(option:Int) {
        // HTTP Request
        let httpRequest = httpHelper.buildRequest(
            "get_attendance_count_for_graph?course_id=\(self.courseId)&option=\(option)",
            method: "GET",
            authType: HTTPRequestAuthType.HTTPTokenAuth)
        
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                var receivedJSON = JSON(data:data)
                switch (option) {
                case (0):
                    self.graphDataOverall = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphOverallArr)
                    self.sortArrayByDate(&self.graphOverallArr)
                    self.get_attendees_by_percentage(0)
                    self.drawGraph(0)
                case (1):
                    self.graphDataMonth = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphMonthArr)
                    self.sortArrayByDate(&self.graphMonthArr)
                    self.get_attendees_by_percentage(1)
                    self.drawGraph(1)
                case (2):
                    self.graphDataWeek = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphWeekArr)
                    self.sortArrayByDate(&self.graphWeekArr)
                    self.get_attendees_by_percentage(2)
                    self.drawGraph(2)
                case (3):
                    self.graphDataDay = receivedJSON
                    self.writeGraphJsonToArrOfDict(receivedJSON, arrDict: &self.graphDayArr)
                    self.sortArrayByDate(&self.graphDayArr)
                    self.get_attendees_by_percentage(3)
                    self.drawGraph(3)
                default:
                    println("Option invalid")
                }
                println(receivedJSON)
                
            }
        })
    }
    
    func drawGraph(option:Int){
        if(option==0){
            addGraphData(graphOverallArr)
        } else if(option==1){
            addGraphData(graphMonthArr)
        } else if(option==2){
            addGraphData(graphWeekArr)
        } else {
            addGraphData(graphDayArr)
        }
    }
    
    func addGraphData(arr:[Dictionary<String, AnyObject>]){
        var xValues  = [String]()
        var yValues = [ChartDataEntry]()
        for(var i = 0;i<arr.count;i++){
            var x :String = (arr[i]["day"] as! String).substr(0, end: 3) + " " + (arr[i]["start_time"] as! String).substr(11,end: 16)
            var y : String = (arr[i]["total_attendance_count"] as! String)
            xValues.append(x)
            yValues.append(BarChartDataEntry(value: y.floatValue, xIndex: i))
        }
        var set : BarChartDataSet = BarChartDataSet(yVals:yValues,label:"")
        if(xValues.count <= 2)
        {
            set.barSpace = 0.70
        }
        else
        {
        set.barSpace = 0.35
        }
        set.setColor(self.view.tintColor)
        var dataSets  = [BarChartDataSet]()
        dataSets.append(set)
        var formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        var data : BarChartData = BarChartData(xVals: xValues, dataSets: dataSets)
        data.setValueFormatter(formatter)
        graph.leftAxis.customAxisMax = arr[0]["total_weeks"]!.floatValue
        graph.data = data
        graph.animate(yAxisDuration: 1)
    }
    
    func setGraphSettings(){
        graph.delegate = self
        graph.descriptionText = ""
        graph.noDataTextDescription = "No data yet"
        graph.drawBarShadowEnabled = true
        graph.drawValueAboveBarEnabled = true
        graph.maxVisibleValueCount = 60
        graph.pinchZoomEnabled = false
        graph.drawGridBackgroundEnabled = false
        graph.backgroundColor = UIColor.whiteColor()
        graph.centerViewTo(xIndex: Int(self.view.frame.width/2), yValue: self.view.frame.height/2, axis: ChartYAxis.AxisDependency.Right)
        
        var xAxis : ChartXAxis = graph.xAxis
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        xAxis.labelFont = UIFont.systemFontOfSize(10)
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.gridLineWidth = 0.3
        
        var leftAxis : ChartYAxis = graph.leftAxis
        leftAxis.labelFont = UIFont.systemFontOfSize(10)
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = true
        leftAxis.gridLineWidth = 0.5
        leftAxis.showOnlyMinMaxEnabled = true
        var formatter: NSNumberFormatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 0
        leftAxis.valueFormatter = formatter

        var rightAxis : ChartYAxis = graph.rightAxis
        rightAxis.labelFont = UIFont.systemFontOfSize(10)
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.enabled = false
        
        graph.legend.position = ChartLegend.ChartLegendPosition.BelowChartLeft
        graph.legend.form = ChartLegend.ChartLegendForm.Square
        graph.legend.formSize = 8
        graph.legend.font = UIFont(name:"HelveticaNeue-light", size:11)!
        graph.legend.xEntrySpace = 4
        graph.legend.enabled = false
        
        graph.animate(yAxisDuration: 1)
        graph.userInteractionEnabled = false
        
    }
    
    func get_attendees() {
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_attendees_by_course_id?course_id=\(self.courseId)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        //httpRequest.HTTPBody = "{\"course_id\":\"\(self.courseId)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                self.atendeesData = JSON(data: data)
                self.writeAtendeesJsonToArrOfDict(self.atendeesData!, arrDict: &self.atendeesArr)
              //  println(self.atendeesData)
               // self.rowNumber = self.getRowCount()
             //   self.tableView.reloadData()
            }
        })
    }
    
    func get_attendees_by_percentage(option:Int) {
        // HTTP Request
        let httpRequest = httpHelper.buildRequest("get_attendees_by_percentage?course_id=\(self.courseId)&option=\(option)", method: "GET", authType: HTTPRequestAuthType.HTTPTokenAuth)
        //httpRequest.HTTPBody = "{\"course_id\":\"\(self.courseId)\"}".dataUsingEncoding(NSUTF8StringEncoding)
        httpRequest.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        
        httpHelper.sendRequest(httpRequest, completion: { (data:NSData!, error:NSError!) -> Void in
            //display error
            if error != nil {
                let errorMessage = self.httpHelper.getErrorMessage(error)
                println(errorMessage)
            }
            else {
                var json = JSON(data:data)
                self.rowNumber = json.count
                println("Inside percentage")
                println(json)
                if option == 0 {
                    self.overallJson = json
                } else if option == 1 {
                    self.monthJson = json
                } else if  option == 2 {
                    self.weekJson = json
                } else {
                    self.dayJSON = json
                }
                
                
                
                self.tableView.reloadData()
            }
        })
    }

    
    func getRowCount() -> Int {
        var set:Set<String> = Set<String>()
        for(var i=0;i<self.atendeesData!.count;i++){
            set.insert(self.atendeesData![i]["name"].stringValue)
        }
        for name in set {
            self.names.addObject(name)
        }
        return set.count
    }
    
    func writeAtendeesJsonToArrOfDict(json:JSON, inout arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["name":json[i]["name"].stringValue,
                         "attendance_date":json[i]["attendance_date"].stringValue,
                        "total_lectures" : json[i]["total_lectures"].stringValue
                ])
        }
    }
    func writeGraphJsonToArrOfDict(json:JSON, inout arrDict: [Dictionary<String, AnyObject>]){
        for(var i=0;i<json.count;i++){
            arrDict.append(["day":json[i]["day"].stringValue,
                "start_time":json[i]["start_time"].stringValue,
                "total_attendance_count" : json[i]["total_attendance_count"].stringValue,
                "total_weeks" : json[i]["total_weeks"].stringValue
                ])
        }
    }
    
    func sortArrayByDate(inout arrDict: [Dictionary<String, AnyObject>]) {
        var x, y : Int
        var key : Dictionary<String,AnyObject>
        
        for (x = 0; x < arrDict.count; x++) { //obtain a key to be evaluated
            key = arrDict[x]
            //iterate backwards through the sorted portion 
            for (y = x; y > -1; y--) {
                if (compareDicts(&key,dic2:&arrDict[y])==0) {
                    //remove item from original position
                    arrDict.removeAtIndex(y + 1)
                    //insert the number at the key position
                    arrDict.insert(key, atIndex: y)
                }
            } //end for
        }
    }
    
    // a < b returns 0
    // a = b returns 1
    // a > b returns 2
    
    func compareDicts(inout dic1: Dictionary<String, AnyObject>, inout dic2: Dictionary<String,AnyObject>) -> Int {
        
        var days = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
        var day1 = findInArr(days,str: dic1["day"] as! String)
        var day2 = findInArr(days,str: dic2["day"] as! String)
        
        if(  day1 < day2) {
            return 0
        } else if (day1==day2){
            var time1 = (dic1["start_time"] as! String).substr(11,end: 16)
            var time2 = (dic2["start_time"] as! String).substr(11,end: 16)
            if( time1 < time2 ){
                return 0
            } else if (time1==time2){
                return 1
            } else { //time1 > time2
                return 2
            }
        } else { //day1 > day2
            return 2
        }
    }
    
    func findInArr(arr : Array<String>,str:String) -> Int {
        var count = 0
        for(var i = 0;  i<arr.count; i++ ){
            if(arr[i]==str){
                return count
            }
            count++
        }
        return -1
    }
    
    func intToCGFloat(value:Int) -> CGFloat {
        let f : CGFloat = CGFloat(value)
        return f
    }
}

class DetailedDashboardCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
}

class TableHeaderViewController {
    var nib: UINib!
    var mainView: UIView!
    
    var graph: HorizontalBarChartView!
    var overallBtn: UIButton!
    var monthBtn: UIButton!
    var weekBtn: UIButton!
    var dayBtn: UIButton!
    
    init(viewController:UIViewController) {
        nib = UINib(nibName: "HeaderView", bundle: nil)
        mainView = nib.instantiateWithOwner(viewController, options: nil)[0] as! UIView
        graph = mainView.viewWithTag(1) as! HorizontalBarChartView
        overallBtn = mainView.viewWithTag(2) as! UIButton
        monthBtn = mainView.viewWithTag(3) as! UIButton
        weekBtn = mainView.viewWithTag(4) as! UIButton
        dayBtn = mainView.viewWithTag(5) as! UIButton
        
        overallBtn.layer.borderWidth = 0.5
        overallBtn.layer.cornerRadius = 0.5
        overallBtn.clipsToBounds = true
        overallBtn.layer.borderColor = viewController.view.tintColor.CGColor
        overallBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        overallBtn.setTitleColor(viewController.view.tintColor, forState: UIControlState.Normal)
        monthBtn.layer.borderWidth = 0.5
        monthBtn.layer.cornerRadius = 0.5
        monthBtn.layer.borderColor = viewController.view.tintColor.CGColor
        monthBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        monthBtn.setTitleColor(viewController.view.tintColor, forState: UIControlState.Normal)
        weekBtn.layer.borderWidth = 0.5
        weekBtn.layer.cornerRadius = 0.5
        weekBtn.layer.borderColor = viewController.view.tintColor.CGColor
        weekBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        weekBtn.setTitleColor(viewController.view.tintColor, forState: UIControlState.Normal)
        dayBtn.layer.borderWidth = 0.5
        dayBtn.layer.cornerRadius = 0.5
        dayBtn.layer.borderColor = viewController.view.tintColor.CGColor
        dayBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
        dayBtn.setTitleColor(viewController.view.tintColor, forState: UIControlState.Normal)
    }
}





