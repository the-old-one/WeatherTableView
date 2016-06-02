/*:
 # Apple "Weather" app inspired controls.
 I was
 It is a simplified version of the controller, without dynamics
 
 Created with Swift 2.2.
 
 Use Assistant editor (⌥+⌘+↩) to interact with the preview.
 */

import UIKit
import XCPlayground

//: View can be presented with different screen sizes
let screenSize = CGSize(width: 320, height: 568)

extension Int {
    func withDegree() -> String {
        return "\(self)°"
    }
}

protocol FakeScrollViewDelegate {
    func updateScrolling(offset: CGPoint)
}

//: Data structure to represent the day of the week. May be instantiated with a network data in a real application
struct Day {
    let name: String
    let temperature: Int
}

class WeekCell: UITableViewCell {
    
    let days:[Day]
    
    class func heightWithNumOfDays(days: Int) -> CGFloat {
        return CGFloat(days) * 25
    }
    
    init(days: [Day]) {
        self.days = days
        super.init(style: .Default, reuseIdentifier: nil)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
//: The size of the cell is updated only after it is placed in a superview
    override func didMoveToSuperview() {
        if self.superview != nil {
            self.contentView.frame.size.width = screenSize.width
            self.addDayLabels(with: self.days)
        }
    }
    
    func addDayLabels(with days:[Day]) {
        
        let labelHeight = 25
        let tempLabelX = Int(self.contentView.frame.width - 75)
        
        for (index, day) in days.enumerate() {
            let tempLabel = UILabel(frame: CGRect(x: tempLabelX, y: labelHeight * index, width: 50, height: labelHeight))
            tempLabel.textAlignment = .Right
            tempLabel.textColor = UIColor.whiteColor()
            tempLabel.text = day.temperature.withDegree()

            let dayLabel = UILabel(frame: CGRect(x: 15, y: labelHeight * index, width: 100, height: labelHeight))
            dayLabel.textColor = UIColor.whiteColor()
            dayLabel.text = day.name
            
            self.contentView.addSubview(dayLabel)
            self.contentView.addSubview(tempLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//: # The view class that creates all interactive elements except the TableView

class WeatherView: UIView, UIScrollViewDelegate {
    
    var delegate: FakeScrollViewDelegate?
    var scrollContentHeight: CGFloat = 0 {
        didSet {
            fakeScrollView.contentSize = CGSize(width: frame.width, height: scrollContentHeight)
        }
    }
    
    private let topView: UIView
    private let tempLabel: UILabel
    private let horizontalScrollView: ScrollingHeaderView
//: Additional scroll view covers all screen area to receive pan gestures even outside of the Table View
    private var fakeScrollView: UIScrollView

    override init(frame: CGRect) {
        
//        scrollContentHeight = 0
        
        topView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 250))
        tempLabel = UILabel(frame: CGRect(x: 0, y: 100, width: frame.width, height: 100))
        horizontalScrollView = ScrollingHeaderView(frame: CGRect(x: 0, y: 300, width: frame.width, height: 50))
        fakeScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: screenSize.height))
        
        super.init(frame:frame)
        
        let background: CAGradientLayer = CAGradientLayer()
        background.frame = self.frame
        background.colors = [[#Color(colorLiteralRed: 0.08294603228569031, green: 0.213395744562149, blue: 0.3579738140106201, alpha: 1)#].CGColor, [#Color(colorLiteralRed: 0.1431525945663452, green: 0.4145618975162506, blue: 0.7041897773742676, alpha: 1)#].CGColor, [#Color(colorLiteralRed: 0.3372549019607843, green: 0.4313725490196079, blue: 0.6196078431372549, alpha: 1)#].CGColor, [#Color(colorLiteralRed: 0.2193539291620255, green: 0.4209204912185669, blue: 0.1073316186666489, alpha: 1)#].CGColor]
        self.layer.addSublayer(background)
        
        topView.userInteractionEnabled = false
       
        addLocaionLabel(topView)
        addTemperatureLabel(topView)

        fakeScrollView.showsVerticalScrollIndicator = false
        fakeScrollView.delegate = self
        
        self.addSubview(topView)
        self.addSubview(fakeScrollView)
        self.addSubview(horizontalScrollView)
    }
    
    func addLocaionLabel(view: UIView) {
        
        let locationLabel = UILabel(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 50))
        locationLabel.text = "Auckland"
        locationLabel.textAlignment = .Center
        locationLabel.font = UIFont(name: locationLabel.font.fontName, size: 20)
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.shadowColor = UIColor.darkGrayColor()
        view.addSubview(locationLabel)
    }
    
    func addTemperatureLabel(view: UIView) {
        
        tempLabel.text = 12.withDegree()
        tempLabel.textAlignment = .Center
        tempLabel.font = UIFont(name: tempLabel.font.fontName, size: 80)
        tempLabel.textColor = UIColor.whiteColor()
        view.addSubview(tempLabel)
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        self.delegate?.updateScrolling(scrollView.contentOffset)
        
        self.tempLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(max(0, (200 - offsetY) * 0.01))
        self.topView.frame.origin.y = max(-50, -offsetY / 4)
        self.horizontalScrollView.frame.origin.y = max(100, -offsetY + 300)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//: This view simulates a **TableView header view**. In the real aplication it would have more functionality, so it is incapsulated in the separate class.
    class ScrollingHeaderView: UIView {
        
        override init(frame: CGRect) {
            let numOfItems = 10
            let itemSideLength = frame.height
            
            super.init(frame: frame)
            
            let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

            let borderLayerTop = CALayer()
            borderLayerTop.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
            borderLayerTop.backgroundColor = UIColor.lightGrayColor().CGColor
            
            let borderLayerBottom = CALayer()
            borderLayerBottom.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
            borderLayerBottom.backgroundColor = UIColor.lightGrayColor().CGColor
            
            self.layer.addSublayer(borderLayerTop)
            self.layer.addSublayer(borderLayerBottom)

            scrollView.contentSize = CGSize(width: CGFloat(numOfItems) * (itemSideLength + 10), height: scrollView.frame.height)
            scrollView.showsHorizontalScrollIndicator = false
            self.addSubview(scrollView)
            
            for index in 0..<10 {
                let smallView = UIView(frame: CGRect(x: (itemSideLength + 10) * CGFloat(index), y: 0, width: itemSideLength, height: itemSideLength))
                let timeLabel = UILabel(frame: CGRect(origin: CGPointZero, size: smallView.frame.size))
                timeLabel.text = Int(arc4random_uniform(5) + 10).withDegree()
                timeLabel.textAlignment = .Center
                timeLabel.textColor = UIColor.whiteColor()
                smallView.addSubview(timeLabel)
                scrollView.addSubview(smallView)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

class WeatherTableViewController: UITableViewController, FakeScrollViewDelegate {
    
//: In a real application it may be populated with a network data
    let days:[Day] = [Day(name: "Monday", temperature: 15),
                      Day(name: "Tuesday", temperature: 14),
                      Day(name: "Wednesday", temperature: 13),
                      Day(name: "Thursday", temperature: 12),
                      Day(name: "Friday", temperature: 11),
                      Day(name: "Saturday", temperature: 10),
                      Day(name: "Sunday", temperature: 9)]
    
    let enclosingView: WeatherView

    override init(style:UITableViewStyle) {
        
        enclosingView = WeatherView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        super.init(style: style)
        
        enclosingView.delegate = self
        
        let distanceFromTop: CGFloat = 150
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.tableView.frame = CGRect(x: 0, y: distanceFromTop, width: screenSize.width, height: enclosingView.frame.height - distanceFromTop)
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 200))
        self.tableView.allowsSelection = false
        self.tableView.userInteractionEnabled = false
        
//: Set the content height of the fake scroll view to simulate the table view content size scrolling limit
        enclosingView.scrollContentHeight = self.tableView.contentSize.height + distanceFromTop
        enclosingView.addSubview(self.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return WeekCell.heightWithNumOfDays(days.count)
        case 1:
            return 75
        default:
            return 200
        }
    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return WeekCell(days: days)
        case 1:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = "Today: Mostly fine, odd shower, clears afternoon. Light winds."
            cell.textLabel?.numberOfLines = 4
            cell.backgroundColor = UIColor.clearColor()
            return cell
        case 2:
            let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In justo odio, vehicula vel massa nec, sagittis posuere nibh. Morbi iaculis est non mi mattis, a hendrerit diam pharetra. Pellentesque quis bibendum ligula. In sit amet lectus vel metus porta imperdiet nec a sapien. Ut suscipit lacus ac arcu dictum vulputate."
            cell.textLabel?.numberOfLines = 10
            cell.backgroundColor = UIColor.clearColor()
            return cell
        default:
            return UITableViewCell(style: .Value1, reuseIdentifier: nil)
        }
    }
    
    //MARK: - FakeScrollViewDelegate
    
    func updateScrolling(offset: CGPoint) {
        self.tableView.contentOffset = offset
    }
}

let tableViewController = WeatherTableViewController(style: .Plain)
XCPlaygroundPage.currentPage.liveView = tableViewController.enclosingView

