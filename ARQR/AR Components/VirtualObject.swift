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
    var loadingNode: SCNParticleSystem?
    
    var animationNodes = [String: SCNNode]()
    
    weak var delegate: VirtualObjectDelegate?
    
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
        let url = Bundle.main.urls(forResourcesWithExtension: "dae", subdirectory: "art.scnassets/Earth")?.first
        
        return url
    }()
    
    init(id: String, anchor: ARAnchor) {
        self.id = id
        self.anchor = anchor
        
        super.init()
        
//        self.load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        
        addLoadingNode()
        
        loadAssets() { error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("LOADED")
            self.removeLoadingNode()
            
        }
    }
    
    private func addLoadingNode() {
        
//        loadingNode = SCNParticleSystem(named: "Loading", inDirectory: "art.scnassets/Loading")
//        self.addParticleSystem(loadingNode!)
        
    }
    
    private func removeLoadingNode() {
        
//        self.removeParticleSystem(loadingNode!)
        
    }
    
    private func loadAssets(_ completionHandler: @escaping (Error?) -> Void) {
        
        let completionHandlerOnMain = { (error: Error?) in
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            
            sleep(2)
            
            self.loadAssetsFromFile()
            completionHandlerOnMain(nil)
            
//            NetworkManager.shared.getObjectInfoWithId(self.id) { objectInfo, error in
//                if let error = error { completionHandlerOnMain(error); return }
//
//                NetworkManager.shared.downloadFileForVirtualObject(objectInfo) { error in
//                    if let error = error { completionHandlerOnMain(error); return }
//
//                    self.loadAssetsFromFile()
//                    completionHandlerOnMain(nil)
//                }
//            }
            
        }
    }
    
    private func loadAssetsFromFile() {
        
        guard let url = fileUrl else {
            // no scene file
            fatalError("No dae or scn file found!")
        }
        
        let source = SCNSceneSource(url: url, options: nil)
        let scene = source?.scene(options: nil)
        
        
        var virtualButtons = [VirtualButton]()
        
        let wrapperNode = SCNNode()
        
        for child in scene!.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            
            if let animationKey = child.animationKeys.first {
                
                animationNodes[animationKey] = child
                virtualButtons.append(createVirtualButtonWithKey(animationKey))
            }
            
            wrapperNode.addChildNode(child)
        }
        

        
        delegate!.prepare(node: wrapperNode) {
            self.addChildNode(wrapperNode)
            
            self.virtualButtonsContainer = VirtualButtonsContainer(buttons: virtualButtons)
            wrapperNode.addChildNode(self.virtualButtonsContainer!)
            self.virtualButtonsContainer?.simdWorldTransform = self.simdWorldTransform.translatedUp(0.0).translatedforward(0.5)
        }
        
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
        
        for child in self.childNodes.first!.childNodes {
            if let animationPlayer = child.animationPlayer(forKey: animationName) {
                
                if animationPlayer.paused {
                    animationPlayer.play()
                } else {
                    animationPlayer.speed = 0.2
                }
            }
        }
    }
    
    private func pauseAnimation(named animationName: String) {
        
        print("Animation: \(animationName)")
        
        for child in self.childNodes.first!.childNodes {
            if let animationPlayer = child.animationPlayer(forKey: animationName) {
                
                animationPlayer.speed = 0
            }
        }
    }
    
}

protocol VirtualObjectDelegate: class  {
    
    func prepare(node: SCNNode, completionHandler: @escaping () -> Void)
}

