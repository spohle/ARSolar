//
//  RootViewController_AR.swift
//  ARSolar
//
//  Created by Sven Pohle on 6/27/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import Foundation
import ARKit


extension RootViewController: ARSCNViewDelegate {
    func cleanupARSession() {
        uiARView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        uiARView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uiARView.session.pause()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = ""
        switch camera.trackingState {
        case .normal:
            status = "World Tracking Normal"
        case .limited:
            status = "World Tracking Limited"
        case .notAvailable:
            status = "World Tracking Not Available"
        }
        
        DispatchQueue.main.async {
            self.uiStatusLabel.text = "\(status)"
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if self.plane != nil { return }
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        self.plane = VirtualPlane(anchor: planeAnchor)
        uiARView.scene.rootNode.addChildNode(self.plane!)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let planeAnchor = anchor as? ARPlaneAnchor, let plane = self.planes[planeAnchor.identifier] {
//            plane.updateWithNewAnchor(planeAnchor)
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        if let planeAnchor = anchor as? ARPlaneAnchor, let index = self.planes.index(forKey: planeAnchor.identifier) {
//            planes.remove(at: index)
//            if planes.count <= 0 {
//                currentTrackingStatus = .temporarilyUnavailable
//            }
//        }
    }
}
