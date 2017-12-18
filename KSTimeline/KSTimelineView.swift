//
//  KSTimelineView.swift
//  KSTimeline
//
//  Created by Shih on 24/11/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit

@objc public protocol KSTimelineDelegate: NSObjectProtocol {
    
    func timelineStartScroll(_ timeline: KSTimelineView)
    
    func timelineEndScroll(_ timeline: KSTimelineView)
    
    func timeline(_ timeline: KSTimelineView, didScrollTo date: Date)
    
}

@objc public protocol KSTimelineDatasource: NSObjectProtocol {
    
    func numberOfEvents(_ timeline: KSTimelineView) -> Int
    
    func event(_ timeline: KSTimelineView, at index: Int) -> KSTimelineEvent
    
}

@objc public class KSTimelineEvent: NSObject {
    
    public var start: Date
    
    public var end: Date
    
    public var duration: Double
    
    public var videoURL: URL
    
    public init(start: Date, end: Date, duration: Double, videoURL: URL) {
        
        self.start = start
        
        self.end = end
        
        self.duration = duration
        
        self.videoURL = videoURL
        
        super.init()
        
    }
        
}

extension UIScreen {
    
    func widthOfSafeArea() -> CGFloat {
        
        guard let rootView = UIApplication.shared.keyWindow else { return 0 }
        
        if #available(iOS 11.0, *) {
            
            let leftInset = rootView.safeAreaInsets.left
            
            let rightInset = rootView.safeAreaInsets.right
            
            return rootView.bounds.width - leftInset - rightInset
            
        } else {
            
            return rootView.bounds.width
            
        }
        
    }
    
    func heightOfSafeArea() -> CGFloat {
        
        guard let rootView = UIApplication.shared.keyWindow else { return 0 }
        
        if #available(iOS 11.0, *) {
            
            let topInset = rootView.safeAreaInsets.top
            
            let bottomInset = rootView.safeAreaInsets.bottom
            
            return rootView.bounds.height - topInset - bottomInset
            
        } else {
            
            return rootView.bounds.height
            
        }
        
    }
    
}

@IBDesignable open class KSTimelineView: UIView {
    
    public var delegate: KSTimelineDelegate?
    
    public var datasource: KSTimelineDatasource?
    
    public var basedDate: Date!
    
    public var currentDate: Date!
    
    public var isScrollingLocked = false

    public let contentView = KSTimelineContentView()
    
    let currentIndicator: CAShapeLayer = CAShapeLayer()
    
    var pinchGesture: UIPinchGestureRecognizer!
    
    var lastScale: CGFloat = 1.0
    
    var scale: CGFloat = 1.0
    
    var isPinching = false
    
    @IBInspectable var contentWidth: CGFloat = 2400
    
    // MARK: Public Methods
    
    public func scrollToDate(date: Date) {
        
        let hour = Calendar.current.component(.hour, from: date)
        
        let minute = Calendar.current.component(.minute, from: date)
        
        let second = Calendar.current.component(.second, from: date)
        
        guard let target_date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.basedDate) else { return }
        
        let contentWidth = self.contentView.contentSize.width - UIScreen.main.widthOfSafeArea()
        
        let unit_hour_width = contentWidth / 24.0
        
        let unit_minute_width = unit_hour_width / 60.0
        
        let unit_second_width = unit_minute_width / 60.0
        
        let newOffset = (unit_hour_width * CGFloat(hour)) + (unit_minute_width * CGFloat(minute)) + (unit_second_width * CGFloat(second))
        
        let delegate = self.contentView.delegate
        
        self.contentView.delegate = nil;
        
        self.contentView.contentOffset = CGPoint(x: newOffset, y: 0)

        self.contentView.delegate = delegate;
        
