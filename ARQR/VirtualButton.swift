//
//  VirtualButton.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-05.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import ARKit

class VirtualButton: SCNNode {
    
    var anchor: ARAnchor?
    
    var title: String?
    var highlighted = false
    
    var action: (() -> Void)?
    
    override init() {
        super.init()
        
        let skScenewidth: CGFloat = 200.0
        let skSceneHeight: CGFloat = 100.0
        
        let spriteKitScene = SKScene(size: CGSize(width: skScenewidth, height: skSceneHeight))
        spriteKitScene.backgroundColor = UIColor.cyan
        
        let imagePlane = SCNPlane(width: 0.2, height: 0.1)
        imagePlane.firstMaterial?.isDoubleSided = true
        imagePlane.firstMaterial?.diffuse.contents = spriteKitScene
        
        self.geometry = imagePlane
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        self.constraints = [billboardConstraint]
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed() {
        action!()
    }
    
    
}
