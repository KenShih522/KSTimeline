//
//  KSTimelineContentView.swift
//  KSTimeline
//
//  Created by Shih on 24/11/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit

@IBDesignable open class KSTimelineContentView: UIScrollView, UIScrollViewDelegate {

    public let rulerView = KSTimelineRulerView()
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
    }
    
    func updateRuler() {
                        
        self.rulerView.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
                
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.clear
        
        self.updateRuler()
                
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
    
    internal func commonInit() {
        
        self.showsVerticalScrollIndicator = false
        
        self.showsHorizontalScrollIndicator = false
        
        self.isOpaque = true

        self.addSubview(self.rulerView)
        
        self.rulerView.drawWave = true
        
    }
        
}
