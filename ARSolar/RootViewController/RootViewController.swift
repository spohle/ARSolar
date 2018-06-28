//
//  RootViewController.swift
//  ARSolar
//
//  Created by Pohle, Sven on 6/25/18.
//  Copyright © 2018 Pohle, Sven. All rights reserved.
//


import UIKit
import SceneKit
import ARKit


class RootViewController: UIViewController {
    
    var plane: VirtualPlane?
    var solarSystemAdded = false
    var solarSystem = SolarSystem()
    var planeAdded = false
    
    
    let uiARView: ARSCNView = {
       let view = ARSCNView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let uiStatusLabel: UILabel = {
        let label = UILabel()
       
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
}


