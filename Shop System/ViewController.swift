//
//  ViewController.swift
//  calendarTest
//
//  Created by Pavel Aristov on 25.11.16.
//  Copyright © 2016 NetSharks. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: FSCalendar!
    
    let gregorian = Calendar(identifier: .gregorian)
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @IBAction func buttonAction(_ sender: UIButton) {
        calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: 1, to: calendarView.currentPage)!, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        let lbl = UIImageView(frame: CGRect(x: 75, y: calendarView.calendarHeaderView.bounds.height - 20, width: calendarView.calendarHeaderView.bounds.width - 150, height: 20))
        
        lbl.image = #imageLiteral(resourceName: "current item")
        lbl.backgroundColor = .clear
        calendarView.calendarHeaderView.addSubview(lbl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.register(DIYCalendarCell.self, forCellReuseIdentifier: "cell")
        calendarView.appearance.titleFont = UIFont(name: "Helvetica Neue", size: 16)
        calendarView.appearance.headerTitleFont = UIFont(name: "Helvetica Neue", size: 24)
        calendarView.appearance.weekdayFont = UIFont(name: "Helvetica Neue", size: 10)
        calendarView.appearance.caseOptions = .weekdayUsesUpperCase
        calendarView.appearance.imageOffset = CGPoint(x: 0, y: 9)
        calendarView.appearance.titleOffset = CGPoint(x: 0, y: 2)
        calendarView.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        calendarView.calendarHeaderView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.left
        calendarView.calendarHeaderView.addGestureRecognizer(swipeLeft)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .right {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: -1, to: calendarView.currentPage)!, animated: true)
            }
            else {
                calendarView.setCurrentPage(self.gregorian.date(byAdding: .month, value: 1, to: calendarView.currentPage)!, animated: true)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        if date == calendarView.today {
            return #imageLiteral(resourceName: "current item")
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        print("did select date \(self.formatter.string(from: date))")
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date, at: position)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        print("did deselect date \(self.formatter.string(from: date))")
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

extension UIColor {
    convenience init(hexString: String) {
        let hexString:NSString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
}
