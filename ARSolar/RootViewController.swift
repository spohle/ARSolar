//
//  RootViewController.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/25/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//


import UIKit
import ARKit

enum ARWorldTrackingState: String, CustomStringConvertible {
    case initialized = "initialized", ready = "ready", temporarilyUnavailable = "temporarily unavailable", failed = "failed"
    
    var description: String {
        switch self {
        case .initialized:
            return "Look for a plane to place your objects on"
        case .ready:
            return "Click on any Plane"
        case .temporarilyUnavailable:
            return "Tracking unavailable. Please wait"
        case .failed:
            return "Tracking Failed"
        }
    }
}

// MARK: ViewController METHODS
class RootViewController: UIViewController {
    
    let uiARView: ARSCNView = {
       let view = ARSCNView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let uiStatusLabel: UILabel = {
        let label = UILabel()
       
        label.text = ARWorldTrackingState.temporarilyUnavailable.description
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var planes = [UUID:VirtualPlane]()
    var solarSystemAdded = false
    var solarSystem = SolarSystem()
    
    var currentTrackingStatus = ARWorldTrackingState.initialized {
        didSet {
            DispatchQueue.main.async {
                self.uiStatusLabel.text = self.currentTrackingStatus.description
            }
            if currentTrackingStatus == .failed {
                cleanupARSession()
            }
        }
    }
    
    func cleanupARSession() {
        uiARView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    fileprivate func setupUserInterface() {
        view.addSubview(uiARView)
        uiARView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        uiARView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        uiARView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        uiARView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        view.addSubview(uiStatusLabel)
        uiStatusLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        uiStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uiStatusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        uiStatusLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        
        uiARView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        uiARView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Ignoring Interaction...")
            return
        }
        
        if currentTrackingStatus != .ready {
            print("Planes are not detected yet!")
            return
        }
        
        let touchPoint = touch.location(in: uiARView)
        if let plane = virtualPlaneProperlySet(touchPoint: touchPoint) {
            print("Plane touched: \(plane)")
            addSolarSystemToPlane(plane: plane, atPoint: touchPoint)
        }
    }
    
    func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
        let hits = uiARView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        if hits.count <= 0 { return nil }
        guard let firstHit = hits.first else { return nil }
        guard let identifier = firstHit.anchor?.identifier else { return nil }
        let plane = planes[identifier]
        return plane
    }
    
    func addSolarSystemToPlane(plane: VirtualPlane, atPoint point: CGPoint) {
        let hits = uiARView.hitTest(point, types: .existingPlaneUsingExtent)
        if hits.count <= 0 { return }
        guard let firstHit = hits.first else { return }
        if solarSystemAdded == true { return }
        
        let worldTransform = firstHit.worldTransform
        let pos = worldTransform.columns.3
        solarSystem.position = SCNVector3Make(pos.x, pos.y + 0.2, pos.z)
        solarSystem.scale = SCNVector3Make(0.1, 0.1, 0.1)
        uiARView.scene.rootNode.addChildNode(solarSystem)
        solarSystemAdded = true
    }
}

// MARK: AR SCENE VIEW DELEGATE METHODS
extension RootViewController: ARSCNViewDelegate {
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (anchor is ARPlaneAnchor) {
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            currentTrackingStatus = .ready
            
            let plane = VirtualPlane(anchor: planeAnchor)
            self.planes[planeAnchor.identifier] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, let plane = self.planes[planeAnchor.identifier] {
            plane.updateWithNewAnchor(planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, let index = self.planes.index(forKey: planeAnchor.identifier) {
            planes.remove(at: index)
            if planes.count <= 0 {
                currentTrackingStatus = .temporarilyUnavailable
            }
        }
    }
}
