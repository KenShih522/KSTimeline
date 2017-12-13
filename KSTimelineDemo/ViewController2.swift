//
//  ViewController2.swift
//  KSTimelineDemo
//
//  Created by Shih on 13/12/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import AVFoundation
import KSTimeline

extension Date {
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        
        return (min(date1, date2) ... max(date1, date2)).contains(self)
        
    }
    
}

class ViewController2: UIViewController {
    
    @IBOutlet weak var timeline: KSTimelineView!
    
    @IBOutlet weak var currentTime: UILabel!
    
    @IBOutlet weak var videoContainer: UIView!
    
    @IBOutlet var playBtn: UIBarButtonItem!
    
    @IBOutlet weak var prevousBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var currentEvent: KSTimelineEvent?
    
    var events: [KSTimelineEvent] = [KSTimelineEvent]()
    
    var displayLink: CADisplayLink?
    
    var isScrolling: Bool = false
    
    lazy var pauseBtn: UIBarButtonItem = {
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(ViewController2.didPressPauseBtn(_:)))
        
        return barButton
        
    }()
    
    lazy var dateFormatter: DateFormatter = {
        
        var dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter
        
    }()
    
    // MARK: IBAction
    
    @IBAction func didPressPreviousVideoBtn(_ sender: Any) {
        
        guard self.events.count > 0 else { return }
        
        if let event = self.getPreviousEvent(date: self.timeline.currentDate) {
            
            if self.events.index(of: event) == 0 {
                
                self.prevousBtn.isEnabled = false
                
            }
            
            self.playEvent(event: event)
            
            self.nextBtn.isEnabled = true
            
        }
        
    }
    
    @IBAction func didPressNextVideoBtn(_ sender: Any) {
        
        guard self.events.count > 0 else { return }
        
        if let event = self.getNextEvent(date: self.timeline.currentDate) {
            
            if self.events.index(of: event) == self.events.count - 1 {
                
                self.nextBtn.isEnabled = false
                
            }
            
            self.playEvent(event: event)
            
            if event == self.events.first {
                
                self.prevousBtn.isEnabled = false
                
            }
            else {
                
                self.prevousBtn.isEnabled = true
                
            }
            
        }
        else {
            
            let event = self.events[0]
            
            self.playEvent(event: event)
            
            self.prevousBtn.isEnabled = false
            
        }
        
    }
    
    @IBAction func didPressPlayBtn(_ sender: Any) {
        
        guard let event = self.findEvents(date: self.timeline.currentDate) else {
            
            guard let event = self.getNextEvent(date: self.timeline.currentDate) else {
                
                guard self.events.count > 0 else { return }
                
                self.playEvent(event: self.events[0])
                
                return
                
            }
            
            self.playEvent(event: event)
            
            return
            
        }
        
        if event == self.currentEvent {
            
            self.player?.play()
            
        }
        else {
            
            self.playEvent(event: event)
            
        }
        
        self.navigationItem.rightBarButtonItem = self.pauseBtn
        
    }
    
    @objc func didPressPauseBtn(_ sender: Any) {
        
        self.player?.pause()
        
        self.navigationItem.rightBarButtonItem = self.playBtn
        
    }
    
    // MARK: Internal Function
    
    internal func setupEvents() {
        
        var startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        var url = Bundle.main.url(forResource: "Toystory", withExtension: "mp4")!
        
        var duration = VideoHelper.getMediaDuration(url: url)
        
        var endDate = Calendar.current.date(byAdding: .second, value: Int(floor(duration)), to: startDate)!
        
        var event = KSTimelineEvent(start: startDate, end: endDate, duration: duration, videoURL: url)
        
        self.events.append(event)
        
        startDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)!
        
        url = Bundle.main.url(forResource: "BigBunny", withExtension: "mp4")!
        
        duration = VideoHelper.getMediaDuration(url: url)
        
        endDate = Calendar.current.date(byAdding: .second, value: Int(floor(duration)), to: startDate)!
        
        event = KSTimelineEvent(start: startDate, end: endDate, duration: duration, videoURL: url)
        
        self.events.append(event)
        
        startDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate)!
        
        startDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDate)!
        
        url = Bundle.main.url(forResource: "F35", withExtension: "mp4")!
        
        duration = VideoHelper.getMediaDuration(url: url)
        
        endDate = Calendar.current.date(byAdding: .second, value: Int(floor(duration)), to: startDate)!
        
        event = KSTimelineEvent(start: startDate, end: endDate, duration: duration, videoURL: url)
        
        self.events.append(event)
        
    }
    
    internal func findEvents(date: Date) -> KSTimelineEvent? {
        
        for event in self.events {
            
            if date.isBetween(event.start, and: event.end) {
                
                return event
                
            }
            
        }
        
        return nil
        
    }
    
    internal func getNextEvent(date: Date) -> KSTimelineEvent? {
        
        for event in self.events {
            
            if Int(event.start.timeIntervalSince1970) > Int(date.timeIntervalSince1970) {
                
                return event
                
            }
            
        }
        
        return nil
        
    }
    
    internal func getPreviousEvent(date: Date) -> KSTimelineEvent? {
        
        for event in self.events.reversed() {
            
            if Int(event.end.timeIntervalSince1970) < Int(date.timeIntervalSince1970) {
                
                return event
                
            }
            
        }
        
        return nil
        
    }
    
    internal func playEvent(event: KSTimelineEvent) {
        
        self.displayLink?.invalidate()
        
        self.displayLink = nil
        
        self.playerLayer?.removeFromSuperlayer()
        
        let asset = AVURLAsset(url: event.videoURL)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.player = AVPlayer(playerItem: playerItem)
        
        self.playerLayer = AVPlayerLayer(player: self.player!)
        
        self.playerLayer!.frame = self.videoContainer.bounds
        
        self.videoContainer.layer.addSublayer(self.playerLayer!)
        
        self.currentEvent = event
        
        self.player!.play()
        
        self.navigationItem.rightBarButtonItem = self.pauseBtn
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(ViewController2.displayLinkDidFire(_:)))
        
        self.displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
    }
    
    // MARK: CADisplayLink Task
    
    @objc func displayLinkDidFire(_ sender: CADisplayLink) {
        
        guard self.isScrolling == false else { return }
        
        guard let player = self.player else { return }
        
        guard let currentItem = player.currentItem else { return }
        
        guard let currentEvent = self.currentEvent else { return }
        
        if UIApplication.shared.applicationState == .background { return }
        
        let seconds = CMTimeGetSeconds(currentItem.currentTime())
        
        guard seconds > 0 else { return }
        
        let date = currentEvent.start.addingTimeInterval(seconds)
        
        if date >= currentEvent.end {
            
            guard let index = self.events.index(of: currentEvent) else { return }
            
            let newIndex = index + 1
            
            if newIndex < self.events.count {
                
                self.currentEvent = self.events[newIndex]
                
                self.playEvent(event: self.currentEvent!)
                
            }
            
        }
        
        self.timeline.scrollToDate(date: date)
        
        let dateString = self.dateFormatter.string(from: date)
        
        self.currentTime.text = dateString
        
    }
    
    // MARK: View Function
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.timeline.delegate = self
        
        self.timeline.datasource = self
        
        self.currentTime.text = self.dateFormatter.string(from: Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!)
        
        self.setupEvents()
        
        guard self.events.count > 0 else { return }
        
        self.prevousBtn.isEnabled = false
        
        self.nextBtn.isEnabled = true
        
        self.playBtn.isEnabled = true
        
        self.pauseBtn.isEnabled = true
        
        guard let event = self.findEvents(date: self.timeline.currentDate) else { return }
        
        self.playEvent(event: event)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        self.playerLayer?.frame = self.videoContainer.bounds
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            
            self.timeline.contentView.rulerView.setNeedsDisplay()
            
        }) { (context) in
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
}

