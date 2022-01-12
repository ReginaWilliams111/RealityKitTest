//
//  ViewController.swift
//  TestRealityKit1
//
//  Created by Regina Williams on 1/9/22.
//

// tutorial followed: https://www.youtube.com/watch?v=8l3J9lwaecY&t=676s

//  possible alternative? https://developer.apple.com/documentation/arkit/previewing_a_model_with_ar_quick_look

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    //  resource downloaded from apple site
    //  https://developer.apple.com/augmented-reality/quick-look/
    let planterAsset = "cup_saucer_set"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        setupARView()
        
        //  next, let's add a tap recognizer, and see if the user is tapping on a recognizable surface
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
    }
    
    func setupARView() {
        //  1. disable automatic configuration
        arView.automaticallyConfigureSession = false
        
        // 2. let's create our own configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
        //  this will make our objects look as realistic as possible
        configuration.environmentTexturing = .automatic
        
        //  run the new configuration
        arView.session.run(configuration)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        //  get the location in the ar view
        let location = recognizer.location(in: arView)
        
        //  Next we want to find out if the tap location intersects with any of our planes
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        //  now let's found out if we hit anything:
        if let firstResult = results.first {
            //  when we place new objects in our scenes, we always have to attach them to anchors
            let newAnchor = ARAnchor(name: planterAsset, transform: firstResult.worldTransform)
            
            // add the anchor to our session:
            arView.session.add(anchor: newAnchor)
        } else {
            print("Not able to find surface to place object")
        }
    }
    
    func placeObject(name entityName: String, for anchor: ARAnchor) {
        //  next create a model entity (all objects in ar scene are entities
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        //  add gesture animation to our models
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        //  next create an anchor entity
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        //  next add it to my scene
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController : ARSessionDelegate {
    //  we are adding an anchor to our session. now we want to place it when it gets added:
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name,
                anchorName == planterAsset {
                placeObject(name: anchorName, for: anchor)
            }
        }
    }
}
