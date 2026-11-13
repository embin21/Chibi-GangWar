
import SwiftUI
import SceneKit

struct GameView: View {
    @State private var moveX: CGFloat = 0
    @State private var moveZ: CGFloat = 0
    @State private var message = "CHIẾM LĨNH THÀNH PHỐ"

    var body: some View {
        ZStack {
            GameSceneView(moveX: moveX, moveZ: moveZ)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("CHIBI GANG WAR")
                        .font(.title2.bold())
                    Spacer()
                    Text("KHU VỰC: 0")
                        .padding(10)
                        .background(.black.opacity(0.6))
                        .clipShape(Capsule())
                }
                .padding()

                Spacer()

                Text(message)
                    .font(.headline.bold())
                    .padding(10)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())

                HStack(alignment: .bottom) {
                    VStack(spacing: 8) {
                        Button("▲") { moveZ = -1 }
                        HStack {
                            Button("◀") { moveX = -1 }
                            Button("●") {
                                moveX = 0
                                moveZ = 0
                            }
                            Button("▶") { moveX = 1 }
                        }
                        Button("▼") { moveZ = 1 }
                    }
                    .font(.title2.bold())
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    VStack {
                        Button("ĐÁNH") {
                            message = "TẤN CÔNG!"
                        }
                        Button("KỸ NĂNG") {
                            message = "ĐANG DÙNG KỸ NĂNG!"
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
            }
            .foregroundStyle(.white)
        }
    }
}

struct GameSceneView: UIViewRepresentable {
    var moveX: CGFloat
    var moveZ: CGFloat

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()
        view.scene = scene
        view.backgroundColor = UIColor(red: 0.35, green: 0.55, blue: 0.75, alpha: 1)
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = true

        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 7, 12)
        cameraNode.eulerAngles = SCNVector3(-0.45, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        let ground = SCNFloor()
        ground.reflectivity = 0
        let groundNode = SCNNode(geometry: ground)
        groundNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        scene.rootNode.addChildNode(groundNode)

        for x in -3...3 {
            for z in -3...3 {
                let building = SCNBox(
                    width: 2,
                    height: CGFloat(2 + abs(x * z) % 5),
                    length: 2,
                    chamferRadius: 0
                )
                building.firstMaterial?.diffuse.contents = UIColor(
                    red: 0.25 + Double(abs(x) % 3) * 0.1,
                    green: 0.3,
                    blue: 0.4,
                    alpha: 1
                )
                let node = SCNNode(geometry: building)
                node.position = SCNVector3(
                    Float(x * 4),
                    Float(building.height / 2),
                    Float(z * 4 - 10)
                )
                scene.rootNode.addChildNode(node)
            }
        }

        let body = SCNCapsule(capRadius: 0.35, height: 1.1)
        body.firstMaterial?.diffuse.contents = UIColor.orange
        let player = SCNNode(geometry: body)
        player.name = "player"
        player.position = SCNVector3(0, 0.9, 0)
        scene.rootNode.addChildNode(player)

        let head = SCNSphere(radius: 0.42)
        head.firstMaterial?.diffuse.contents = UIColor.systemYellow
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 0.85, 0)
        player.addChildNode(headNode)

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let player = uiView.scene?.rootNode.childNode(
            withName: "player",
            recursively: true
        ) else { return }

        player.position.x += Float(moveX) * 0.08
        player.position.z += Float(moveZ) * 0.08
    }
}
