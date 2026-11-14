


import SwiftUI
import SceneKit
import UIKit

struct GameRootView: View {
    @State private var movement = CGSize.zero
    @State private var cameraYaw: Float = 0
    @State private var attackCount = 0
    @State private var jumpCount = 0
    @State private var crouching = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                GameSceneView(
                    movement: movement,
                    cameraYaw: cameraYaw,
                    attackCount: attackCount,
                    jumpCount: jumpCount,
                    crouching: crouching
                )
                .ignoresSafeArea()

                // Vùng vuốt camera độc lập ở bên phải
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: geo.size.width * 0.48)

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    cameraYaw -= Float(
                                        value.translation.width
                                    ) * 0.004
                                }
                        )
                }
                .ignoresSafeArea()

                VStack {
                    hud
                    Spacer()
                    controls
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var hud: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CHIBI GANG WAR")
                    .font(.headline.bold())
                    .foregroundColor(.white)

                Text("LEVEL 1")
                    .font(.caption.bold())
                    .foregroundColor(.orange)

                ProgressView(value: 1)
                    .tint(.red)
                    .frame(width: 130)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("TIỀN: 0")
                Text("VÀNG: 0")
            }
            .font(.caption.bold())
            .foregroundColor(.yellow)
        }
        .padding(12)
        .background(.black.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var controls: some View {
        HStack(alignment: .bottom) {
            JoystickView(movement: $movement)
                .frame(width: 125, height: 125)

            Spacer()

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    circleButton(
                        "NGỒI",
                        icon: "arrow.down",
                        color: crouching ? .green : .orange
                    ) {
                        crouching.toggle()
                    }

                    circleButton(
                        "NHẢY",
                        icon: "arrow.up",
                        color: .blue
                    ) {
                        jumpCount += 1
                    }
                }

                circleButton(
                    "TẤN CÔNG",
                    icon: "hand.raised.fill",
                    color: .red,
                    size: 82
                ) {
                    attackCount += 1
                }
            }
        }
    }

    private func circleButton(
        _ title: String,
        icon: String,
        color: Color,
        size: CGFloat = 64,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .bold))

                Text(title)
                    .font(.system(size: 9, weight: .heavy))
            }
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(color)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white.opacity(0.8), lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

struct JoystickView: View {
    @Binding var movement: CGSize

