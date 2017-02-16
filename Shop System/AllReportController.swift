//
//  AllReportController.swift
//  Shop System
//
//  Created by Pavel Aristov on 18.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit
import iCarousel
import Charts

struct ShowOrder {
    var sum = 0.0
    var profit = 0.0
    var countGuests = 0
    var avgSum = 0.0
}

class AllReportController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var ordersLoadActivity: UIActivityIndicatorView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var collectionView: iCarousel!
    @IBOutlet weak var segmentation: UISegmentedControl!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarBack: UIImageView!
    
    @IBOutlet weak var allSumLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var avgSumLabel: UILabel!
    @IBOutlet weak var countGuestLabel: UILabel!
    
    @IBOutlet weak var calendarUpCloseView: UIView!
    
    @IBOutlet weak var closeOpenArrow: UIImageView!
    
    @IBOutlet weak var calendarTop: NSLayoutConstraint!
    
    let gregorian = Calendar(identifier: .gregorian)
    
    var orders = [Order]()
    var showOrders = [ShowOrder]()
    var currentOrders = [[Order]()]
    
    var numLabels = [String]()//, "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    var xLabels = [String]()
    
    var isScrolling = false
    
    override func viewDidLayoutSubviews() {
        let separator = UIView(frame: CGRect(x: calendarView.calendarHeaderView.center.x - 40, y: calendarView.calendarHeaderView.bounds.height - 10, width: 80, height: 4))
        
        separator.backgroundColor = UIColor.orangeFill()
        separator.layer.cornerRadius = 2
        calendarView.calendarHeaderView.addSubview(separator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chartView.clear()
        self.orders.removeAll()
        ordersLoadActivity.startAnimating()
        self.calendarTop.constant = 11
        self.closeOpenArrow.image = #imageLiteral(resourceName: "closeArrow")
        API.OrdersManager.getAllOrdersWithSales { (orders) in
            self.ordersLoadActivity.stopAnimating()
            self.orders = orders
            switch self.segmentation.selectedSegmentIndex {
            case 0: self.fillByDay()
            case 1: self.fillByMonth()
            case 2: self.fillByYear()
            default: break
            }
            //self.setChartData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentation.setImage(segmentation.imageForSegment(at: 3)!.resize(to: CGSize(width: 50, height: 17)), forSegmentAt: 3)
        
        //Set chartView
        collectionView.type = .linear
        chartView.delegate = self
        
        chartView.noDataText = ""
        chartView.chartDescription?.text = ""
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        
        chartView.xAxis.avoidFirstLastClippingEnabled = true
        chartView.xAxis.labelCount = 14
        chartView.xAxis.labelPosition = .bottomInside
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLabelsEnabled = true
        chartView.xAxis.labelTextColor = UIColor.white
        chartView.xAxis.yOffset = -5
        chartView.xAxis.granularity = 1
        
        chartView.scaleYEnabled = false
        chartView.scaleXEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawBordersEnabled = false
        chartView.backgroundColor = UIColor.clear
        
        // Set calendarView
        calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendarView.appearance.titleFont = UIFont(name: "Helvetica Neue", size: 16)
        calendarView.appearance.headerTitleFont = UIFont(name: "Helvetica Neue", size: 24)
        calendarView.appearance.weekdayFont = UIFont(name: "Helvetica Neue", size: 10)
        calendarView.appearance.caseOptions = .weekdayUsesUpperCase
        calendarView.appearance.imageOffset = CGPoint(x: 0, y: 2)
        calendarView.appearance.titleOffset = CGPoint(x: 0, y: 2)
        calendarView.swipeToChooseGesture.isEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = .right
        calendarView.calendarHeaderView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = .left
        calendarView.calendarHeaderView.addGestureRecognizer(swipeLeft)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        panGesture.require(toFail: swipeLeft)
        panGesture.require(toFail: swipeRight)
        calendarView.calendarHeaderView.addGestureRecognizer(panGesture)
        //calendarView.calendarHeaderView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        calendarView.calendarHeaderView.addGestureRecognizer(tap)
    }
    
    var calendarVisible: Bool {
        get {
            return calendarBack.isHidden
        }
        set {
            UIView.animate(withDuration: 0.2) {
                self.calendarView.selectedDates.forEach({ (date) in
                    self.calendarView.deselect(date)
                })
                
                self.allSumLabel.text = "0 ₽"
                self.avgSumLabel.text = "0 ₽"
                self.profitLabel.text = "0 ₽"
                self.countGuestLabel.text = "0"
                self.calendarView.reloadData()
                
                self.calendarBack.alpha = newValue ? 1 : 0
                self.calendarView.alpha = newValue ? 1 : 0
                self.calendarBack.isHidden = !newValue
                self.calendarView.isHidden = !newValue
                
                if newValue {
                    self.chartView.frame = CGRect(origin: self.chartView.frame.origin, size: CGSize(width: self.chartView.frame.size.width, height: self.chartView.frame.size.height - 20))
                   
                }
            }
        }
    }
    
    var currentLastLast = 0
    var currentLast = 0
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .right {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: -1, to: calendarView.currentPage)!, animated: true)
            }
            else if swipeGesture.direction == .left {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: 1, to: calendarView.currentPage)!, animated: true)
            }
        }
        else if let tapGesture = gesture as? UITapGestureRecognizer {
            if tapGesture.location(in: calendarView.calendarHeaderView).x > (calendarView.calendarHeaderView.center.x + 100) {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: 1, to: calendarView.currentPage)!, animated: true)
            }
            else if tapGesture.location(in: calendarView.calendarHeaderView).x < (calendarView.calendarHeaderView.center.x - 100) {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: -1, to: calendarView.currentPage)!, animated: true)
            }
        }
        else if let panGesture = gesture as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self.view)
            
            if calendarBack.frame.origin.y + translation.y > self.collectionView.frame.origin.y {
                if calendarBack.frame.origin.y + translation.y < self.chartView.frame.origin.y + self.chartView.bounds.height - self.calendarUpCloseView.bounds.height {
                    self.calendarTop.constant += translation.y
                    UIView.animate(withDuration: 0.2, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
                else {
                    self.calendarTop.constant = 11 + self.collectionView.frame.height + self.chartView.frame.height - self.calendarUpCloseView.bounds.height
                }
            }
            else {
                self.calendarTop.constant = 11
               
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                closeOpenArrow.image = #imageLiteral(resourceName: "closeArrow")
            }
            
            if panGesture.state == .ended {
                if currentLast > currentLastLast {
                    self.calendarTop.constant = 11 + self.collectionView.frame.height + self.chartView.frame.height - self.calendarUpCloseView.bounds.height
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                            self.view.layoutIfNeeded()//self.calendarBack.layoutIfNeeded()
                        }, completion: nil)
                    
                    closeOpenArrow.image = #imageLiteral(resourceName: "openArrow")
                }
                else {
                    self.calendarTop.constant = 11
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                        }
                    closeOpenArrow.image = #imageLiteral(resourceName: "closeArrow")
                }
            }
            
            if (currentLast != Int(calendarTop.constant)) {
                currentLastLast = currentLast
                currentLast = Int(calendarTop.constant)
            }
            
            panGesture.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        isScrolling = true
        collectionView.scrollToItem(at: Int(highlight.x) - 1, animated: true)
        
        fillShowOrder(index: Int(highlight.x) - 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentetionValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: fillByDay()
            case 1: fillByMonth()
            case 2: fillByYear()
            case 3: calendarVisible = true
            default: break
        }
    }
    
    func fillShowOrder(index: Int) {
        let currValue = showOrders[index]
        allSumLabel.text = String(format: "%g ₽", currValue.sum)
        avgSumLabel.text = String(format: "%g ₽", currValue.avgSum)
        countGuestLabel.text = "\(currValue.countGuests)"
        profitLabel.text = String(format: "%g ₽", currValue.profit)
    }
    
    func fillByMonth() {
        calendarVisible = false
        showOrders.removeAll()
        xLabels.removeAll()
        numLabels.removeAll()
        currentOrders.removeAll()
        
        var ordersEntires = [ChartDataEntry]()
        ordersEntires.append(ChartDataEntry(x: Double(0), y: 0))
        
        for k in 1..<13 {
            let start = Calendar.current.date(byAdding: .month, value: Int(1 - k), to: Date().startOfMonth()!)
            let end = Calendar.current.date(byAdding: .month, value: 1, to: start!)
            
            var localOrders = orders.filter({$0.date >= start!})
            localOrders = localOrders.filter({$0.date <= end!})
            currentOrders.append(localOrders)
            
            var allSum = 0.0
            var profit = 0.0
            var countGuests = 0
            for order in localOrders {
                let localSum = order.getSum()
                allSum += localSum.sum
                profit += localSum.profit
                countGuests += 1
            }
            let orderEntry = ChartDataEntry(x: Double(13 - k), y: allSum)
            
            let comp: Set<Calendar.Component> = [.month]
            let monthIndex = Calendar.current.dateComponents(comp, from: start!).month!
            xLabels.insert(Global.shortMonth[monthIndex]!, at: 0)
            
            currentOrders.insert(localOrders, at: 0)
            showOrders.insert(ShowOrder(sum: allSum, profit: profit, countGuests: countGuests, avgSum: allSum / Double(countGuests == 0 ? 1 : countGuests)), at: 0)
            ordersEntires.insert(orderEntry, at: 1)
            numLabels.insert("\(monthIndex < 10 ? "0" : "")\(monthIndex)", at: 0)
        }
        
        if !ordersLoadActivity.isAnimating {
            ordersEntires.append(ChartDataEntry(x: Double(13), y: 0))
        
            let chartDataSet = LineChartDataSet(values: ordersEntires, label: "Sum")
            setChartDataSet(dataSet: chartDataSet)
            
            chartView.data = LineChartData(dataSets: [chartDataSet])
            
            var values = xLabels
            values.insert("t", at: 0)
            values.append("t")
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)
            
            chartView.animate(yAxisDuration: 0.2, easingOption: .easeInCubic)
        }
        
        collectionView.reloadData()
        collectionView.scrollToItem(at: self.numLabels.count - 2, animated: false)
        collectionView.scrollToItem(at: self.numLabels.count - 1, animated: false)
        fillShowOrder(index: collectionView.currentItemIndex)
    }
    
    func fillByDay() {
        calendarVisible = false
        showOrders.removeAll()
        xLabels.removeAll()
        numLabels.removeAll()
        currentOrders.removeAll()
        
        var ordersEntires = [ChartDataEntry]()
        ordersEntires.append(ChartDataEntry(x: Double(0), y: 0))
        
        var dayStrings = [String]()
        
        for k in 1..<13 {
            let start = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: Int(1 - k), to: Date())!)
            let end = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: start)!)
            
            var localOrders = orders.filter({$0.date >= start})
            localOrders = localOrders.filter({$0.date <= end})
            
            var allSum = 0.0
            var profit = 0.0
            var countGuests = 0
            for order in localOrders {
                let localSum = order.getSum()
                allSum += localSum.sum
                profit += localSum.profit
                countGuests += 1
            }
            let orderEntry = ChartDataEntry(x: Double(13 - k), y: allSum)
            
            let comp: Set<Calendar.Component> = [.month, .day]
            let date = Calendar.current.dateComponents(comp, from: start)
            let dayString = "\(date.day! < 10 ? "0" : "")\(date.day!)"
            xLabels.insert(Global.shortMonth[date.month!]!, at: 0)
            numLabels.insert(dayString, at: 0)
            dayStrings.insert(dayString, at:0)
            
            currentOrders.insert(localOrders, at: 0)
            
            showOrders.insert(ShowOrder(sum: allSum, profit: profit, countGuests: countGuests, avgSum: allSum / Double(countGuests == 0 ? 1 : countGuests)), at: 0)
            ordersEntires.insert(orderEntry, at: 1)
        }
        
        if !ordersLoadActivity.isAnimating {
            ordersEntires.append(ChartDataEntry(x: Double(13), y: 0))
            
            let chartDataSet = LineChartDataSet(values: ordersEntires, label: "Sum")
            setChartDataSet(dataSet: chartDataSet)
            
            chartView.data = LineChartData(dataSets: [chartDataSet])
            
            var values = dayStrings
            values.insert("t", at: 0)
            values.append("t")
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)
            
            chartView.animate(yAxisDuration: 0.2, easingOption: .easeInCubic)
        }
        collectionView.reloadData()
        collectionView.scrollToItem(at: self.numLabels.count - 2, animated: false)
        collectionView.scrollToItem(at: self.numLabels.count - 1, animated: false)
    
        fillShowOrder(index: collectionView.currentItemIndex)
    }
    
    func fillByYear() {
        calendarVisible = false
        showOrders.removeAll()
        xLabels.removeAll()
        numLabels.removeAll()
        currentOrders.removeAll()
        
        var ordersEntires = [ChartDataEntry]()
        ordersEntires.append(ChartDataEntry(x: Double(0), y: 0))
        
        for k in 1..<13 {
            let start = Calendar.current.date(byAdding: .year, value: Int(1 - k), to: Date().startOfMonth()!)
            let end = Calendar.current.date(byAdding: .year, value: 1, to: start!)
            
            var localOrders = orders.filter({$0.date >= start!})
            localOrders = localOrders.filter({$0.date <= end!})
            currentOrders.append(localOrders)
            
            var allSum = 0.0
            var profit = 0.0
            var countGuests = 0
            for order in localOrders {
                let localSum = order.getSum()
                allSum += localSum.sum
                profit += localSum.profit
                countGuests += 1
            }
            let orderEntry = ChartDataEntry(x: Double(13 - k), y: allSum)
            
            let comp: Set<Calendar.Component> = [.year]
            let year = Calendar.current.dateComponents(comp, from: start!).year!
            //xLabels.insert("\(year)", at: 0)
            
            currentOrders.insert(localOrders, at: 0)
            showOrders.insert(ShowOrder(sum: allSum, profit: profit, countGuests: countGuests, avgSum: allSum / Double(countGuests == 0 ? 1 : countGuests)), at: 0)
            ordersEntires.insert(orderEntry, at: 1)
            numLabels.insert("\(year)", at: 0)
        }
        if !ordersLoadActivity.isAnimating {
            ordersEntires.append(ChartDataEntry(x: Double(13), y: 0))
            
            let chartDataSet = LineChartDataSet(values: ordersEntires, label: "Sum")
            setChartDataSet(dataSet: chartDataSet)
            
            chartView.data = LineChartData(dataSets: [chartDataSet])
            
            var values = numLabels
            values.insert("t", at: 0)
            values.append("t")
            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: values)
            
            chartView.animate(yAxisDuration: 0.2, easingOption: .easeInCubic)
        }
        collectionView.reloadData()
        collectionView.scrollToItem(at: self.numLabels.count - 2, animated: false)
        collectionView.scrollToItem(at: self.numLabels.count - 1, animated: false)
        fillShowOrder(index: collectionView.currentItemIndex)
    }
    
    func setChartDataSet(dataSet: LineChartDataSet) {
        // Create bar chart data set containing salesEntries
        dataSet.colors = [UIColor(hexString: "F7DFDB")]
        dataSet.valueTextColor = UIColor.white
        dataSet.valueFont = NSUIFont(name: "Helvetica Neue", size: 10)!
        dataSet.circleRadius = 2
        dataSet.circleColors = [UIColor.white]
        dataSet.highlightColor = UIColor.darkGray
        dataSet.highlightLineWidth = 1
        dataSet.highlightLineDashPhase = 2
        dataSet.highlightLineDashLengths = [3]
        
        //chartDataSet.cubicIntensity = 0.7
        dataSet.mode = .horizontalBezier
        //chartDataSet.drawValuesEnabled = false
        
        let gradientColors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0.2).cgColor] // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0] // Positioning of the gradient
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations) // Gradient Object
        dataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        dataSet.drawFilledEnabled = true // Draw the Gradient
        
    }
    
    @IBAction func currentOrderShowAction(_ sender: UIBarButtonItem) {
        if self.ordersLoadActivity.isAnimating { return }
        
        let ordersVC = Global.mainStoryBoard.instantiateViewController(withIdentifier: "reportVC") as! ReportController
        ordersVC.orders = self.currentOrders[collectionView.currentItemIndex]
        ordersVC.offline = true
        
        let navController = UINavigationController(rootViewController: ordersVC)
        present(navController, animated: true, completion: nil)
//        self.navigationController?.show(ordersVC, sender: self)
    }
}

