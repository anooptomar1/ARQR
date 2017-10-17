//
//  QRScanner.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-03.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import UIKit
import Vision

class QRScanner {
    
    typealias QRScanCompletionHandler = ([QRCode]) -> Void
    
    static func scanQRfromPixelBuffer(_ pixelBuffer: CVPixelBuffer, completionHandler: @escaping QRScanCompletionHandler) {
        
        // Create a Barcode Detection Request
        let request = VNDetectBarcodesRequest { (request, error) in
            
            guard let results = request.results as? [VNBarcodeObservation] else { return }
            
            let qrCodes: [QRCode] = results.map{
                
                let payload = $0.payloadStringValue ?? ""
                var rect = $0.boundingBox
                
                // Flip coordinates
                rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
                rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
                
                return QRCode(payload: payload, frame: rect)
            }
            
            // Complete on main thread
            DispatchQueue.main.async {
                completionHandler(qrCodes)
            }
        }
        
        // Process the request in the background
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                request.symbologies = [.QR]
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
                try imageRequestHandler.perform([request])
            } catch {
                // TODO: handle
            }
        }
    }
    
}

struct QRCode {
    var payload: String
    var frame: CGRect
    
    var objectId: String {
        return payload == "0001" ? "be3f2d0d-4654-468c-aea0-6b30c5390078" : "e9cb53f4-731c-4bf5-9523-9f3f8c1591ff"
//        return payload
    }
}
