//
//  Extensions.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-03.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import Foundation
import ARKit

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
