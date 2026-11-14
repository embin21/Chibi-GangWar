

import SwiftUI
import SceneKit
import UIKit

struct GameRootView: View {
    @State private var isPlaying = false
    @State private var movement = CGSize.zero
    @State private var attackCount = 0
    @State private var jumpCount = 0
    @State private var isCrouching = false

    var body: some View {
        ZStack {
            if isPlaying {
                gameScreen
            } else {
                mainMenu
            }
        }
        .preferredColorScheme(.dark)
    }

    private var mainMenu: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .red.opacity(0.7), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Text("CHIBI")
                    .font(.system(size: 58, weight: .black))
                    .foregroundColor(.red)

                Text("GANG WAR")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)

                Text("CITY DOMINATION")
                    .tracking(6)
                    .foregroundColor(.gray)

                Spacer()

                Button {
                    isPlaying = true
                } label: {
                    Text("VÀO GAME")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 230, height: 58)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Spacer()
            }
        }
    }

    private var gameScreen: some View {
        ZStack {
            GameSceneView(
                movement: movement,
                attackCount: attackCount,
                jumpCount: jumpCount,
                isCrouching: isCrouching
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CHIBI GANG WAR")
                            .font(.headline.bold())
                        Text("CẤP ĐỘ 1")
                            .font(.caption.bold())
                            .foregroundColor(.red)
                    }

                    Spacer()

                    Text("TIỀN: 0")
                        .font(.caption.bold())
                }
                .padding()

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("HP")
                            .font(.caption.bold())
                        ProgressView(value: 1)
                            .tint(.red)
                            .frame(width: 115)

                        Text("NĂNG LƯỢNG")
                            .font(.caption.bold())
                        ProgressView(value: 1)
                            .tint(.blue)
                            .frame(width: 115)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                HStack(alignment: .bottom) {
                    JoystickView(movement: $movement)
                        .frame(width: 125, height: 125)

                    Spacer()

                    VStack(spacing: 13) {
                        HStack(spacing: 12) {
                            roundButton(
                                "NGỒI",
                                icon: "arrow.down",
                                color: isCrouching ? .green : .orange
                            ) {
                                isCrouching.toggle()
                            }

                            roundButton(
                                "NHẢY",
                                icon: "arrow.up",
                                color: .blue
                            ) {
                                jumpCount += 1
                            }
                        }

                        roundButton(
                            "TẤN CÔNG",
                            icon: "hand.raised.fill",
                            color: .red,
                            size: 82
                        ) {
                            attackCount += 1
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 25)
            }
        }
    }

    private func roundButton(
        _ title: String,
        icon: String,
        color: Color,
        size: CGFloat = 64,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                Text(title)
                    .font(.system(size: 9, weight: .heavy))
            }
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(color)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white.opacity(0.7), lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

struct JoystickView: View {
    @Binding var movement: CGSize

    var body: some View {
        GeometryReader { geometry in
            let center = geometry.size.width / 2

            ZStack {
                Circle()
                    .fill(.black.opacity(0.55))
                    .overlay {
                        Circle().stroke(.white.opacity(0.6), lineWidth: 2)
                    }

                Circle()
                    .fill(.red)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle().stroke(.white, lineWidth: 2)
                    }
                    .offset(movement)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let dx = value.translation.width
                        let dy = value.translation.height
                        let distance = sqrt(dx * dx + dy * dy)
                        let limit = center - 28

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
    var attackCount: Int
    var jumpCount: Int
    var isCrouching: Bool

    func makeCoordinator() -> GameCoordinator {
        GameCoordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()

        view.scene = scene
        view.backgroundColor = UIColor(
            red: 0.08,
            green: 0.07,
            blue: 0.10,
            alpha: 1
        )
        view.isPlaying = true
        view.delegate = context.coordinator
        view.antialiasingMode = .multisampling4X

        let player = SCNNode()
        player.name = "player"

        let bodyGeometry = SCNCapsule(
            capRadius: 0.35,
            height: 1.5
        )
        bodyGeometry.firstMaterial?.diffuse.contents = UIColor.red

        let body = SCNNode(geometry: bodyGeometry)
        body.position.y = 0.75
        player.addChildNode(body)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 3.5, 7)
        camera.eulerAngles.x = -0.28
        camera.camera?.fieldOfView = 65
        player.addChildNode(camera)

        scene.rootNode.addChildNode(player)

        let ground = SCNFloor()
        ground.reflectivity = 0
        ground.firstMaterial?.diffuse.contents = UIColor(
            red: 0.18,
            green: 0.18,
            blue: 0.20,
            alpha: 1
        )
        scene.rootNode.addChildNode(SCNNode(geometry: ground))

        createCity(in: scene)

        context.coordinator.player = player
        context.coordinator.body = body
        context.coordinator.camera = camera

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        let coordinator = context.coordinator

        coordinator.movement = movement
        coordinator.isCrouching = isCrouching

        if attackCount != coordinator.lastAttack {
            coordinator.lastAttack = attackCount
            coordinator.attack()
        }

        if jumpCount != coordinator.lastJump {
            coordinator.lastJump = jumpCount
            coordinator.jump()
        }
    }

    private func createCity(in scene: SCNScene) {
        for x in -5...5 {
            for z in [-12, -20, 12, 20] {
                let height = CGFloat(
                    Int.random(in: 3...9)
                )

                let building = SCNBox(
                    width: 3,
                    height: height,
                    length: 3,
                    chamferRadius: 0.1
                )

                building.firstMaterial?.diffuse.contents =
                    UIColor.darkGray

                let node = SCNNode(geometry: building)
                node.position = SCNVector3(
                    Float(x * 5),
                    Float(height / 2),
                    Float(z)
                )

                scene.rootNode.addChildNode(node)
            }
        }
    }
}

final class GameCoordinator: NSObject, SCNSceneRendererDelegate {
    var player: SCNNode?
    var body: SCNNode?
    var camera: SCNNode?

    var movement = CGSize.zero
    var isCrouching = false

    var lastAttack = 0
    var lastJump = 0

    private var jumpTime: Float = 0
    private var lastFrame: TimeInterval = 0

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {
        guard let player = player else { return }

        let delta = lastFrame == 0
            ? Float(1.0 / 60.0)
            : Float(min(time - lastFrame, 0.05))

        lastFrame = time

        let dx = Float(movement.width / 45)
        let dz = Float(movement.height / 45)

        let speed: Float = isCrouching ? 1.4 : 3.5

        player.position.x += dx * speed * delta
        player.position.z += dz * speed * delta

        if abs(dx) > 0.08 || abs(dz) > 0.08 {
            player.eulerAngles.y = atan2(dx, dz)
        }

        if let body = body {
            body.scale.y = isCrouching ? 0.6 : 1
            body.position.y = isCrouching ? 0.45 : 0.75
        }

        if jumpTime > 0 {
            jumpTime -= delta
            player.position.y = max(
                0,
                sin((1 - jumpTime) * .pi) * 1.2
            )
        } else {
            player.position.y = 0
        }
    }

    func jump() {
        guard jumpTime <= 0 else { return }
        jumpTime = 0.8
    }

    
func attack() {
    guard let body = body else { return }

    body.removeAllActions()

    body.runAction(
        SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 0.08),
            SCNAction.scale(to: 1.0, duration: 0.12)
        ])
    )
}

}
