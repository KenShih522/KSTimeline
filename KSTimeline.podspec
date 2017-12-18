Pod::Spec.new do |s|

  s.name         = "KSTimeline"
  s.version      = "0.1.1"
  s.summary      = "KSTimeline, written in swift, is a simple and customizable view which supports showing a series of events in a vertically time-sorted structure."
  s.homepage     = "https://github.com/KenShih522/KSTimeline"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "KenShih522" => "kenshih522@gmail.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/KenShih522/KSTimeline", :tag => "0.1.1" }
  s.source_files  = Dir['KSTimeline/*']
  s.requires_arc = true
  
end
