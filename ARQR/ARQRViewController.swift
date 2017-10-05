//
//  ViewController.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-03.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARQRViewController: UIViewController {

    // MARK: - Properties
    
    var sceneView: ARSCNView!
    var resetButton: UIButton!
    
    var virtualObjectsManager: VirtualObjectsManager!
    
    var processing = false
    
    var floatingHeight: Float = 0.5
}

// MARK: - Lifecycle

extension ARQRViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        virtualObjectsManager = VirtualObjectsManager()
        
        setupSceneView()
        setupResetButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pauseSession()
    }
    
    private func setupSceneView() {
        
        sceneView = ARSCNView()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
    private func setupResetButton() {
        
        resetButton = UIButton()
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action:#selector(resetButtonPressed), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            resetButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            resetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            resetButton.heightAnchor.constraint(equalToConstant: 10.0),
//            resetButton.widthAnchor.constraint(equalToConstant: 30)
            ])
        
        
        
    }
    
    private func startSession(reset: Bool = false) {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if reset {
            virtualObjectsManager.clearObjects()
            sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        } else {
            sceneView.session.run(configuration)
        }
    }
    
    private func pauseSession() {
        sceneView.session.pause()
    }
    
    @objc func resetButtonPressed(sender: UIButton) {
        
        startSession(reset: true)
        
    }
}

// MARK: - ARSCNViewDelegate

extension ARQRViewController: ARSCNViewDelegate {
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        return virtualObjectsManager.virtualObjectFromAnchor(anchor)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - ARSessionDelegate

extension ARQRViewController: ARSessionDelegate {
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if processing { return }
        processing = true
        
        QRScanner.scanQRfromPixelBuffer(frame.capturedImage) { qrCodes in
            
            let newQRCodes = qrCodes.filter { !self.virtualObjectsManager.hasObjectwithId($0.objectId) }
            
            guard let newQRCode = newQRCodes.first else {
                // No new code
                self.processing = false
                return
            }
            
            self.process(newQRCode, in: frame)
        }
    }
    
    private func process(_ newQRCode: QRCode, in frame: ARFrame) {
        
        guard let anchor = anchorOnPlaneBehind(newQRCode, in: frame) else {
            // No plane found
            self.processing = false
            return
        }
        
        self.virtualObjectsManager.loadVirtualObjectFromId(newQRCode.objectId) {
            self.virtualObjectsManager.attach(anchor, toVirtualObjectWithId: newQRCode.objectId)
            self.sceneView.session.add(anchor: anchor)
            self.processing = false
        }
    }
    
    private func anchorOnPlaneBehind(_ qrCode: QRCode, in frame: ARFrame) -> ARAnchor? {
        
        // Get bottom center
        let center = CGPoint(x: qrCode.frame.midX, y: qrCode.frame.maxY)
        
        // Perform a hit test on the ARFrame to find a surface
        let hitTestResults = frame.hitTest(center, types: [.featurePoint/*, .estimatedHorizontalPlane, .existingPlane, .existingPlaneUsingExtent*/] )
        
        guard let hitTestResult = hitTestResults.first else { return nil } // No plane
        
        // Create an anchor. The node will be created in delegate methods
        return ARAnchor(transform: hitTestResult.worldTransform.translatedUp(floatingHeight))
        
        
    }
    
}