extension AllReportController: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return numLabels.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var label1: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            
            label = itemView.viewWithTag(1) as! UILabel
            label1 = itemView.viewWithTag(2) as! UILabel
        } else {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 55, height: 90))
            label = UILabel(frame: CGRect(x: 0, y: 20, width: itemView.bounds.width, height: 60))
            label.textColor = UIColor.dayColor()
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica Neue", size: 16)
            label.tag = 1
            itemView.addSubview(label)
            
            label1 = UILabel(frame: CGRect(x: 0, y: 25, width: itemView.bounds.width, height: 10))
            label1.textColor = UIColor.dayColor()
            label1.textAlignment = .center
            label1.font = UIFont(name: "Helvetica Neue", size: 10)
            label1.tag = 2
            itemView.addSubview(label1)
        }

        label.text = "\(numLabels[index])"
        if xLabels.count != 0 {
            label1.text = "\(xLabels[index % xLabels.count].uppercased())"
        }
        
        return itemView
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        isScrolling = false
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        guard numLabels.count != 0 else { return }
        
        if !isScrolling {
            let highlight = Highlight(x: Double(collectionView.currentItemIndex + 1), y: -1000, dataSetIndex: 0)
            
            chartView.highlightValue(highlight)
            
            fillShowOrder(index: collectionView.currentItemIndex)
        }
        
        for view in collectionView.visibleItemViews {
            if let imageView = view as? UIView {
                let label = imageView.viewWithTag(1) as! UILabel
                let label1 = imageView.viewWithTag(2) as! UILabel
                
                if (imageView == self.collectionView.currentItemView) {
                    label.font = label.font.withSize(23)
                    label.textColor = UIColor.white
                    label1.textColor = UIColor.white
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        label.frame = CGRect(origin: CGPoint(x: label.frame.origin.x, y: label.frame.origin.y - 10), size: label.frame.size)
                        label1.frame = CGRect(origin: CGPoint(x: label1.frame.origin.x, y: label1.frame.origin.y - 10), size: label1.frame.size)
                    })
                }
                else {
                    label.font = label.font.withSize(16)
                    
                    label.textColor = UIColor.dayColor()
                    label1.textColor = UIColor.dayColor()
                    if (label.frame.origin.y < 20) {
                        UIView.animate(withDuration: 0.3, animations: {
                            label.frame = CGRect(origin: CGPoint(x: label.frame.origin.x, y: 20), size: label.frame.size)
                            label1.frame = CGRect(origin: CGPoint(x: label1.frame.origin.x, y: label1.frame.origin.y + 10), size: label1.frame.size)
                        })
                    }
                }
            }
        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
            case .visibleItems:
                return 7
            default:
                return value
        }
    }
}

