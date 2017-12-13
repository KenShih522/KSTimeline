//
//  VideoHelper.swift
//  KSTimelineDemo
//
//  Created by Shih on 13/12/2017.
//  Copyright © 2017 kenshih. All rights reserved.
//

import UIKit
import AVFoundation

class VideoHelper: NSObject {
    
    class func getMediaDuration(url: URL) -> Double{
        
        let asset = AVURLAsset(url: url)
        
        let duration: CMTime = asset.duration
        
        return CMTimeGetSeconds(duration)
        
    }

}
