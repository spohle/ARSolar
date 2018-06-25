//
//  RootViewController.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/25/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import UIKit
import ARKit

class RootViewController: UIViewController {
    
    let uiARView: ARSCNView = {
       let view = ARSCNView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var solarRootNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(uiARView)
        uiARView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        uiARView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        uiARView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        uiARView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
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
            
            let gridNode = createAnchorGrid(anchor: planeAnchor)
            node.addChildNode(gridNode)
            
            solarRootNode.position = SCNVector3Make(0, 0.1, 0)
            solarRootNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
            node.addChildNode(solarRootNode)
        }
    }

    func createAnchorGrid(anchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        let geo = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.x))
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "grid.jpg").cgImage!
        material.transparency = 0.5
        geo.materials = [material]
        node.geometry = geo
        node.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        node.rotation = SCNVector4Make(1, 0, 0, -Float.pi/2.0)
        
        return node
    }
}
