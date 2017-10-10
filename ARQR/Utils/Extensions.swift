//
//  Extensions.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-03.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

extension simd_float4x4 {
    
    func translatedUp(_ height: Float) -> simd_float4x4 {
        
        var translation = matrix_identity_float4x4
        translation.columns.3.y = height
        
        return matrix_multiply(self, translation)
    }
    
    func translatedforward(_ distance: Float) -> simd_float4x4 {
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = distance
        
        return matrix_multiply(self, translation)
    }
    
}

extension simd_float4x4 {
    
    func xyz() -> String {
        
        return "x:\(self.columns.3.x) y:\(self.columns.3.y) z:\(self.columns.3.z)"
        
    }


}

extension simd_float3 {
    
    func addHeight(_ translation: Float) -> simd_float3 {
        
        return simd_float3(self.x, self.y + translation, self.z)
        
    }
    
    func moveForward(_ translation: Float) -> simd_float3 {
        
        return simd_float3(self.x, self.y, self.z + translation)
        
    }
    
}

extension SCNVector3 {
    
    func addHeight(_ translation: Float) -> SCNVector3 {
        
        return SCNVector3(self.x, self.y + translation, self.z)
        
    }
    
    func moveForward(_ translation: Float) -> SCNVector3 {
        
        return SCNVector3(self.x, self.y, self.z + translation)
        
    }
    
}
