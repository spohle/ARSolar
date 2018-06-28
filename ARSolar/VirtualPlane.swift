//
//  VirtualPlane.swift
//  ARSolar
//
//  Created by Sven Pohle on 6/26/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import Foundation
import ARKit

class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initPlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1.0, 0.0, 0.0)
        
        updatePlaneMaterialDimensions()
        
        self.addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "grid.jpg").cgImage!
        material.transparency = 0.5
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        material.ambient.contents = UIColor.black
        material.lightingModel = .constant
        
        return material
    }
    
    func updatePlaneMaterialDimensions() {
        let material = self.planeGeometry.materials.first!
        
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        updatePlaneMaterialDimensions()
    }
}
