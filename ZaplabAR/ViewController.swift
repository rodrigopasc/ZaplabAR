//
//  ViewController.swift
//  ZaplabAR
//
//  Created by Rodrigo Paschoaletto on 27/04/2019.
//  Copyright © 2019 Rodrigo Paschoaletto. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    let configuration = ARWorldTrackingConfiguration()
    
    @IBOutlet weak var sceneARView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSettings()
        setupPlaneDetection()
        setupDebugOptions()
        playARScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneARView.session.pause()
    }
    
    // MARK: Initial setup functions.
    
    func setupSettings() {
        sceneARView.delegate = self
        sceneARView.showsStatistics = false
        sceneARView.autoenablesDefaultLighting = true
        sceneARView.automaticallyUpdatesLighting = true
    }
    
    func setupPlaneDetection() {
        configuration.planeDetection = [.horizontal, .vertical]
    }
    
    func setupDebugOptions() {
        sceneARView.debugOptions = [ARSCNDebugOptions.showSkeletons, ARSCNDebugOptions.showCreases, ARSCNDebugOptions.showFeaturePoints]
    }
    
    func playARScene() {
        sceneARView.session.run(configuration)
    }
}

extension ViewController: ARSCNViewDelegate {
    // MARK: Callback to detected anchors.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let worldPlaneAnchor = anchor as? ARPlaneAnchor else { return }
        
        let detectedScenePlane = setupNewDetectedScene(anchor: worldPlaneAnchor)
        let detectedNodePlane = setupNewDetectedNode(scenePlane: detectedScenePlane, anchor: worldPlaneAnchor)
        
        node.addChildNode(detectedNodePlane)
    }
    
    // MARK: Setup its detected plane for the anchor.
    func setupNewDetectedScene (anchor: ARPlaneAnchor) -> SCNPlane {
        // Get dimensions of its detected plane.
        let detectedPlaneWidth = CGFloat(anchor.extent.x)
        let detectedPlaneHeight = CGFloat(anchor.extent.z)
        
        // Setup a Scene Plane with those dimensions.
        let detectedPlane = SCNPlane(width: detectedPlaneWidth, height: detectedPlaneHeight)
        
        // Set a custom green color to appear in the detected area.
        detectedPlane.materials.first?.diffuse.contents = UIColor.myCustomLightGreen
        
        return detectedPlane
    }
    
    // MARK: Setup the node for the detected area.
    func setupNewDetectedNode(scenePlane: SCNPlane, anchor: ARPlaneAnchor) -> SCNNode {
        // Setup a node with the geometry size of the detected scene.
        let detectedPlaneNode = SCNNode(geometry: scenePlane)
        
        // Setup size dimensions of the brand new detected node.
        let detectedPlaneXSizeShallBe = CGFloat(anchor.center.x)
        let detectedPlaneYSizeShallBe = CGFloat(anchor.center.y)
        let detectedPlaneZSizeShallBe = CGFloat(anchor.center.z)
        
        // Setup node's position as where it was detected.
        detectedPlaneNode.position = SCNVector3(detectedPlaneXSizeShallBe, detectedPlaneYSizeShallBe, detectedPlaneZSizeShallBe)
        
        // This is importante to push 90 degrees down so you can see as a plane, not as a wall.
        detectedPlaneNode.eulerAngles.x = -.pi / 2
        
        return detectedPlaneNode
    }
}

extension UIColor {
    open class var myCustomLightGreen: UIColor {
        return UIColor(red: 92/255, green: 214/255, blue: 92/255, alpha: 0.40)
    }
}

