//
//  VirtualObjectNodeInformation.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-12.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation

class VirtualObjectNodeInformation: Codable {
    
    var name: String
    var imgageUrl: String?
    
    var info: [String: String]
    
    init(name: String) {
        self.name = name
        info = [String: String]()
    }

    
}
