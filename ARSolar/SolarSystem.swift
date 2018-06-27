//
//  SolarSystem.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/27/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import Foundation
import ARKit

class SolarSystem: SCNNode {
    override init() {
        super.init()
        self.createSystem()
        self.addChildNode(solarRootNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    var solarRootNode: SCNNode = SCNNode()
    
    func createSystem() {
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
    }
}
