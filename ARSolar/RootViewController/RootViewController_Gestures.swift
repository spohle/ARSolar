//
//  RootViewController_Gestures.swift
//  ARSolar
//
//  Created by Sven Pohle on 6/27/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension RootViewController: UIGestureRecognizerDelegate {

    enum TouchType {
        case tapped
        case began
        case ended
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let location = touches.first?.location(in: uiARView) else { return }
    }
    
    private func touch(type: TouchType, location: CGPoint) {
        
    }
    
    func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
        let hits = uiARView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        if hits.count <= 0 { return nil }
        guard let firstHit = hits.first else { return nil }
//        guard let identifier = firstHit.anchor?.identifier else { return nil }
//        let plane = planes[identifier]
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
        plane.isHidden = true
    }
}
