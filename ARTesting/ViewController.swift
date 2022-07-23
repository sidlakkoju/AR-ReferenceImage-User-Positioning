
import UIKit
import RealityKit
import ARKit
import simd
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblAngle: UILabel!
    
    @IBOutlet weak var lblUserPosition: UILabel!
    @IBOutlet weak var lblAnchorPosition: UILabel!
    
    var userPosition = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
    
    
    var parentAnchor = AnchorEntity()
    let worldOriginAnchor = AnchorEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configure()
        
        
        
    }
    
    func configure() {
        let session = arView.session
        session.delegate = self
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        // Set up reference images
        guard let refImg = ARReferenceImage.referenceImages(inGroupNamed: "Reference Images", bundle: nil)
        else { fatalError("Error Loading Images") }
        config.detectionImages = refImg
        config.maximumNumberOfTrackedImages = 0 // Test w/ 0 (results in infrequent image pose updates)
        
        arView.debugOptions = [.showWorldOrigin]
        
        session.run(config)
        
        arView.scene.addAnchor(worldOriginAnchor)
    }

}


extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.userPosition.x = frame.camera.transform.columns.3.x
        self.userPosition.y = frame.camera.transform.columns.3.y
        self.userPosition.z = frame.camera.transform.columns.3.z
        
        lblUserPosition.text = "User: (\(round(userPosition.x*10)/10), \(round(userPosition.z*10)/10))"
        lblAnchorPosition.text =  "Anchor: (\(round(parentAnchor.transform.translation.x*10)/10), \(round(parentAnchor.transform.translation.x*10)/10)"
        lblAngle.text = "Angle: \(round(getUserHeading()*10)/10)"
        lblPosition.text = "Distance: \(round(getUserDistance()*10)/10)"
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                print("reference image detected")
                updateParentAnchor(matrix: imageAnchor.transform)
                addCoordinates()
                arView.scene.addAnchor(parentAnchor)
            }
        }
    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                updateParentAnchor(matrix: imageAnchor.transform)
            }
        }
    }
    
}

extension ViewController {
    
    func updateParentAnchor(matrix: simd_float4x4) {
        self.parentAnchor.transform = Transform(matrix: matrix)
        self.parentAnchor.transform.rotation = self.parentAnchor.transform.rotation.getYRotation() // Keeps information reguarding only rotation about y axis
    }
    
    
    func getUserDistance() -> Float {
        
        let xVariance = self.userPosition.x - self.parentAnchor.transform.translation.x
        let zVariance = self.userPosition.z - self.parentAnchor.transform.translation.z
        
        return sqrt((xVariance*xVariance) + (zVariance*zVariance))
    }
    
    
    func getUserHeading() -> Float {
        let relativeUserPosition = worldOriginAnchor.convert(position: self.userPosition, to: self.parentAnchor)
        let angle = atan2(relativeUserPosition.x, relativeUserPosition.z)
        return -1*angle
    }
    
    
    func addCoordinates() {
        var cancel: AnyCancellable? = nil
        cancel = ModelEntity.loadAsync(named: "Test Coordinates")
            .sink(receiveCompletion: { error in
                print("Error loading entity \(error)")
                cancel?.cancel()
            }, receiveValue: { model in
                self.parentAnchor.addChild(model)
                cancel?.cancel()
            })
    }
    
    
    
}


extension simd_quatf {
    func getYRotation() -> simd_quatf {
        let qfloat = self.vector    // Gives the four values of a quaternion as a vector: [x, y, z, w]
        let theta = atan2(qfloat.y, qfloat.w)
        return simd_quatf(ix: 0, iy: sin(theta), iz: 0, r: cos(theta))
    }
}