    var body: some View {
        GeometryReader { geo in
            let limit = min(geo.size.width, geo.size.height) / 2 - 27

            ZStack {
                Circle()
                    .fill(.black.opacity(0.55))
                    .overlay {
                        Circle().stroke(.white.opacity(0.65), lineWidth: 2)
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
                        let x = value.translation.width
                        let y = value.translation.height
                        let distance = sqrt(x * x + y * y)

                        if distance > limit {
                            let ratio = limit / distance
                            movement = CGSize(
                                width: x * ratio,
                                height: y * ratio
                            )
                        } else {
                            movement = CGSize(width: x, height: y)
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
    var cameraYaw: Float
    var attackCount: Int
    var jumpCount: Int
    var crouching: Bool

    func makeCoordinator() -> GameCoordinator {
        GameCoordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        let scene = SCNScene()

        view.scene = scene
        view.delegate = context.coordinator
        view.isPlaying = true
        view.backgroundColor = UIColor(
            red: 0.10, green: 0.09, blue: 0.13, alpha: 1
        )
        view.antialiasingMode = .multisampling4X

        createLighting(scene)
        createGround(scene)
        createCity(scene)

        let player = createPlayer()
        scene.rootNode.addChildNode(player)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.fieldOfView = 65
        camera.position = SCNVector3(0, 3.4, 7)
        camera.eulerAngles.x = -0.22
        player.addChildNode(camera)

        context.coordinator.player = player
        context.coordinator.camera = camera
        context.coordinator.body = player.childNode(
            withName: "body", recursively: true
        )

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        let c = context.coordinator

        c.movement = movement
        c.cameraYaw = cameraYaw
        c.crouching = crouching

        if attackCount != c.lastAttack {
            c.lastAttack = attackCount
            c.attack()
        }

        if jumpCount != c.lastJump {
            c.lastJump = jumpCount
            c.jump()
        }
    }

    private func createLighting(_ scene: SCNScene) {
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .omni
        light.light?.intensity = 1100
        light.position = SCNVector3(0, 12, 5)
        scene.rootNode.addChildNode(light)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 500
        ambient.light?.color = UIColor.lightGray
        scene.rootNode.addChildNode(ambient)
    }

    private func createGround(_ scene: SCNScene) {
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor(
            red: 0.17, green: 0.16, blue: 0.19, alpha: 1
        )

        scene.rootNode.addChildNode(SCNNode(geometry: floor))

        // Đường phố
        let road = SCNBox(
            width: 15,
            height: 0.04,
            length: 200,
            chamferRadius: 0
        )
        road.firstMaterial?.diffuse.contents = UIColor(
            red: 0.07, green: 0.07, blue: 0.08, alpha: 1
        )

        let roadNode = SCNNode(geometry: road)
        roadNode.position.y = 0.02
        scene.rootNode.addChildNode(roadNode)
    }

    private func createCity(_ scene: SCNScene) {
        for side in [-1, 1] {
            for index in 0..<18 {
                let height = CGFloat(arc4random_uniform(12) + 5)

                let building = SCNBox(
                    width: 5,
                    height: height,
                    length: 6,
                    chamferRadius: 0.15
                )

                building.firstMaterial?.diffuse.contents =
                    index % 2 == 0
                    ? UIColor.darkGray
                    : UIColor(
                        red: 0.22, green: 0.12, blue: 0.16, alpha: 1
                    )

                let node = SCNNode(geometry: building)
                node.position = SCNVector3(
                    Float(side * 12),
                    Float(height / 2),
                    Float(-index * 11)
                )
                scene.rootNode.addChildNode(node)

                // Biển hiệu phát sáng
                let sign = SCNBox(
                    width: 2.5,
                    height: 0.6,
                    length: 0.12,
                    chamferRadius: 0
                )
                sign.firstMaterial?.diffuse.contents = UIColor.red
                sign.firstMaterial?.emission.contents = UIColor.red

                let signNode = SCNNode(geometry: sign)
                signNode.position = SCNVector3(
                    Float(side) * 9.35,
                    Float(height * 0.7),
                    Float(-index * 11)
                )
                scene.rootNode.addChildNode(signNode)
            }
        }

        // Cột đèn đường
        for index in 0..<12 {
            let pole = SCNCylinder(radius: 0.08, height: 5)
            pole.firstMaterial?.diffuse.contents = UIColor.gray

            let node = SCNNode(geometry: pole)
            node.position = SCNVector3(
                8, 2.5, Float(-index * 15)
            )
            scene.rootNode.addChildNode(node)

            let lamp = SCNSphere(radius: 0.22)
            lamp.firstMaterial?.diffuse.contents = UIColor.orange
            lamp.firstMaterial?.emission.contents = UIColor.orange

            let lampNode = SCNNode(geometry: lamp)
            lampNode.position = SCNVector3(8, 5, Float(-index * 15))
            scene.rootNode.addChildNode(lampNode)
        }
    }

    private func createPlayer() -> SCNNode {
        let player = SCNNode()
        player.name = "player"

        // Thân áo
        let body = SCNBox(
            width: 0.85,
            height: 0.95,
            length: 0.45,
            chamferRadius: 0.12
        )
        body.firstMaterial?.diffuse.contents = UIColor.black

        let bodyNode = SCNNode(geometry: body)
        bodyNode.name = "body"
        bodyNode.position.y = 1.05
        player.addChildNode(bodyNode)

        // Đầu
        let head = SCNSphere(radius: 0.48)
        head.firstMaterial?.diffuse.contents = UIColor(
            red: 1, green: 0.78, blue: 0.62, alpha: 1
        )

        let headNode = SCNNode(geometry: head)
        headNode.position.y = 1.85
        player.addChildNode(headNode)

        // Tóc
        let hair = SCNSphere(radius: 0.49)
        hair.firstMaterial?.diffuse.contents = UIColor.white

        let hairNode = SCNNode(geometry: hair)
        hairNode.scale = SCNVector3(1, 0.55, 1)
        hairNode.position.y = 2.15
        player.addChildNode(hairNode)

        // Hai chân
        for x: Float in [-0.23, 0.23] {
            let leg = SCNCapsule(capRadius: 0.13, height: 0.75)
            leg.firstMaterial?.diffuse.contents = UIColor.darkGray

            let node = SCNNode(geometry: leg)
            node.position = SCNVector3(x, 0.38, 0)
            player.addChildNode(node)
        }

        // Hai tay
        for x: Float in [-0.55, 0.55] {
            let arm = SCNCapsule(capRadius: 0.12, height: 0.75)
            arm.firstMaterial?.diffuse.contents = UIColor.black

            let node = SCNNode(geometry: arm)
            node.position = SCNVector3(x, 1.05, 0)
            node.eulerAngles.z = x < 0 ? -0.2 : 0.2
            player.addChildNode(node)
        }

        return player
    }
}

final class GameCoordinator: NSObject, SCNSceneRendererDelegate {
    var player: SCNNode?
    var camera: SCNNode?
    var body: SCNNode?

    var movement = CGSize.zero
    var cameraYaw: Float = 0
    var crouching = false

    var lastAttack = 0
    var lastJump = 0

    private var jumpTime: Float = 0
    private var lastTime: TimeInterval = 0

    func renderer(
        _ renderer: SCNSceneRenderer,
        updateAtTime time: TimeInterval
    ) {
        guard let player = player,
              let camera = camera else { return }

        let delta = Float(
            lastTime == 0 ? 1.0 / 60.0 : min(time - lastTime, 0.05)
        )
        lastTime = time

        // Camera xoay độc lập
        camera.eulerAngles.y = cameraYaw

        let inputX = Float(movement.width / 45)
        let inputY = -Float(movement.height / 45)

        // Di chuyển theo hướng camera
        let forwardX = -sin(cameraYaw)
        let forwardZ = -cos(cameraYaw)

        let rightX = cos(cameraYaw)
        let rightZ = -sin(cameraYaw)

        let moveX = rightX * inputX + forwardX * inputY
        let moveZ = rightZ * inputX + forwardZ * inputY

        let speed: Float = crouching ? 1.4 : 3.5

        player.position.x += moveX * speed * delta
        player.position.z += moveZ * speed * delta

        if abs(moveX) > 0.05 || abs(moveZ) > 0.05 {
            player.eulerAngles.y = atan2(-moveX, -moveZ)
        }

        if let body = body {
            body.scale.y = crouching ? 0.65 : 1
        }

        if jumpTime > 0 {
            jumpTime -= delta
            player.position.y = max(
                0,
                sin((1 - jumpTime / 0.8) * .pi) * 1.2
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
                SCNAction.scale(to: 1.15, duration: 0.08),
                SCNAction.scale(to: 1.0, duration: 0.12)
            ])
        )
    }
}
