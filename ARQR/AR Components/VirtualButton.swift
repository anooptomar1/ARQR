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
    
    var backgroundImageNode: SKSpriteNode
    var title: String?
    var highlighted = false {
        didSet {
            updateButtonState()
        }
    }
    
    var onAction: (() -> Void)?
    var offAction: (() -> Void)?
    
    override init() {
        
        let width: CGFloat =  0.1
        let height: CGFloat = 0.05
        
        let skScenewidth: CGFloat = 5000 * width
        let skSceneHeight: CGFloat = 5000 * height
        
        let spriteKitScene = SKScene(size: CGSize(width: skScenewidth, height: skSceneHeight))
        spriteKitScene.backgroundColor = UIColor.clear
        
        backgroundImageNode = SKSpriteNode(color: .clear, size: spriteKitScene.size)
        spriteKitScene.addChild(backgroundImageNode)
        backgroundImageNode.position = CGPoint(x: skScenewidth/2, y: skSceneHeight/2)
        
        let label = SKLabelNode()
        label.text = "Rotate"
        label.fontSize = 100
        label.fontName = UIFont.boldSystemFont(ofSize: 100).fontName
        label.yScale = -1
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        spriteKitScene.addChild(label)
        label.position = CGPoint(x: skScenewidth/2, y: skSceneHeight/2)
        
        let imagePlane = SCNPlane(width: width, height: height)
        imagePlane.firstMaterial?.diffuse.contents = spriteKitScene
        
        super.init()
        
        self.updateButtonState()
        self.geometry = imagePlane
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapped() {
        if highlighted {
            
            offAction?()
            highlighted = false
            
        } else {
            
            onAction?()
            highlighted = true
        }
    }
    
    private func updateButtonState() {
        
        let image = highlighted ? #imageLiteral(resourceName: "rounded_green") : #imageLiteral(resourceName: "rounded_gray")
        let imageTexture = SKTexture(image: image)
        backgroundImageNode.texture = imageTexture
        
    }
    
    
}
