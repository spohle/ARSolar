//
//  RootViewController.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/25/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

// TODO: https://digitalleaves.com/blog/2017/11/augmented-reality-arkit-placing-objects/


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
    
    var solarRootNode: SCNNode = SCNNode()
    var planes = [UUID:VirtualPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        uiARView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        uiARView.delegate = self
        
        self.createSolarSystem()
    }
    
    func createSolarSystem() {
        let names = ["Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
        let sizes = [0.25, 0.04, 0.08, 0.1, 0.06, 0.3, 0.24, 0.18, 0.16]
        let offsets: [Float] = [0.0, 0.4, 0.6, 0.8, 1.0, 1.4, 1.68, 1.95, 2.14]
        let diffuse: [String:CGImage] = ["Sun":UIImage(named: "art.scnassets/textures/sun.jpg")!.cgImage!,
                                         "Mercury":UIImage(named: "art.scnassets/textures/mercury.jpg")!.cgImage!,
                                         "Venus":UIImage(named: "art.scnassets/textures/venus.jpg")!.cgImage!,
                                         "Earth":UIImage(named: "art.scnassets/textures/earth-diffuse.jpg")!.cgImage!,
                                         "Mars":UIImage(named: "art.scnassets/textures/mars.jpg")!.cgImage!,
                                         "Jupiter":UIImage(named: "art.scnassets/textures/jupiter.jpg")!.cgImage!,
                                         "Saturn":UIImage(named: "art.scnassets/textures/saturn.jpg")!.cgImage!,
                                         "Uranus":UIImage(named: "art.scnassets/textures/uranus.jpg")!.cgImage!,
                                         "Neptune":UIImage(named: "art.scnassets/textures/neptune.jpg")!.cgImage!,
                                        ]
        
        var planets: [String:SCNNode] = [:]
        var rotNodes: [String:SCNNode] = [:]
        var fullOffset: Float = 0.0
        for (index, name) in names.enumerated() {
            let node = SCNNode()
            let geom = SCNSphere(radius: CGFloat(sizes[index]))
            let material = SCNMaterial()
            material.diffuse.contents = diffuse[name]
            geom.materials = [material]
            node.geometry = geom
            node.position = SCNVector3Make(fullOffset + offsets[index], 0, 0)
            planets[name] = node
            let rotNode = SCNNode()
            rotNode.addChildNode(node)
            rotNodes[name] = rotNode
            
            let orbitNode = SCNNode()
            orbitNode.opacity = 0.5
            let orbitGeo = SCNPlane(width: 0.5, height: 0.5)
            orbitGeo.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/textures/orbit.png")!.cgImage!
            orbitGeo.firstMaterial?.diffuse.mipFilter = SCNFilterMode.linear // no lighting
            
            solarRootNode.addChildNode(rotNode)
            solarRootNode.addChildNode(orbitNode)
            fullOffset += offsets[index]
        }
        
        // scale the whole thing down to 10%
        solarRootNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
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
        }
    }
}
