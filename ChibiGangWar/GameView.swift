import SwiftUI
import SceneKit

struct GameRootView: View {
    @State private var entered = false
    @State private var loading = false
    @State private var background = Int.random(in: 0..<5)

    private let palettes: [[Color]] = [
        [.black, .red], [.black, Color(red: 0.35, green: 0.04, blue: 0.08)],
        [Color(red: 0.08, green: 0.04, blue: 0.10), .black],
        [Color(red: 0.22, green: 0.03, blue: 0.02), .black],
        [.black, Color(red: 0.18, green: 0.18, blue: 0.22)]
    ]

    var body: some View {
        Group {
            if entered {
                CityGameScreen().ignoresSafeArea()
            } else {
                ZStack {
                    LinearGradient(colors: palettes[background], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    VStack(spacing: 18) {
                        Spacer()
                        Text("CHIBI").font(.system(size: 48, weight: .black, design: .rounded)).tracking(8)
                        Text("GANG WAR").font(.system(size: 28, weight: .heavy)).tracking(5).foregroundStyle(.red)
                        Text("CITY DOMINATION").font(.caption2.bold()).tracking(4).foregroundStyle(.white.opacity(0.65))
                        Spacer()
                        if loading {
                            ProgressView("Đang tải thành phố…").tint(.red).foregroundStyle(.white)
                        } else {
                            Button {
                                background = Int.random(in: 0..<palettes.count)
                                loading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    loading = false
                                    entered = true
                                }
                            } label: {
                                Text("VÀO GAME").font(.system(size: 17, weight: .black)).tracking(2)
                                    .foregroundStyle(.white).frame(maxWidth: 260).padding()
                                    .background(.red).clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            Text("BẢN THỬ NGHIỆM OFFLINE").font(.caption2.bold()).tracking(2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer().frame(height: 30)
                    }.foregroundStyle(.white).padding()
                }
            }
        }.preferredColorScheme(.dark)
    }
}

struct CityGameScreen: View {
    @State private var stick = CGSize.zero
    @State private var attack = false
    @State private var menu = false

    var body: some View {
        ZStack {
            CitySceneView(movement: stick, attackPulse: attack)
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CHIBI GANG WAR").font(.caption.bold()).tracking(1)
                        Text("LEVEL 1 • THÀNH PHỐ THỬ NGHIỆM").font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                    Button { menu.toggle() } label: {
                        Image(systemName: "line.3.horizontal").padding(12)
                            .background(.black.opacity(0.65)).clipShape(Circle())
                    }
                }.padding(.horizontal, 18).padding(.top, 12)
                Spacer()
                HStack(alignment: .bottom) {
                    JoystickView(value: $stick).frame(width: 130, height: 130)
                    Spacer()
                    VStack {
                        Button { attack.toggle() } label: {
                            Image(systemName: "burst.fill").font(.system(size: 28, weight: .black))
                                .frame(width: 68, height: 68).background(.red)
                                .clipShape(Circle()).overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 2))
                        }
                        Text("ĐÁNH").font(.caption2.bold())
                    }
                }.padding(.horizontal, 22).padding(.bottom, 26)
            }
            if menu {
                Color.black.opacity(0.75).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("MENU").font(.largeTitle.bold())
                    Text("Bản thử nghiệm offline: di chuyển và nút đánh.")
                        .multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.7))
                    Button("TIẾP TỤC") { menu = false }
                        .font(.headline.bold()).padding().background(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding(28).background(.black).clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(28)
            }
        }.foregroundStyle(.white).preferredColorScheme(.dark)
    }
}

struct JoystickView: View {
    @Binding var value: CGSize
    @State private var knob = CGSize.zero
    private let radius: CGFloat = 42

    var body: some View {
        ZStack {
            Circle().fill(.black.opacity(0.55)).overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 2))
            Circle().fill(.white.opacity(0.2)).frame(width: 52, height: 52)
                .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 1)).offset(knob)
        }
        .contentShape(Circle())
        .gesture(DragGesture(minimumDistance: 0).onChanged { g in
            let dx = g.translation.width, dy = g.translation.height
            let length = sqrt(dx * dx + dy * dy)
            let scale = length > radius ? radius / length : 1
            knob = CGSize(width: dx * scale, height: dy * scale)
            value = CGSize(width: knob.width / radius, height: knob.height / radius)
        }.onEnded { _ in
            withAnimation(.spring()) { knob = .zero; value = .zero }
        })
    }
}

