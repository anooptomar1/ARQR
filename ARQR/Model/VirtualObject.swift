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
    var animations = [String]()
    
    
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
        
        for child in scene!.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            
            if let animationKey = child.animationKeys.first {
                animations.append(animationKey)
            }
            
            self.addChildNode(child)
            
        }
        
        var virtualButtons = [VirtualButton]()
        
        for key in animations {
            
            let button = VirtualButton()
            button.title = key
            button.action = {
                self.playAnimation(named: key)
            }
           
            virtualButtons.append(button)
        }
        
        let containerAnchor = ARAnchor(transform: anchor.transform.translatedUp(-0.2))
        virtualButtonsContainer = VirtualButtonsContainer(buttons: virtualButtons, anchor: containerAnchor)
        
        
    }
    
    func playAnimation(named animationName: String) {
        
        
        
    }
    
}
