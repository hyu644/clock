//
//  ViewController.swift
//  Clock
//
//  Created by cmStudent on 2020/01/09.
//  Copyright © 2020 cmStudent. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum TimerStatus {
        case started, paused, stopped
    }
    
    @IBOutlet weak var minuteHand: UIImageView!
    @IBOutlet weak var hourHand: UIImageView!
    @IBOutlet weak var secondHand: UIImageView!
    @IBOutlet weak var hourHand24: UIImageView!
    
    @IBOutlet weak var stopWatchHand: UIImageView!
    @IBOutlet weak var stopWatchCounter: UIImageView!
    
    @IBOutlet weak var headImage: UIImageView!
    
    @IBOutlet weak var stopWatchControlButton: UIButton!
    
    var startTransform = CGAffineTransform.identity
    
    var timerStatus = TimerStatus.stopped
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.driveClock(_:)), userInfo: nil, repeats: true)
    }
    
    // MARK: Timer
    @objc private func driveClock(_ timer: Timer) {
        
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.hour, .minute, .second], from: today)
        
        let hour = todayComponents.hour ?? 0
        let min = todayComponents.minute ?? 0
        let sec = todayComponents.second ?? 0
        
        let fineHour = (CGFloat(hour % 12)) + CGFloat(min) / 60.0
        
        hourHand.transform = createAffineTransform(from: fineHour, component: 12)
        hourHand24.transform = createAffineTransform(from: CGFloat(hour), component: 24)
        minuteHand.transform = createAffineTransform(from: CGFloat(min), component: 60)
        secondHand.transform = createAffineTransform(from: CGFloat(sec), component: 60)
    }

    // MARK: IBAction
    @IBAction func stopWatchControlButtonTapped(_ sender: UIButton) {
        
        switch timerStatus {

        case .started:
            pause(layer: stopWatchHand.layer)
            pause(layer: stopWatchCounter.layer)
            timerStatus = .paused
            stopWatchControlButtonTextChange(title: "Resume")
            
        case .paused:
            resume(layer: stopWatchHand.layer)
            resume(layer: stopWatchCounter.layer)
            timerStatus = .started
            stopWatchControlButtonTextChange(title: "Pause")
            
        case .stopped:
            stopWatchStart()
            timerStatus = .started
            stopWatchControlButtonTextChange(title: "Pause")
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        resume(layer: stopWatchHand.layer)
        resume(layer: stopWatchCounter.layer)
        
        stopWatchHand.layer.removeAnimation(forKey: "rotationAnimation")
        stopWatchCounter.layer.removeAnimation(forKey: "rotationAnimation")
        
        timerStatus = .stopped
        stopWatchControlButtonTextChange(title: "Start")
    }

    @IBAction func rotateImage(_ sender: UIRotationGestureRecognizer) {
        if(sender.state == UIGestureRecognizer.State.began) {
            startTransform = headImage.transform
        }
        
        headImage.transform = startTransform.rotated(by: sender.rotation)
    }
    
    // MARK: Private
    private func createAffineTransform(from time: CGFloat, component: CGFloat) -> CGAffineTransform {
        let rotationAngle = CGFloat(Double.pi) * 2 * time / component
        return CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    private func stopWatchStart() {
        
        setStopWatchHandAnimation()
        setStopWatchCounterAnimation()
    }
    
    private func pause(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    private func resume(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    private func stopWatchControlButtonTextChange(title: String) {
        stopWatchControlButton.setTitle(title, for: [])
    }
    
    private func setStopWatchHandAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        stopWatchHand.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func setStopWatchCounterAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        rotationAnimation.toValue = CGFloat(Double.pi / 180) * 360
        rotationAnimation.duration = 60.0
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        stopWatchCounter.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