struct CitySceneView: UIViewRepresentable {
    var movement: CGSize
    var attackPulse: Bool
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = buildScene()
        view.backgroundColor = UIColor(red: 0.025, green: 0.025, blue: 0.04, alpha: 1)
        view.isPlaying = true
        view.delegate = context.coordinator
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.movement = movement
        if context.coordinator.lastAttack != attackPulse {
            context.coordinator.lastAttack = attackPulse
            context.coordinator.attack()
        }
    }

    private func buildScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.025, green: 0.025, blue: 0.04, alpha: 1)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = UIColor(white: 0.13, alpha: 1)
        scene.rootNode.addChildNode(SCNNode(geometry: floor))

        for x in -3...3 {
            for z in -3...3 where !(x == 0 && z == 0) {
                let h = CGFloat.random(in: 1.5...4.0)
                let box = SCNBox(width: 2.2, height: h, length: 2.2, chamferRadius: 0.08)
                box.firstMaterial?.diffuse.contents = UIColor(red: 0.19, green: 0.09, blue: 0.12, alpha: 1)
                let node = SCNNode(geometry: box)
                node.position = SCNVector3(Float(x * 5), Float(h / 2), Float(z * 5))
                scene.rootNode.addChildNode(node)
            }
        }

        let player = SCNNode()
        player.name = "player"
        let torso = SCNCapsule(capRadius: 0.32, height: 1.1)
        torso.firstMaterial?.diffuse.contents = UIColor.systemRed
        let torsoNode = SCNNode(geometry: torso); torsoNode.position.y = 0.55
        player.addChildNode(torsoNode)
        let head = SCNSphere(radius: 0.28)
        head.firstMaterial?.diffuse.contents = UIColor(red: 0.95, green: 0.72, blue: 0.58, alpha: 1)
        let headNode = SCNNode(geometry: head); headNode.position.y = 1.25
        player.addChildNode(headNode)
        scene.rootNode.addChildNode(player)

        let cameraNode = SCNNode()
        cameraNode.name = "followCamera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 65
        cameraNode.position = SCNVector3(0, 6, 9)
        scene.rootNode.addChildNode(cameraNode)

        let light = SCNNode(); light.light = SCNLight(); light.light?.type = .omni
        light.light?.intensity = 1100; light.position = SCNVector3(0, 12, 6)
        scene.rootNode.addChildNode(light)
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient
        ambient.light?.intensity = 350; scene.rootNode.addChildNode(ambient)
        return scene
    }

    final class Coordinator: NSObject, SCNSceneRendererDelegate {
        weak var view: SCNView?
        var movement = CGSize.zero
        var lastAttack = false
        private var lastTime: TimeInterval = 0

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let scene = renderer.scene,
                  let player = scene.rootNode.childNode(withName: "player", recursively: true),
                  let camera = scene.rootNode.childNode(withName: "followCamera", recursively: true) else { return }
            let dt = min(time - (lastTime == 0 ? time : lastTime), 0.05)
            lastTime = time
            player.position.x += Float(movement.width) * 4.0 * Float(dt)
            player.position.z += Float(movement.height) * 4.0 * Float(dt)
            let target = SCNVector3(player.position.x, player.position.y + 5.3, player.position.z + 8)
            camera.position = SCNVector3(
                camera.position.x + (target.x - camera.position.x) * 0.08,
                camera.position.y + (target.y - camera.position.y) * 0.08,
                camera.position.z + (target.z - camera.position.z) * 0.08
            )
            camera.look(at: SCNVector3(player.position.x, player.position.y + 0.5, player.position.z))
        }

        func attack() {
            guard let player = view?.scene?.rootNode.childNode(withName: "player", recursively: true) else { return }
            let scale = player.scale
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.12
            player.scale = SCNVector3(1.18, 1.18, 1.18)
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.12
                player.scale = scale
                SCNTransaction.commit()
            }
            SCNTransaction.commit()
        }
    }
}
