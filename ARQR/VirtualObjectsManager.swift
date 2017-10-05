//
//  VirtualObjectsManager.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-03.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import ARKit

class VirtualObjectsManager {
    
    private let basePath = "art.scnassets"
    
    // Maps IDs to ARAnchors and Scene nodes
    private var arAnchors = [String: ARAnchor]()
    private var sceneNodes = [String: SCNNode]()
    
    func clearObjects() {
        arAnchors.removeAll()
        sceneNodes.removeAll()
    }
    
    func hasObjectwithId(_ id: String) -> Bool {
        return arAnchors.keys.contains(id)
    }
    
    func add(_ anchor: ARAnchor, withId id: String) {
        arAnchors[id] = anchor
    }
    
    func sceneNodeFromAnchor(_ anchor: ARAnchor) -> SCNNode? {
        
        let id = arAnchors.keys.first{ arAnchors[$0] == anchor }
        
        if let id = id {
            return sceneNodes[id]
        } else {
            return nil
        }
    }
    
    func loadSceneNodeFromId(_ id: String, completionHandler: @escaping () -> Void) {
        print("Loading ID: \(id)")
        
        
        self.loadSceneFileWithId(id)
        
        DispatchQueue.main.async {
            completionHandler()
        }
        
//        NetworkManager.shared.getObjectInfoWithId(id) { objectInfo in
//
//            NetworkManager.shared.downloadFileForVirtualObject(objectInfo) { error in
//
//                self.loadSceneFileWithId(id)
//
//                DispatchQueue.main.async {
//                    completionHandler()
//                }
//
//            }
//
//        }
    }
    
    private func loadSceneFileWithId(_ id: String) {
        
//        let fileManager = FileManager()
//
//        let baseUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(id)")
//        var fileUrl: URL? = nil
//
//        let enumerator = fileManager.enumerator(at: baseUrl, includingPropertiesForKeys: nil)
//
//        while let element = enumerator?.nextObject() as? URL {
//            if (element.pathExtension == "scn" || element.pathExtension == "dae") {
//                fileUrl = element
//                break
//            }
//        }
        
        let fileUrl = Bundle.main.urls(forResourcesWithExtension: "dae", subdirectory: "\(basePath)/Battery")?.first
        
        
        guard let url = fileUrl else {
            // no scene file
            
            return
        }
        
        let source = SCNSceneSource(url: url, options: nil)
        let scene = source?.scene(options: nil)
        
        let wrapperNode = SCNNode()
        
        for child in scene!.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            //            child.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
            
            wrapperNode.addChildNode(child)
        }
        
        self.sceneNodes[id] = wrapperNode
        
    }
    
}
