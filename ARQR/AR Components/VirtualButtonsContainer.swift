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
    
    init(buttons: [VirtualButton]) {
        super.init()
        
        let width: CGFloat = 0.1 + CGFloat(buttons.count) * 0.1
        let height: CGFloat = 0.1
        
        let skScenewidth: CGFloat = 1000 * width
        let skSceneHeight: CGFloat = 1000 * height
        
        
        let skScene = SKScene(size: CGSize(width: skScenewidth, height: skSceneHeight))
        skScene.backgroundColor = UIColor.clear
        
        
        let plane = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        self.geometry = plane
        
        let billboardYConstraint = SCNBillboardConstraint()
        billboardYConstraint.freeAxes = SCNBillboardAxis.Y
        self.constraints = [billboardYConstraint]
        

        
        for (index,button) in buttons.enumerated() {
            addChildNode(button)
            button.position.z += 0.01
            button.position.y -= Float(index) * 0.055
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
