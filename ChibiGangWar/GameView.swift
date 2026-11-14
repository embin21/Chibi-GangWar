import SwiftUI
import SceneKit

struct GameRootView: View {
    @State private var started = false
    @State private var movement = CGSize.zero

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .red.opacity(0.75), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if started {
                gameScreen
            } else {
                menuScreen
            }
        }
        .preferredColorScheme(.dark)
    }

    private var menuScreen: some View {
        VStack(spacing: 25) {
            Spacer()

            Text("CHIBI")
                .font(.system(size: 52, weight: .black))
                .foregroundColor(.red)

            Text("GANG WAR")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.white)

            Text("CITY DOMINATION")
                .font(.caption)
                .tracking(5)
                .foregroundColor(.gray)

            Spacer()

            Button {
                started = true
            } label: {
                Text("VÀO GAME")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(width: 220, height: 55)
                    .background(Color.red)
                    .cornerRadius(12)
            }

            Spacer()
        }
    }

    private var gameScreen: some View {
        ZStack {
            GameSceneView(movement: movement)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("CHIBI GANG WAR")
                        .font(.headline.bold())
                    Spacer()
                    Text("LV.1")
                        .foregroundColor(.red)
                }
                .padding()

                Spacer()

                HStack(alignment: .bottom) {
                    JoystickView(movement: $movement)
                        .frame(width: 125, height: 125)

                    Spacer()

                    Button {
                        // Nút tấn công thử nghiệm
                    } label: {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .frame(width: 75, height: 75)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding(25)
            }
        }
    }
}

struct GameSceneView: UIViewRepresentable {
    var movement: CGSize

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()

        view.scene = scene
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1)
        view.allowsCameraControl = true
        view.isPlaying = true

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 5, 10)
        scene.rootNode.addChildNode(camera)

        let ground = SCNFloor()
        ground.reflectivity = 0
        let groundNode = SCNNode(geometry: ground)
        groundNode.geometry?.firstMaterial?.diffuse.contents = UIColor.darkGray
        scene.rootNode.addChildNode(groundNode)

        for i in -4...4 {
            let building = SCNBox(
                width: 2,
                height: CGFloat(arc4random_uniform(5) + 2),
                length: 2,
                chamferRadius: 0
            )
            building.firstMaterial?.diffuse.contents = UIColor.darkGray

            let node = SCNNode(geometry: building)
            node.position = SCNVector3(Float(i * 4), Float(building.height / 2), -8)
            scene.rootNode.addChildNode(node)
        }

        let player = SCNCapsule(capRadius: 0.4, height: 1.6)
        player.firstMaterial?.diffuse.contents = UIColor.red

        let playerNode = SCNNode(geometry: player)
        playerNode.position = SCNVector3(0, 0.8, 0)
        scene.rootNode.addChildNode(playerNode)

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
    }
}

struct JoystickView: View {
    @Binding var movement: CGSize

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))

            Circle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 48, height: 48)
                .offset(movement)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let x = max(-35, min(35, value.translation.width))
                    let y = max(-35, min(35, value.translation.height))
                    movement = CGSize(width: x, height: y)
                }
                .onEnded { _ in
                    movement = .zero
                }
        )
    }
}
