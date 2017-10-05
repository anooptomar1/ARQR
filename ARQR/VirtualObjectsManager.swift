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
            return virtualObjects.flatMap{$0.virtualButtons}
                .first{$0.anchor == anchor}
        }
    }
    
    func loadVirtualObjectFromId(_ id: String,withAnchor anchor: ARAnchor, completionHandler: @escaping (VirtualObject) -> Void) {
        print("Loading ID: \(id)")
        
        
        let virtualObject = self.loadVirtualObjectWithId(id, anchor: anchor)
        
        DispatchQueue.main.async {
            completionHandler(virtualObject)
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
    
    private func loadVirtualObjectWithId(_ id: String, anchor: ARAnchor) -> VirtualObject {
        
        let virtualObject = VirtualObject(id: id, anchor: anchor)
        virtualObject.load()
        
        virtualObjects.append(virtualObject)
        return virtualObject
    }
}
