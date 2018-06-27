//
//  VirtualBoard.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/27/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import Foundation
import ARKit

class VirtualBoard: SCNNode {
    static let minimumScale: Float = 0.3
    static let maximumScale: Float = 11.0
    static let animationDuration = 5.0
    static let borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    var anchor: ARPlaneAnchor?
    
    var borderIsHidden: Bool = false
    
    var preferredSize: CGSize = CGSize(width: 1.5, height: 1.5) {
        didSet {
            updateBorderAspectRatio()
        }
    }
    var aspectRatio: Float = 1.0
    private var borderIsOpen = false
    private var isAnimating = false
    private var recentPositions: [float3] = []
    private var recentRotationAngles: [Float] = []
    private var anchorsOfVisitedPlanes: Set<ARAnchor> = []
    private let borderNode = SCNNode()
    private var borderSegments: [VirtualBoard.BorderSegment] = []
    
    private lazy var fillPlane: SCNNode = {
       let length = 1 - 2 * BorderSegment.thickness
        let plane = SCNPlane(width: length, height: length)
        let node = SCNNode(geometry: plane)
        node.name = "fillPlane"
        node.opacity = 0.6
        
        let material = plane.firstMaterial!
        material.diffuse.contents = UIImage(named: "gameassets.scnassets/textures/grid.png")
        material.emission.contents = material.diffuse.contents
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        material.isDoubleSided = true
        material.ambient.contents = UIColor.black
        material.lightingModel = .constant
        
        return node
    }()
    
    override init() {
        super.init()
        
        simdScale = float3(VirtualBoard.minimumScale)
        Corner.allCases.forEach { corner in
            Alignment.allCases.forEach { alignment in
                let borderSize = CGSize(width: 1.0, height: CGFloat(aspectRatio))
                let borderSegment = BorderSegment(corner: corner, alignment: alignment, borderSize: borderSize)
                borderSegments.append(borderSegment)
                borderNode.addChildNode(borderSegment)
            }
        }
        
        borderNode.addChildNode(fillPlane)
        borderNode.eulerAngles.x = .pi / 2
        borderNode.isHidden = true
        
        addChildNode(borderNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateBorderAspectRatio() {
    
    }
}
