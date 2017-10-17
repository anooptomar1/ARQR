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
    var objectDescription: VirtualObjectDescription?
    
    var virtualButtonsContainer: VirtualButtonsContainer?
    var loadingNode: SCNNode?
    
    var animationNodes = [String: SCNNode]()
    
    weak var delegate: VirtualObjectDelegate?
    
    lazy var baseUrl: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(id)")
    }()
    
    lazy var fileUrl: URL? = {
        
        let fileManager = FileManager()
        var url: URL? = nil

        let enumerator = fileManager.enumerator(at: baseUrl, includingPropertiesForKeys: nil)

        while let element = enumerator?.nextObject() as? URL {
            if (element.pathExtension == "scn" || element.pathExtension == "abc") {
                url = element
                break
            }
        }
//
//        let directory = id == "0001" ? "art.scnassets/SolarSystem" : "art.scnassets/Earth"
//
//        let url = Bundle.main.urls(forResourcesWithExtension: "dae", subdirectory: directory)?.first
        
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
            
            
        }
    }
    
    private func addLoadingNode() {
        
        let sphere = SCNSphere(radius: 0.010)
        
        let material = SCNMaterial()
        material.emission.contents = [UIColor.white]
        material.emission.intensity = 1.0
        
        sphere.firstMaterial = material
        
//        box.firstMaterial?.diffuse.contents = UIColor.blue
        loadingNode = SCNNode(geometry: sphere)
        
        let trail = SCNParticleSystem(named: "fire.scnp", inDirectory: "art.scnassets/Loading")!
        // 3
        trail.particleColor = UIColor.white
        // 4
        trail.emitterShape = sphere
        
//        loadingNode?.addParticleSystem(trail)
        
        self.addChildNode(loadingNode!)
        loadingNode?.simdWorldTransform = self.simdWorldTransform.translatedUp(-0.4)
        
        let moveUp = SCNAction.moveBy(x: 0, y: 0.4, z: 0, duration: 4)
        moveUp.timingMode = .easeInEaseOut
        
        let scaleUp = SCNAction.scale(by: 1.5, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut;
        let scaleDown = SCNAction.scale(by: 1/1.5, duration: 1.0)
        scaleDown.timingMode = .easeInEaseOut;
        let scaleSequence = SCNAction.sequence([scaleUp,scaleDown])
        let scaleLoop = SCNAction.repeatForever(scaleSequence)
        
        loadingNode!.runAction(scaleLoop)
        loadingNode!.runAction(moveUp)
        
    }
    
    private func removeLoadingNode() {
        
        loadingNode?.removeFromParentNode()
        
    }
    
    private func loadAssets(_ completionHandler: @escaping (Error?) -> Void) {
        
        let completionHandlerOnMain = { (error: Error?) in
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            
//            self.objectDescription = VirtualObjectDescription(id: "1", path: "")
//
//            let nodeInformation = VirtualObjectNodeInformation(name: "Earth")
//            nodeInformation.information["Age"] = "4.5 billion years"
//            nodeInformation.information["Population"] = "6 Billion"
//
//            self.objectDescription?.nodeInformation.append(nodeInformation)
            
//            sleep(5)
            
//            self.loadAssetsFromFile()
//            completionHandlerOnMain(nil)
            
            NetworkManager.shared.getObjectInfoWithId(self.id) { objectDescription, error in
                if let error = error { completionHandlerOnMain(error); return }
                self.objectDescription = objectDescription
                
                var isDir = ObjCBool(true)
                if !FileManager.default.fileExists(atPath: self.baseUrl.path, isDirectory: &isDir) {
                    
                    NetworkManager.shared.downloadFileForVirtualObject(objectDescription) { error in
                        if let error = error { completionHandlerOnMain(error); return }
                        
                        self.loadAssetsFromFile()
                        completionHandlerOnMain(nil)
                    }
                } else {
                    
                    sleep(5)
                    
                    self.loadAssetsFromFile()
                    completionHandlerOnMain(nil)
                }
                

            }
            
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
            
            findAnimations(node: child)
            wrapperNode.addChildNode(child)
        }
        
        let playPauseButton = VirtualButton(title: "Rotation")
        playPauseButton.onAction = {
            self.playAllAnimations()
        }
        playPauseButton.offAction = {
            self.pauseAllAnimations()
        }

        virtualButtons.append(playPauseButton)
        
        let orbitsButton = VirtualButton(title: "Orbit")
        orbitsButton.onAction = {
            self.setOpacityOnNodesWithName("Axis", to: 1.0, onBaseNode: self)
        }
        orbitsButton.offAction = {
            self.setOpacityOnNodesWithName("Axis", to: 0.0, onBaseNode: self)
        }
        
        
        
        virtualButtons.append(orbitsButton)
        
        delegate!.prepare(node: wrapperNode) {
            
            self.virtualButtonsContainer = VirtualButtonsContainer(buttons: virtualButtons)
            wrapperNode.addChildNode(self.virtualButtonsContainer!)
            self.virtualButtonsContainer?.simdWorldTransform = wrapperNode.simdWorldTransform.translatedUp(0.30).translatedforward(0.0)
            
            let scaleFactor: CGFloat = 0.1
            wrapperNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
//            wrapperNode.opacity = 0.0
            self.addChildNode(wrapperNode)
            
            let scaleUp = SCNAction.scale(by: 1/scaleFactor, duration: 0.2)
            scaleUp.timingMode = .easeIn;
            
            let fadeIn = SCNAction.fadeIn(duration: 0.1)
            scaleUp.timingMode = .easeInEaseOut;
            
            wrapperNode.runAction(scaleUp)
            wrapperNode.runAction(fadeIn)
            self.virtualButtonsContainer?.runAction(fadeIn)
            
            orbitsButton.tapped()
            self.removeLoadingNode()
        }
        
    }
    
    private func findAnimations(node: SCNNode) {
        
        for animationKey in node.animationKeys {
            animationNodes[animationKey] = node
        }
        
        for childNode in node.childNodes {
            findAnimations(node: childNode)
        }

    }
    
    private func playAllAnimations() {
        
        for key in animationNodes.keys {
            playAnimation(named: key)
        }
        
    }
    
    private func pauseAllAnimations() {
        
        for key in animationNodes.keys {
            pauseAnimation(named: key)
        }
        
    }
    
    private func playAnimation(named animationName: String) {
        
        print("Animation: \(animationName)")
        
        if let node = animationNodes[animationName], let animationPlayer = node.animationPlayer(forKey: animationName) {
            
            if animationPlayer.paused {
                animationPlayer.play()
            } else {
                animationPlayer.speed = 0.8
            }
        }
    }
    
    private func pauseAnimation(named animationName: String) {
        
        if let node = animationNodes[animationName], let animationPlayer = node.animationPlayer(forKey: animationName) {
            
            animationPlayer.speed = 0.0
        }
    }
    
    private func setOpacityOnNodesWithName(_ name: String,to value: CGFloat, onBaseNode node: SCNNode) {
        
        for childNode in node.childNodes {
            if childNode.name?.contains(name) ?? false {
                childNode.opacity = value
            }
            
            setOpacityOnNodesWithName(name, to: value, onBaseNode: childNode)
        }
    }
    
    func informationForNode(_ node: SCNNode) -> VirtualObjectNodeInformation? {
    
        return objectDescription?.info.first {$0.name == node.name}
    }
    
}

protocol VirtualObjectDelegate: class  {
    
    func prepare(node: SCNNode, completionHandler: @escaping () -> Void)
}

