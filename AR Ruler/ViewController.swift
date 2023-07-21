import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var pointArray = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pointArray.count >= 2 {
            for point in pointArray {
                point.removeFromParentNode()
            }
            pointArray = [SCNNode]()
        }
        
        if let location = touches.first?.location(in: sceneView) {
            guard let hitTest = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .any) else {
               return
            }
            let results = sceneView.session.raycast(hitTest)
            
            if let hitResult = results.first {
                addPoint(at: hitResult)
            }
        }
    }
    
    func addPoint(at hitResult : ARRaycastResult) {
        let column = hitResult.worldTransform.columns
        let geometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        geometry.materials = [material]
        
        let dotNode = SCNNode(geometry: geometry)
        dotNode.position = SCNVector3(x: column.3.x, y: column.3.y, z: column.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        pointArray.append(dotNode)
        
        if pointArray.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let start = pointArray[0]
        let end = pointArray[1]
        
        let x = start.position.x - end.position.x
        let y = start.position.y - end.position.y
        let z = start.position.z - end.position.z
        
        let distance = sqrt(pow(x,2) + pow(y,2) + pow(z,2))
        updateText(text: "\(abs(distance))", position: end.position)
    }
    
    func updateText(text : String, position : SCNVector3) {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 2.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.001, 0.001, 0.001)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }

  
}