        if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: target_date) {
            
            self.currentDate = date
            
        }
        else {
            
            self.currentDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: target_date)
            
        }
                
    }
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        self.backgroundColor = UIColor.clear
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.commonInit()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.commonInit()
        
    }
    
    override open func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
        self.commonInit()
        
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.contentView.setNeedsDisplay()
        
        let x = (self.bounds.size.width / 2)
        
        let y = CGFloat(0)
        
        let width = CGFloat(10)
        
        let height = self.bounds.height
        
        let frame = CGRect(x: x, y: y, width: width, height: height)
                
        self.currentIndicator.frame = frame
        
    }
    
    func commonInit() {
        
        let now = Date()
        
        self.basedDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: now)
        
        self.currentDate = basedDate
        
        self.setupView()
        
        self.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(KSTimelineView.pinch(gesture:)))

        self.contentView.addGestureRecognizer(self.pinchGesture)
        
        let padding = UIScreen.main.bounds.width - UIScreen.main.widthOfSafeArea()
        
        self.contentView.contentSize = CGSize(width: self.contentWidth + padding, height: self.bounds.height)
                                
    }
    
    @objc func pinch(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .began {
            
            lastScale = gesture.scale
            
            self.isPinching = true
            
        }
        
        let kMaxScale: CGFloat = 10.0
        
        let kMinScale: CGFloat = 1.0
        
        let currentScale = max(min(gesture.scale * scale, kMaxScale), kMinScale)
        
        self.contentView.contentSize = CGSize(width: self.contentWidth*currentScale, height: self.bounds.size.height)
        
        self.contentView.rulerView.frame.size = self.contentView.contentSize
        
        let hour = Calendar.current.component(.hour, from: self.currentDate)
        
        let minute = Calendar.current.component(.minute, from: self.currentDate)
        
        let second = Calendar.current.component(.second, from: self.currentDate)
        
        let padding: CGFloat = UIScreen.main.widthOfSafeArea()
        
        let contentWidth = self.contentView.contentSize.width - padding
        
        let unit_hour_width = contentWidth / 24.0
        
        let unit_minute_width = unit_hour_width / 60.0
        
        let unit_second_width = unit_minute_width / 60.0
        
        let newOffset = (unit_hour_width * CGFloat(hour)) + (unit_minute_width * CGFloat(minute)) + (unit_second_width * CGFloat(second))
                
        self.contentView.contentOffset = CGPoint(x: newOffset, y: 0)
        
        self.contentView.rulerView.setNeedsDisplay()
        
        lastScale = currentScale
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            
            scale = currentScale
            
            self.isPinching = false
            
        }
        
    }
    
    internal func setupView() {

        self.addSubview(self.contentView)
        
        self.contentView.delegate = self
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.rulerView.dataSource = self
        
        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))

        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        self.contentView.bounces = false
        
        self.setupCurrentIndicator()
        
    }
    
    internal func setupCurrentIndicator() {
        
        let triangle = UIBezierPath()
        
        triangle.move(to: CGPoint(x: -5, y: 0))
        
        triangle.addLine(to: CGPoint(x: 5, y: 0))
        
        triangle.addLine(to: CGPoint(x: 0, y: 10))
        
        triangle.close()
        
        let line = CALayer()
        
        line.frame = CGRect(x: -0.5, y: 0, width: 1, height: self.bounds.height)
        
        line.backgroundColor = UIColor.red.cgColor
        
        self.currentIndicator.path = triangle.cgPath
        
        self.currentIndicator.fillColor = UIColor.red.cgColor
        
        self.currentIndicator.addSublayer(line)
        
        self.layer.addSublayer(self.currentIndicator)
        
    }

}

extension KSTimelineView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.delegate?.timelineStartScroll(self)
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard isPinching == false && isScrollingLocked == false else { return }
        
        guard let target_date = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self.basedDate) else { return }
        
        let padding = self.bounds.width
        
        let contentWidth = scrollView.contentSize.width - padding
        
        let unit_hour_width = contentWidth / 24
        
        let unit_minute_width = unit_hour_width / 60
        
        let unit_second_width = unit_minute_width / 60
        
        let timeline_x = scrollView.contentOffset.x
        
        let hour = Int(floor(timeline_x / unit_hour_width))
        
        let minute = Int(floor((timeline_x - (CGFloat(hour) * unit_hour_width)) / unit_minute_width))
        
        let second = Int(floor((timeline_x - (CGFloat(hour) * unit_hour_width) - (CGFloat(minute) * unit_minute_width)) / unit_second_width))
        
        if let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: target_date) {
            
            self.currentDate = date
            
        }
        else {
            
            self.currentDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: target_date)
            
        }
        
        self.delegate?.timeline(self, didScrollTo: self.currentDate)
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        self.delegate?.timelineEndScroll(self)
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.delegate?.timelineEndScroll(self)
        
    }
    
}

extension KSTimelineView: KSTimelineRulerEventDataSource {
    
    func numberOfEvents(_ ruler: KSTimelineRulerView) -> Int {
        
        guard let datasource = self.datasource else { return 0 }
        
        return datasource.numberOfEvents(self)
        
    }
    
    func timelineRuler(_ ruler: KSTimelineRulerView, eventAt index: Int) -> KSTimelineEvent {
        
        return self.datasource!.event(self, at: index)
        
    }
    
}