extension ViewController2: KSTimelineDelegate {
    
    func timelineStartScroll(_ timeline: KSTimelineView) {
        
        self.isScrolling = true
        
    }
    
    func timelineEndScroll(_ timeline: KSTimelineView) {
        
        self.isScrolling = false
        
    }
    
    func timeline(_ timeline: KSTimelineView, didScrollTo date: Date) {
        
        self.isScrolling = true
        
        let dateString = self.dateFormatter.string(from: date)
        
        self.currentTime.text = dateString
        
        guard let lastEvent = self.events.last else { return }
        
        guard let firstEvent = self.events.first else { return }
        
        let date = self.timeline.currentDate!
        
        if lastEvent == firstEvent {
            
            self.prevousBtn.isEnabled = false
            
            self.nextBtn.isEnabled = false
            
        }
        else if date < firstEvent.end {
            
            self.prevousBtn.isEnabled = false
            
            self.nextBtn.isEnabled = true
            
        }
        else if date > lastEvent.start {
            
            self.nextBtn.isEnabled = false
            
            self.prevousBtn.isEnabled = true
            
        }
        else {
            
            self.nextBtn.isEnabled = true
            
            self.prevousBtn.isEnabled = true
            
        }
        
        guard let event = self.findEvents(date: date) else {
            
            self.player?.pause()
            
            self.currentEvent = nil
            
            self.navigationItem.rightBarButtonItem = self.playBtn
            
            return
            
        }
        
        guard self.currentEvent == event else {
            
            self.playEvent(event: event)
            
            return
            
        }
        
        let interval = date.timeIntervalSince(event.start)
        
        let timeScale = self.player?.currentItem?.asset.duration.timescale
        
        let time = CMTimeMakeWithSeconds(interval, timeScale!)
        
        self.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
    }
    
}

extension ViewController2: KSTimelineDatasource {
    
    func numberOfEvents(_ timeline: KSTimelineView) -> Int {
        
        return self.events.count
        
    }
    
    func event(_ timeline: KSTimelineView, at index: Int) -> KSTimelineEvent {
        
        return self.events[index]
        
    }
    
}
