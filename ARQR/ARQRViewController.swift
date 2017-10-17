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
    var infoView: InfoView!
    
    var virtualObjectsManager: VirtualObjectsManager!
    
    var processing = false
    
    var floatingHeight: Float = 0.4
    
    var focusedVirtualObject: VirtualObject? = nil
    
    var activeTouches = [UITouch]()
    var initialPinchDistance: CGFloat?
    var initalPinchScale: CGFloat?
}

// MARK: - Lifecycle

extension ARQRViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupResetButton()
        
        virtualObjectsManager = VirtualObjectsManager()
        virtualObjectsManager.sceneView = sceneView
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
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
    
    @objc
    func resetButtonPressed(sender: UIButton) {
        startSession(reset: true)
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        let position = gestureRecognize.location(ofTouch: 0, in: sceneView)
        
        
        
        reactOnTap(at: position)
    }
    
    private func reactOnTap(at point: CGPoint) {
        
        let hitTestResults = hitTestOnSceneView(at: point)
        
        for result in hitTestResults {
            
            if let button = self.isNodePartOfVirtualbutton(result.node) {
                button.tapped()
                return
            }
            
            if let virtualObject = self.isNodePartOfVirtualObject(result.node), let nodeInformation = virtualObject.informationForNode(result.node) {
                
                presentInformation(nodeInformation: nodeInformation)
                
            }
            
        }
    }
    
    private func virtualObjectOnScreen() -> VirtualObject? {
        
        let center = CGPoint(x: sceneView.bounds.width/2,y: sceneView.bounds.height/2)
        let top = CGPoint(x: sceneView.bounds.width/2,y: sceneView.bounds.height/4)
        let topRight = CGPoint(x: 3*sceneView.bounds.width/4,y: sceneView.bounds.height/4)
        let right = CGPoint(x: 3*sceneView.bounds.width/4,y: sceneView.bounds.height/2)
        let bottomRight = CGPoint(x: 3*sceneView.bounds.width/4,y: 3*sceneView.bounds.height/4)
        let bottom = CGPoint(x: sceneView.bounds.width/2,y: 3*sceneView.bounds.height/4)
        let bottomLeft = CGPoint(x: sceneView.bounds.width/4,y: 3*sceneView.bounds.height/4)
        let left = CGPoint(x: sceneView.bounds.width/4,y: sceneView.bounds.height/2)
        let topLeft = CGPoint(x: sceneView.bounds.width/4,y: sceneView.bounds.height/4)
        
        let points = [center, top, right, bottom, left, topRight, bottomRight, bottomLeft, topLeft]
        
        for point in points {
            
            let hitTestResults = hitTestOnSceneView(at: point)
            
            let virtualObject = hitTestResults.lazy.flatMap { result in
                self.isNodePartOfVirtualObject(result.node)
            }.first
            
            if let virtualObject = virtualObject {
                return virtualObject
            }
            
        }
        
        return nil
    }
    
    private func hitTestOnSceneView(at point: CGPoint) -> [SCNHitTestResult] {
        
        let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
        let hitTestResults: [SCNHitTestResult] = sceneView.hitTest(point, options: hitTestOptions)
        
        return hitTestResults
        
    }
    
    func isNodePartOfVirtualbutton(_ node: SCNNode) -> VirtualButton? {
        if let virtualButton = node as? VirtualButton {
            return virtualButton
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualbutton(node.parent!)
        }
        
        return nil
    }
    
    func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
        if let virtualObject = node as? VirtualObject {
            return virtualObject
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualObject(node.parent!)
        }
        
        return nil
    }
    
    func presentInformation(nodeInformation: VirtualObjectNodeInformation) {
        
        
        infoView = InfoView(information: nodeInformation)
        infoView.alpha = 0
        infoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoView)
        
        NSLayoutConstraint.activate([
            
            infoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            infoView.topAnchor.constraint(equalTo: view.topAnchor),
            infoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            infoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
            ])
        
        UIView.animate(withDuration: 0.3) {
            self.infoView.alpha = 1
            self.infoView.effect = UIBlurEffect(style: .dark)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        print(touches.count)
        
        activeTouches.append(contentsOf: touches)
        
        if focusedVirtualObject == nil {
            focusedVirtualObject = virtualObjectOnScreen()
        }
        
        if activeTouches.count == 2 {
            
            initialPinchDistance = activeTouches[0].location(in: self.sceneView).distanceTo(point: activeTouches[1].location(in: self.sceneView))
            initalPinchScale = CGFloat(focusedVirtualObject?.scale.x ?? 1.0)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if activeTouches.count == 1 {
            if let virtualObject = focusedVirtualObject, touches.count == 1, let touch = touches.first {
                let locationInView = touch.location(in: self.sceneView)
                let previousLocation = touch.previousLocation(in: self.sceneView)
                
                let translation = locationInView.x - previousLocation.x
                let degreesHorizontal =  translation / CGFloat(200)
                
                virtualObject.rotateObject(degreesHorizontal: degreesHorizontal, degreesVertical: 0.0)
            }
            
        } else if activeTouches.count == 2 {
            
            let distance = activeTouches[0].location(in: self.sceneView).distanceTo(point: activeTouches[1].location(in: self.sceneView))
            let scale = distance/initialPinchDistance!
            
         let scaled = focusedVirtualObject?.scaleObject(scale: scale * initalPinchScale!)
            
            if let scaled = scaled, scaled == false {
                initialPinchDistance = distance
                initalPinchScale = CGFloat(focusedVirtualObject!.scale.x)
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let index = activeTouches.index(of: touch)!
            activeTouches.remove(at: index)
        }
        
        if activeTouches.count == 0 {
            focusedVirtualObject = nil
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("cancelled")
        
        for touch in touches {
            let index = activeTouches.index(of: touch)!
            activeTouches.remove(at: index)
        }
        
        if activeTouches.count == 0 {
            focusedVirtualObject = nil
        }
    }
}


// MARK: - ARSCNViewDelegate

extension ARQRViewController: ARSCNViewDelegate {
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let object = virtualObjectsManager.virtualObjectFromAnchor(anchor)
        
        if let object = object {
            print("node found")
        }
        
        return object
        
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
        
        let virtualObject = virtualObjectsManager.loadVirtualObjectFromId(newQRCode.objectId, withAnchor: anchor)
        sceneView.session.add(anchor: virtualObject.anchor)
        processing = false
        
        

        
    }
    
    private func anchorOnPlaneBehind(_ qrCode: QRCode, in frame: ARFrame) -> ARAnchor? {
        
        let center = CGPoint(x: qrCode.frame.midX, y: qrCode.frame.midY)
        let hitTestResults = frame.hitTest(center, types: [.featurePoint/*, .estimatedHorizontalPlane, .existingPlane, .existingPlaneUsingExtent*/] )
        
        guard let hitTestResult = hitTestResults.first else { return nil } // No plane
        
        return ARAnchor(transform: hitTestResult.worldTransform.translatedUp(floatingHeight))
    }
}
