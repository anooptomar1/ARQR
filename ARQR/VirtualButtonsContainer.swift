//
//  VirtualButtonsContainer.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-05.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import ARKit

class VirtualButtonsContainer: SCNNode {
    
    var anchor: ARAnchor
    
    init(buttons: [VirtualButton], anchor: ARAnchor) {
        self.anchor = anchor
        super.init()
        
        let height: CGFloat = 0.1
        let width: CGFloat = CGFloat(buttons.count) * 0.1
        
        let spriteKitScene = SKScene(size: CGSize(width: width*100.0, height: height*100.0))
        spriteKitScene.backgroundColor = UIColor.red
        
        let imagePlane = SCNPlane(width: width, height: height)
        imagePlane.firstMaterial?.isDoubleSided = true
        imagePlane.firstMaterial?.diffuse.contents = spriteKitScene
        
        self.geometry = imagePlane
        
        let billboardYConstraint = SCNBillboardConstraint()
        billboardYConstraint.freeAxes = SCNBillboardAxis.Y
        self.constraints = [billboardYConstraint]
        
        for button in buttons {
            addChildNode(button)
            button.position.z += 0.01
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
