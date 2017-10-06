//
//  VirtualObject.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-05.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class VirtualObject: SCNNode {
    
    var id: String
    var anchor: ARAnchor
    
    var virtualButtonsContainer: VirtualButtonsContainer?
    var animationNodes = [String: SCNNode]()
    
    lazy var fileUrl: URL? = {
        
//        let fileManager = FileManager()
//        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(id)")
//        var url: URL? = nil
//
//        let enumerator = fileManager.enumerator(at: baseUrl, includingPropertiesForKeys: nil)
//
//        while let element = enumerator?.nextObject() as? URL {
//            if (element.pathExtension == "scn" || element.pathExtension == "dae") {
//                url = element
//                break
//            }
//        }
        let url = Bundle.main.urls(forResourcesWithExtension: "dae", subdirectory: "art.scnassets/Battery")?.first
        
        return url
    }()
    
    init(id: String, anchor: ARAnchor) {
        self.id = id
        self.anchor = anchor
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        
        guard let url = fileUrl else {
            // no scene file
            fatalError("No dae or scn file found!")
        }
        
        let source = SCNSceneSource(url: url, options: nil)
        let scene = source?.scene(options: nil)
        
        
        var virtualButtons = [VirtualButton]()
        
        for child in scene!.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            
            if let animationKey = child.animationKeys.first {
                
                animationNodes[animationKey] = child
                virtualButtons.append(createVirtualButtonWithKey(animationKey))
            }
            
            self.addChildNode(child)
        }
        
        let containerAnchor = ARAnchor(transform: anchor.transform.translatedUp(-0.2))
        virtualButtonsContainer = VirtualButtonsContainer(buttons: virtualButtons, anchor: containerAnchor)
    }
    
    private func createVirtualButtonWithKey(_ key: String) -> VirtualButton {
        
        let button = VirtualButton()
        button.title = key
        button.onAction = { [weak self] in
            self?.playAnimation(named: key)
        }
        button.offAction = { [weak self] in
            self?.pauseAnimation(named: key)
        }
        
        button.highlighted = true
        return button
    }
    
    private func playAnimation(named animationName: String) {
        
        print("Animation: \(animationName)")
        
        for child in self.childNodes {
            if let animationPlayer = child.animationPlayer(forKey: animationName) {
                
                if animationPlayer.paused {
                    animationPlayer.play()
                } else {
                    animationPlayer.speed = 1
                }
            }
        }
    }
    
    private func pauseAnimation(named animationName: String) {
        
        print("Animation: \(animationName)")
        
        for child in self.childNodes {
            if let animationPlayer = child.animationPlayer(forKey: animationName) {
                
                animationPlayer.speed = 0
            }
        }
    }
    
}