extension AllReportController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        if date == calendarView.today {
            return #imageLiteral(resourceName: "current item").resize(to: CGSize(width: 30, height: 27))
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date, at: position)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date, at: position)
        }
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return true//monthPosition == .current;
    }
    
    // MARK: - Private functions
    
    func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let diyCell = (cell as! DIYCalendarCell)
        
        if calendarView.selectedDates.contains(date) {
            let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
            let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
            //print(diyCell.contentView.frame)
            if calendarView.selectedDates.contains(date) {
                diyCell.selectionLayer.isHidden = false
                if calendarView.selectedDates.contains(previousDate) && calendarView.selectedDates.contains(nextDate) {
                    diyCell.selectionLayer.path = UIBezierPath(rect: diyCell.contentView.frame).cgPath
                }
                else if calendarView.selectedDates.contains(previousDate) && calendarView.selectedDates.contains(date) {
                    diyCell.selectionLayer.path = UIBezierPath(roundedRect: diyCell.contentView.frame, byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: diyCell.contentView.frame.width / 2, height: diyCell.contentView.frame.width / 2)).cgPath
                }
                else if calendarView.selectedDates.contains(nextDate) {
                    diyCell.selectionLayer.path = UIBezierPath(roundedRect: diyCell.contentView.frame, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: diyCell.contentView.frame.width / 2, height: diyCell.contentView.frame.width / 2)).cgPath
                }
                else {
                    let diameter: CGFloat = min(diyCell.contentView.frame.height, diyCell.contentView.frame.width)
                    diyCell.selectionLayer.path = UIBezierPath(ovalIn: CGRect(x: diyCell.contentView.frame.width / 2 - diameter / 2, y: diyCell.contentView.frame.height / 2 - diameter / 2, width: diameter, height: diameter)).cgPath
                }
            }
        }
        else {
            diyCell.selectionLayer.isHidden = true
            return
        }
    }
}

