//
//  TinkoffFanWindow.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 27/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class TinkoffFanWindow: UIWindow {
    var emitters: [CAEmitterLayer] = [CAEmitterLayer]()
    
    override func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            if let touches = event.allTouches {
                for touch in touches {
                    if touch.phase == UITouchPhase.began {
                        let pointTap = touch.location(in: self)
                        createEmitter(point: pointTap)
                    } else if touch.phase == .ended {
                        stopEmitter()
                    } else if touch.phase == UITouchPhase.moved {
                        let pointTap = touch.location(in: self)
                        self.emitters.last?.emitterPosition = pointTap
                    }
                }
            }
        }
        
        super.sendEvent(event)
    }
    
    func createEmitter(point: CGPoint) {
        let emitter = CAEmitterLayer()
        let emitterCell = CAEmitterCell()

        emitterCell.scale = 0.1
        emitterCell.name = "tcs"
        emitterCell.lifetime = 5
        emitterCell.velocity = 150
        emitterCell.birthRate = 10
        emitterCell.yAcceleration = 250
        emitter.emitterPosition = point
        emitterCell.emissionRange = .pi * 0.5
        emitterCell.emissionLongitude = .pi * -0.5
        emitter.emitterShape = kCAEmitterLayerSphere
        emitter.beginTime = CACurrentMediaTime() + 0.00001;
        emitterCell.contents = UIImage(named: "tcs_logo32.png")?.cgImage

        emitter.emitterCells = [emitterCell]
        
        self.layer.addSublayer(emitter)
        self.emitters.append(emitter)
    }
    
    func stopEmitter() {
        self.emitters.last?.setValue(0, forKeyPath: "emitterCells.tcs.birthRate")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let emitter = self.emitters[0]
            emitter.removeFromSuperlayer()
            self.emitters.remove(at: 0)
        }
    }
}
