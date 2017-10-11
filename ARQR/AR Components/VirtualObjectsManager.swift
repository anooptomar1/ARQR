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
    
    
    var sceneView: ARSCNView?
    private var virtualObjects = [VirtualObject]()
    
    func clearObjects() {
        virtualObjects.removeAll()
    }
    
    func hasObjectwithId(_ id: String) -> Bool {
        return virtualObjects.map{ $0.id }.contains(id)
    }
    
    func virtualObjectFromAnchor(_ anchor: ARAnchor) -> SCNNode? {
        
        if let virtualObject = virtualObjects.first(where: { $0.anchor == anchor }) {
            return virtualObject
        } else {
            return nil
        }
    }
    
    func loadVirtualObjectFromId(_ id: String,withAnchor anchor: ARAnchor) -> VirtualObject {
        print("Loading ID: \(id)")
        
        let virtualObject = VirtualObject(id: id, anchor: anchor)
        virtualObject.delegate = self
        virtualObject.load()
        
        virtualObjects.append(virtualObject)
        return virtualObject
        
    }
}

extension VirtualObjectsManager: VirtualObjectDelegate {
    
    func prepare(node: SCNNode, completionHandler: @escaping () -> Void) {
        sceneView!.prepare([node]) { _ in
            
            completionHandler()
            
        }
    }
    
    
    
    
}
