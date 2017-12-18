//
//  ViewController1.swift
//  KSTimelineDemo
//
//  Created by Shih on 13/12/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit
import KSTimeline

class ViewController1: UIViewController {
    
    @IBOutlet weak var timeline: KSTimelineView!
    
    @IBOutlet weak var currentTime: UILabel!
    
    var currentDate: Date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! {
        
        didSet {
            
            let dateString = self.dateFormatter.string(from: currentDate)
            
            self.currentTime.text = dateString
            
        }
        
    }
    
    lazy var dateFormatter: DateFormatter = {
        
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter
        
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.timeline.delegate = self
        
        self.currentTime.text = self.dateFormatter.string(from: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.timeline.isScrollingLocked = true
        
        coordinator.animate(alongsideTransition: { (context) in
            
            self.timeline.contentView.rulerView.setNeedsDisplay()
            
            self.timeline.scrollToDate(date: self.currentDate)
            
        }) { (context) in
            
            self.timeline.isScrollingLocked = false
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()

    }
    
}

extension ViewController1: KSTimelineDelegate {
    
    func timelineStartScroll(_ timeline: KSTimelineView) {
        
    }
    
    func timelineEndScroll(_ timeline: KSTimelineView) {
        
    }
    
    func timeline(_ timeline: KSTimelineView, didScrollTo date: Date) {
        
        self.currentDate = date
        
    }
    
}
