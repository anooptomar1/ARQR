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

fileprivate let minimumHitArea = CGSize(width: 44, height: 44)

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }
        
        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        
        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}

extension SCNNode {
    
    func rotateObject(degreesHorizontal: CGFloat, degreesVertical: CGFloat) {
        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(degreesHorizontal), z: CGFloat(degreesVertical), duration: 0.01)
        self.runAction(rotateAction)
    }
    
    func scaleObject(scale: CGFloat) -> Bool {
        
        guard scale > 0.5 && scale < 3 else { return false }
        
        let scaleAction = SCNAction.scale(to: scale, duration: 0.01)
        self.runAction(scaleAction)
        return true
    }
    
}

extension CGPoint {
    
    func distanceTo(point: CGPoint) -> CGFloat {
        
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        
    }
    
}
