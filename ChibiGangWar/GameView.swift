
import SwiftUI
import SceneKit

struct GameRootView: View {
    @State private var started = false
    @State private var movement = CGSize.zero
    @State private var attackPulse = 0
    @State private var jumpPulse = 0
    @State private var crouching = false

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
        VStack(spacing: 20) {
            Spacer()
            Text("CHIBI")
                .font(.system(size: 52, weight: .black))
                .foregroundColor(.red)

            Text("GANG WAR")
                .font(.system(size: 30, weight: .heavy))

            Text("CITY DOMINATION")
                .font(.caption)
                .tracking(5)
                .foregroundColor(.gray)

            Spacer()

            Button("VÀO GAME") {
                started = true
            }
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(width: 220, height: 55)
            .background(Color.red)
            .cornerRadius(12)

            Spacer()
        }
    }

    private var gameScreen: some View {
        ZStack {
            GameSceneView(
                movement: movement,
                attackPulse: attackPulse,
                jumpPulse: jumpPulse,
                crouching: crouching
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("CHIBI GANG WAR")
                        .font(.headline.bold())
                    Spacer()
                    Text("LV.1")
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                HStack(alignment: .bottom) {
                    JoystickView(movement: $movement)
                        .frame(width: 125, height: 125)

                    Spacer()

                    VStack(spacing: 12) {
                        HStack(spacing: 14) {
                            controlButton(
                                "NGỒI",
                                icon: "arrow.down",
                                active: crouching,
                                color: .orange
                            ) {
                                crouching.toggle()
                            }

                            controlButton(
                                "NHẢY",
                                icon: "arrow.up",
                                color: .blue
                            ) {
                                jumpPulse += 1
                            }
                        }

                        controlButton(
                            "TẤN CÔNG",
                            icon: "hand.raised.fill",
                            color: .red,
                            size: 78
                        ) {
                            attackPulse += 1
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
        }
    }

    private func controlButton(
        _ title: String,
        icon: String,
        active: Bool = false,
        color: Color,
        size: CGFloat = 62,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                Text(title)
                    .font(.system(size: 10, weight: .heavy))
            }
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(active ? Color.green : color)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.white.opacity(0.7), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct JoystickView: View {
    @Binding var movement: CGSize

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.55))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )

                Circle()
                    .fill(Color.red.opacity(0.9))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 2)
                    )
                    .position(
                        x: center.x + movement.width,
                        y: center.y + movement.height
                    )
            }
            .contentShape(Circle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        let distance = sqrt(dx * dx + dy * dy)
                        let limit: CGFloat = 35

                        if distance > limit {
                            let scale = limit / distance
                            movement = CGSize(
                                width: dx * scale,
                                height: dy * scale
                            )
                        } else {
                            movement = CGSize(width: dx, height: dy)
                        }
                    }
                    .onEnded { _ in
                        movement = .zero
                    }
            )
        }
    }
}

struct GameSceneView: UIViewRepresentable {
    var movement: CGSize
    var attackPulse: Int
    var jumpPulse: Int
    var crouching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()

        view.scene = scene
        view.backgroundColor = UIColor(
            red: 0.08, green: 0.08, blue: 0.1, alpha: 1
        )
        view.isPlaying = true
        view.delegate = context.coordinator

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 4, 8)
        camera.eulerAngles.x = -0.25

        let player = SCNNode()
        player.position = SCNVector3(0, 0, 0)

        let body = SCNCapsule(capRadius: 0.4, height: 1.6)
        body.firstMaterial?.diffuse.contents = UIColor.red

        let bodyNode = SCNNode(geometry: body)
        bodyNode.position.y = 0.8
        player.addChildNode(bodyNode)

        player.addChildNode(camera)
        scene.rootNode.addChildNode(player)

        let ground = SCNFloor()
        ground.reflectivity = 0
        ground.firstMaterial?.diffuse.contents = UIColor.darkGray
        scene.rootNode.addChildNode(SCNNode(geometry: ground))

        for i in -4...4 {
            let height = CGFloat(arc4random_uniform(5) + 2)
            let building = SCNBox(
                width: 2,
                height: height,
                length: 2,
                chamferRadius: 0
            )
            building.firstMaterial?.diffuse.contents = UIColor.gray

            let node = SCNNode(geometry: building)
            node.position = SCNVector3(
                Float(i * 4),
                Float(height / 2),
                -8
            )
            scene.rootNode.addChildNode(node)
        }

        context.coordinator.player = player
        context.coordinator.body = bodyNode
        context.coordinator.camera = camera

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.movement = movement
        context.coordinator.crouching = crouching

        if attackPulse != context.coordinator.lastAttack {
            context.coordinator.lastAttack = attackPulse
            context.coordinator.attack()
        }

        if jumpPulse != context.coordinator.lastJump {
            context.coordinator.lastJump = jumpPulse
            context.coordinator.jump()
        }
    }

    class Coordinator: NSObject, SCNSceneRendererDelegate {
        var player: SCNNode?
        var body: SCNNode?
        var camera: SCNNode?

        var movement = CGSize.zero
        var crouching = false
        var lastAttack = 0
        var lastJump = 0
        var jumpTime: Float = 0

        func renderer(
            _ renderer: SCNSceneRenderer,
            updateAtTime time: TimeInterval
        ) {
            guard let player = player else { return }

            let dx = Float(movement.width / 35)
            let dz = Float(movement.height / 35)

            let speed: Float = 0.10

            player.position.x += dx * speed
            player.position.z += dz * speed

            if abs(dx) > 0.1 || abs(dz) > 0.1 {
                player.eulerAngles.y = atan2(dx, dz)
            }

            if let body = body {
                body.scale.y = crouching ? 0.55 : 1.0
                body.position.y = crouching ? 0.45 : 0.8
            }

            if jumpTime > 0 {
                jumpTime -= 0.04
                player.position.y = sin(jumpTime * .pi) * 1.3
            } else {
                player.position.y = 0
            }
        }

        func jump() {
            guard jumpTime <= 0 else { return }
            jumpTime = 1
        }

        func attack() {
            guard let body = body else { return }

            body.runAction(
                SCNAction.sequence([
                    SCNAction.scale(to: 1.2, duration: 0.08),
                    SCNAction.scale(to: crouching ? 0.55 : 1.0, duration: 0.12)
                ])
            )
        }
    }
}
