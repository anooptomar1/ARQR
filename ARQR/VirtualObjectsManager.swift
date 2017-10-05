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
    
    func attach(_ anchor: ARAnchor, toVirtualObjectWithId id: String) {
        
        if let virtualObject = virtualObjects.first(where: { $0.id == id }) {
            virtualObject.anchor = anchor
        } else {
            // Object not found
        }
    }
    
    func virtualObjectFromAnchor(_ anchor: ARAnchor) -> VirtualObject? {
        
        return virtualObjects.first{ $0.anchor == anchor }
    }
    
    func loadVirtualObjectFromId(_ id: String, completionHandler: @escaping () -> Void) {
        print("Loading ID: \(id)")
        
        
        self.loadVirtualObjectWithId(id)
        
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
    
    private func loadVirtualObjectWithId(_ id: String) {
        
        let virtualObject = VirtualObject(id: id)
        virtualObject.load()
        
        virtualObjects.append(virtualObject)
    }
}
