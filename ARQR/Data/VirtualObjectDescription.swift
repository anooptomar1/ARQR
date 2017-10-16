//
//  VirtualObjectInfo.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-04.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation

class VirtualObjectDescription: Codable {
    
    var id: String
//    var title: String
    var path: String
    
    var filePath: String?
    
    var nodeInformation: [VirtualObjectNodeInformation]
    
    init(id: String, path: String) {
        self.id = id
        self.path = path
        self.nodeInformation = [VirtualObjectNodeInformation]()
    }
}
