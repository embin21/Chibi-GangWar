


import SwiftUI
import SceneKit
import UIKit


struct GameRootView: View {
    @State private var movement = CGSize.zero
    @State private var cameraYaw: Float = 0
    @State private var cameraStartYaw: Float = 0

    @State private var attackCount = 0
    @State private var jumpCount = 0
    @State private var crouching = false

    @State private var activePanel: String? = nil
    @State private var showChat = false

    private let gold = Color(red: 1, green: 0.72, blue: 0.08)
    private let red = Color(red: 0.85, green: 0.04, blue: 0.10)

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

                // Vuốt camera ở nửa phải màn hình
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: geo.size.width * 0.48)

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 5)
                                .onChanged { value in
                                    cameraYaw = cameraStartYaw
                                        - Float(value.translation.width) * 0.004
                                }
                                .onEnded { _ in
                                    cameraStartYaw = cameraYaw
                                }
                        )
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar

                    HStack(alignment: .top) {
                        leftMenu

                        Spacer()

                        rightInformation
                    }
                    .padding(.top, 12)

                    Spacer()

                    bottomHUD
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)

                if let panel = activePanel {
                    menuPanel(panel)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - TOP BAR

    private var topBar: some View {
        HStack(spacing: 8) {
            // Avatar và thông tin nhân vật
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                    Image(systemName: "person.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.white)
                }
                .frame(width: 58, height: 58)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(gold, lineWidth: 2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Nhật Bin Trần")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Lv.50       EXP: 85%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(gold)

                    ProgressView(value: 0.85)
                        .tint(gold)
                        .frame(width: 125)

                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("HP 100/100")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 5)
                    .background(red.opacity(0.8))
                    .cornerRadius(4)

                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.cyan)
                        Text("Năng Lượng 100/100")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 5)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(4)
                }
            }
            .padding(5)
            .background(Color.black.opacity(0.72))
            .cornerRadius(10)

            Spacer(minLength: 2)

            currencyBox(icon: "bitcoinsign.circle.fill",
                        value: "2.000.000")

            currencyBox(icon: "diamond.fill",
                        value: "999.999")

            Spacer(minLength: 2)

            topMenuButton("Cửa Hàng", icon: "cart.fill")
            topMenuButton("Băng Hội", icon: "person.3.fill")
            topMenuButton("Xếp Hạng", icon: "trophy.fill")
            topMenuButton("Cài Đặt", icon: "gearshape.fill")
            topMenuButton("Thoát Game", icon: "door.right.hand.open")
        }
    }

    private func currencyBox(icon: String, value: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(gold)
                .font(.system(size: 17))

            Text(value)
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(.white)

            Image(systemName: "plus.circle.fill")
                .foregroundColor(gold)
        }
        .padding(7)
        .background(Color.black.opacity(0.75))
        .cornerRadius(8)
    }

    private func topMenuButton(_ title: String, icon: String) -> some View {
        Button {
            activePanel = title
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(gold)

                Text(title)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundColor(.white)
            }
            .frame(minWidth: 43)
        }
        .buttonStyle(.plain)
    }

    // MARK: - LEFT MENU

    private var leftMenu: some View {
        VStack(alignment: .leading, spacing: 13) {
            sideMenuButton("Nhiệm Vụ", icon: "scroll.fill")
            sideMenuButton("Quà Đăng Nhập", icon: "gift.fill")
            sideMenuButton("Sự Kiện", icon: "trophy.fill")
        }
        .padding(8)
        .background(Color.black.opacity(0.22))
        .cornerRadius(12)
    }

    private func sideMenuButton(_ title: String, icon: String) -> some View {
        Button {
            activePanel = title
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(gold)

                Text(title)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 75)
        }
        .buttonStyle(.plain)
    }

    // MARK: - RIGHT INFORMATION

    private var rightInformation: some View {
        VStack(alignment: .trailing, spacing: 9) {
            // Minimap
            Button {
                activePanel = "Bản Đồ"
            } label: {
                VStack(spacing: 0) {
                    minimap

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.yellow)

                        Text("Trung Tâm Thành Phố")
                            .foregroundColor(.white)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(6)
                    .background(Color.black.opacity(0.85))
                }
                .frame(width: 150)
                .background(Color.black.opacity(0.85))
                .cornerRadius(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(gold, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)

            // Nhiệm vụ chính
            Button {
                activePanel = "Nhiệm Vụ"
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Nhiệm Vụ Chính")
                        .foregroundColor(gold)
                        .font(.system(size: 13, weight: .heavy))

                    Text("› Đánh bại 10 tên côn đồ")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))

                    Text("(0/10)                         ›")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                }
                .padding(9)
                .frame(width: 190, alignment: .leading)
                .background(Color.black.opacity(0.78))
                .cornerRadius(9)
                .overlay {
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(gold, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var minimap: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.13, green: 0.19, blue: 0.15)

                // Đường phố trên minimap
                ForEach(0..<5, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(height: 7)
                        .offset(y: CGFloat(i - 2) * 25)

                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 7)
                        .offset(x: CGFloat(i - 2) * 30)
                }

                ForEach(0..<12, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i % 2 == 0 ? Color.green : Color.orange)
                        .frame(width: 13, height: 10)
                        .offset(
                            x: CGFloat((i % 4) - 2) * 29,
                            y: CGFloat((i / 4) - 1) * 27
                        )
                }

                Image(systemName: "location.north.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.cyan)
                    .shadow(color: .black, radius: 3)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .frame(height: 105)
    }

    // MARK: - BOTTOM HUD

    private var bottomHUD: some View {
        HStack(alignment: .bottom) {
            // Chat thế giới
            Button {
                showChat.toggle()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    Text("Thế Giới  |  AnhEm: Kết bang nào?")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(gold)

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .padding(9)
                .background(Color.black.opacity(0.78))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Spacer()

            // Joystick
            JoystickView(movement: $movement)
                .frame(width: 125, height: 125)

            Spacer()

            // Ba lô
            Button {
                activePanel = "Ba Lô"
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "backpack.fill")
                        .font(.system(size: 29))
                        .foregroundColor(gold)

                    Text("Ba Lô")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Điều khiển chiến đấu
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    actionButton("CAMERA", icon: "camera.fill",
                                 color: .gray, size: 57) {
                        activePanel = "Camera"
                    }

                    actionButton("NHẢY", icon: "figure.run",
                                 color: .orange, size: 65) {
                        jumpCount += 1
                    }
                }

                HStack(spacing: 12) {
                    actionButton("NGỒI", icon: "figure.sitting",
                                 color: .gray, size: 65) {
                        crouching.toggle()
                    }

                    actionButton("TẤN CÔNG", icon: "hand.raised.fill",
                                 color: red, size: 88) {
                        attackCount += 1
                    }
                }
            }
        }
    }

    private func actionButton(
        _ title: String,
        icon: String,
        color: Color,
        size: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: size * 0.34, weight: .heavy))

                Text(title)
                    .font(.system(size: 9, weight: .heavy))
            }
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(color.opacity(0.88))
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white.opacity(0.85), lineWidth: 2)
            }
            .shadow(color: color.opacity(0.5), radius: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - MENU PANEL

    private func menuPanel(_ title: String) -> some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 15) {
                HStack {
                    Text(title.uppercased())
                        .font(.system(size: 21, weight: .heavy))
                        .foregroundColor(gold)

                    Spacer()

                    Button {
                        activePanel = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 27))
                            .foregroundColor(.red)
                    }
                }

                Divider().background(gold)

                Text(panelDescription(title))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(22)
            .frame(width: 340, height: 220)
            .background(Color(red: 0.09, green: 0.07, blue: 0.08))
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(gold, lineWidth: 2)
            }
        }
    }

    private func panelDescription(_ title: String) -> String {
        switch title {
        case "Cửa Hàng":
            return "Cửa hàng vật phẩm và trang phục sẽ được kết nối tại đây."
        case "Băng Hội":
            return "Thông tin băng hội, thành viên và lãnh thổ."
        case "Xếp Hạng":
            return "Bảng xếp hạng chiến binh đường phố."
        case "Cài Đặt":
            return "Cài đặt âm thanh, camera và điều khiển."
        case "Nhiệm Vụ":
            return "Nhiệm vụ chính và nhiệm vụ hằng ngày."
        case "Quà Đăng Nhập":
            return "Phần thưởng đăng nhập 7 ngày."
        case "Sự Kiện":
            return "Các sự kiện trong thành phố."
        case "Bản Đồ":
            return "Bản đồ 6 khu vực của thành phố."
        case "Ba Lô":
            return "Vật phẩm, trang phục và vũ khí của nhân vật."
        case "Camera":
            return "Vuốt nửa phải màn hình để xoay camera 360 độ."
        default:
            return "Chức năng đang được phát triển."
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

    let root = scene.rootNode

    // MARK: - Vật liệu
    func mat(_ color: UIColor, glow: Bool = false) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        if glow {
            m.emission.contents = color
        }
        return m
    }

    let concrete = mat(UIColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1))
    let darkRed = mat(UIColor(red: 0.24, green: 0.035, blue: 0.06, alpha: 1))
    let glass = mat(UIColor(red: 0.08, green: 0.16, blue: 0.22, alpha: 1))
    let windowLight = mat(UIColor(red: 1, green: 0.65, blue: 0.2, alpha: 1), glow: true)
    let neonRed = mat(.red, glow: true)
    let neonBlue = mat(.cyan, glow: true)
    let sidewalkMat = mat(UIColor(red: 0.28, green: 0.28, blue: 0.30, alpha: 1))
    let roadMat = mat(UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1))

    // MARK: - Đường chính
    
// MARK: - Đường phố 3D
let road = SCNBox(
    width: 18,
    height: 0.12,
    length: 240,
    chamferRadius: 0
)
road.firstMaterial = roadMat

let roadNode = SCNNode(geometry: road)
roadNode.position = SCNVector3(0, -0.12, -100)
root.addChildNode(roadNode)

// Vạch vàng phân chia hai chiều
for side: Float in [-1, 1] {
    let line = SCNBox(
        width: 0.12,
        height: 0.025,
        length: 240,
        chamferRadius: 0
    )
    line.firstMaterial = mat(.yellow)

    let node = SCNNode(geometry: line)
    node.position = SCNVector3(side * 0.12, -0.045, -100)
    root.addChildNode(node)
}

// Vạch trắng phân làn đứt đoạn
for lane: Float in [-1, 1] {
    for index in 0..<30 {
        let dash = SCNBox(
            width: 0.12,
            height: 0.025,
            length: 3,
            chamferRadius: 0
        )
        dash.firstMaterial = mat(.white)

        let node = SCNNode(geometry: dash)
        node.position = SCNVector3(
            lane * 4.5,
            -0.045,
            Float(-index * 8)
        )
        root.addChildNode(node)
    }
}

// Vạch trắng sát mép đường
for side: Float in [-1, 1] {
    let edge = SCNBox(
        width: 0.15,
        height: 0.025,
        length: 240,
        chamferRadius: 0
    )
    edge.firstMaterial = mat(.white)

    let node = SCNNode(geometry: edge)
    node.position = SCNVector3(side * 8.5, -0.045, -100)
    root.addChildNode(node)
}

// Vạch qua đường ở một số vị trí
for crossing in [30, 90, 150] {
    for index in 0..<9 {
        let stripe = SCNBox(
            width: 1.5,
            height: 0.03,
            length: 0.45,
            chamferRadius: 0
        )
        stripe.firstMaterial = mat(.white)

        let node = SCNNode(geometry: stripe)
        node.position = SCNVector3(
            -6.8 + Float(index) * 1.7,
            -0.035,
            Float(-crossing)
        )
        root.addChildNode(node)
    }
}

    
    // MARK: - Vỉa hè hai bên
    
// MARK: - Vỉa hè hai bên thành phố

let sidewalkMaterial = mat(
    UIColor(red: 0.32, green: 0.32, blue: 0.34, alpha: 1)
)

let curbMaterial = mat(
    UIColor(red: 0.65, green: 0.65, blue: 0.67, alpha: 1)
)

let tileMaterial = mat(
    UIColor(red: 0.42, green: 0.42, blue: 0.44, alpha: 1)
)

let grassMaterial = mat(
    UIColor(red: 0.08, green: 0.28, blue: 0.12, alpha: 1)
)

// Vỉa hè và bó vỉa
for side: Float in [-1, 1] {

    let sidewalk = SCNBox(
        width: 4,
        height: 0.3,
        length: 240,
        chamferRadius: 0
    )
    sidewalk.firstMaterial = sidewalkMaterial

    let sidewalkNode = SCNNode(geometry: sidewalk)
    sidewalkNode.position = SCNVector3(side * 11, 0, -100)
    root.addChildNode(sidewalkNode)

    let curb = SCNBox(
        width: 0.25,
        height: 0.4,
        length: 240,
        chamferRadius: 0
    )
    curb.firstMaterial = curbMaterial

    let curbNode = SCNNode(geometry: curb)
    curbNode.position = SCNVector3(side * 9, 0.02, -100)
    root.addChildNode(curbNode)

    // Gạch lát vỉa hè
    for index in 0..<60 {
        let tile = SCNBox(
            width: 3.7,
            height: 0.025,
            length: 3.8,
            chamferRadius: 0.02
        )
        tile.firstMaterial = tileMaterial

        let tileNode = SCNNode(geometry: tile)
        tileNode.position = SCNVector3(
            side * 11,
            0.17,
            Float(-index * 4)
        )
        root.addChildNode(tileNode)
    }

    // Bồn cây và cây xanh
    for index in 0..<12 {
        let z = Float(-index * 18 - 5)

        let planter = SCNBox(
            width: 1.8,
            height: 0.55,
            length: 1.8,
            chamferRadius: 0.12
        )
        planter.firstMaterial = mat(.darkGray)

        let planterNode = SCNNode(geometry: planter)
        planterNode.position = SCNVector3(side * 12, 0.4, z)
        root.addChildNode(planterNode)

        let trunk = SCNCylinder(radius: 0.13, height: 2.2)
        trunk.firstMaterial = mat(
            UIColor(red: 0.3, green: 0.17, blue: 0.08, alpha: 1)
        )

        let trunkNode = SCNNode(geometry: trunk)
        trunkNode.position = SCNVector3(side * 12, 1.75, z)
        root.addChildNode(trunkNode)

        let leaves = SCNSphere(radius: 0.9)
        leaves.firstMaterial = grassMaterial

        let leavesNode = SCNNode(geometry: leaves)
        leavesNode.scale = SCNVector3(1, 1.3, 1)
        leavesNode.position = SCNVector3(side * 12, 3.1, z)
        root.addChildNode(leavesNode)
    }

    // Thùng rác công cộng
    for index in 0..<8 {
        let bin = SCNCylinder(radius: 0.32, height: 0.85)
        bin.firstMaterial = mat(.darkGray)

        let binNode = SCNNode(geometry: bin)
        binNode.position = SCNVector3(
            side * 10.5,
            0.65,
            Float(-index * 28 - 12)
        )
        root.addChildNode(binNode)
    }
}


        // MARK: - Dãy nhà
        for index in 0..<18 {

            let height = CGFloat(arc4random_uniform(12) + 10)
            let width: CGFloat = CGFloat(arc4random_uniform(3) + 7)

            let building = SCNBox(
                width: width,
                height: height,
                length: 8,
                chamferRadius: 0.12
            )
            building.firstMaterial = index % 2 == 0 ? concrete : darkRed

            let centerX: Float = index % 2 == 0 ? -17 : 17
            let centerZ = Float(-index * 12)

            let buildingNode = SCNNode(geometry: building)
            buildingNode.position = SCNVector3(
                centerX,
                Float(height / 2),
                centerZ
            )
            root.addChildNode(buildingNode)

            // Mái nhà
            let roof = SCNBox(
                width: width + 0.4,
                height: 0.35,
                length: 8.4,
                chamferRadius: 0.05
            )
            roof.firstMaterial = darkRed

            let roofNode = SCNNode(geometry: roof)
            roofNode.position = SCNVector3(
                centerX,
                Float(height) + 0.15,
                centerZ
            )
            root.addChildNode(roofNode)

            // Cửa sổ theo từng tầng
            let floors = max(2, Int(height / 3))

            for floor in 0..<floors {
                for windowIndex in 0..<2 {

                    let window = SCNBox(
                        width: 1.25,
                        height: 1.5,
                        length: 0.12,
                        chamferRadius: 0.04
                    )

                    window.firstMaterial = arc4random_uniform(3) == 0
                        ? glass
                        : windowLight

                    let windowNode = SCNNode(geometry: window)

                    let windowX = centerX + Float(windowIndex) * 2 - 1
                    let windowY = Float(floor) * 2.7 + 2.1
                    let windowZ = centerZ - 4.08

                    windowNode.position = SCNVector3(
                        windowX,
                        windowY,
                        windowZ
                    )
                    root.addChildNode(windowNode)
                }
            }

            // Ban công tầng trên
            if height > 13 {
                let balcony = SCNBox(
                    width: 3.8,
                    height: 0.18,
                    length: 0.9,
                    chamferRadius: 0.04
                )
                balcony.firstMaterial = darkRed

                let balconyNode = SCNNode(geometry: balcony)
                balconyNode.position = SCNVector3(
                    centerX,
                    4.0,
                    centerZ - 4.5
                )
                root.addChildNode(balconyNode)

                // Lan can
                let rail = SCNBox(
                    width: 3.8,
                    height: 0.65,
                    length: 0.08,
                    chamferRadius: 0
                )
                rail.firstMaterial = mat(.gray)

                let railNode = SCNNode(geometry: rail)
                railNode.position = SCNVector3(
                    centerX,
                    4.4,
                    centerZ - 4.9
                )
                root.addChildNode(railNode)
            }

            // Cửa chính
            let door = SCNBox(
                width: 1.8,
                height: 2.8,
                length: 0.15,
                chamferRadius: 0.04
            )
            door.firstMaterial = mat(.black)

            let doorNode = SCNNode(geometry: door)
            doorNode.position = SCNVector3(
                centerX,
                1.4,
                centerZ - 4.1
            )
            root.addChildNode(doorNode)

            // Bảng hiệu neon
            let sign = SCNBox(
                width: 3.8,
                height: 0.8,
                length: 0.18,
                chamferRadius: 0.05
            )
            sign.firstMaterial = index % 2 == 0 ? neonRed : neonBlue

            let signNode = SCNNode(geometry: sign)
            signNode.position = SCNVector3(
                centerX,
                3.5,
                centerZ - 4.3
            )
            root.addChildNode(signNode)

            // Mái che cửa hàng
            let awning = SCNBox(
                width: 4.5,
                height: 0.16,
                length: 1.2,
                chamferRadius: 0.04
            )
            awning.firstMaterial = index % 2 == 0 ? neonRed : darkRed

            let awningNode = SCNNode(geometry: awning)
            awningNode.position = SCNVector3(
                centerX,
                2.8,
                centerZ - 4.7
            )
            root.addChildNode(awningNode)
        }
    

    // MARK: - Cột đèn đường
    for index in 0..<16 {
        let z = Float(-index * 15)

        let pole = SCNCylinder(radius: 0.08, height: 5)
        pole.firstMaterial = mat(.gray)

        let poleNode = SCNNode(geometry: pole)
        poleNode.position = SCNVector3(8, 2.5, z)
        root.addChildNode(poleNode)

        let lamp = SCNSphere(radius: 0.22)
        lamp.firstMaterial = mat(.orange, glow: true)

        let lampNode = SCNNode(geometry: lamp)
        lampNode.position = SCNVector3(8, 5, z)
        root.addChildNode(lampNode)
    }
}


    
private func createPlayer() -> SCNNode {
    let player = SCNNode()
    player.name = "player"

    // MARK: - Vật liệu
    func material(_ color: UIColor, roughness: CGFloat = 0.8) -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = color
        m.roughness.contents = roughness
        return m
    }

    let black = material(.black)
    let red = material(UIColor(red: 0.8, green: 0.02, blue: 0.06, alpha: 1))
    let white = material(.white)
    let skin = material(UIColor(red: 1, green: 0.72, blue: 0.55, alpha: 1))
    let pantsMat = material(UIColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1))
    let shoeMat = material(UIColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1))

    // MARK: - Thân áo hoodie
    let torso = SCNBox(
        width: 0.88,
        height: 0.95,
        length: 0.48,
        chamferRadius: 0.16
    )
    torso.materials = [black, black, black, black, black, black]

    let bodyNode = SCNNode(geometry: torso)
    bodyNode.name = "body"
    bodyNode.position = SCNVector3(0, 1.12, 0)
    player.addChildNode(bodyNode)

    // Áo đỏ bên trong
    let shirt = SCNBox(width: 0.42, height: 0.7, length: 0.025, chamferRadius: 0.04)
    shirt.firstMaterial = red

    let shirtNode = SCNNode(geometry: shirt)
    shirtNode.position = SCNVector3(0, 1.12, -0.25)
    player.addChildNode(shirtNode)

    // Logo trước ngực
    let logo = SCNBox(width: 0.22, height: 0.12, length: 0.025, chamferRadius: 0.025)
    logo.firstMaterial = red

    let logoNode = SCNNode(geometry: logo)
    logoNode.position = SCNVector3(0.2, 1.35, -0.26)
    player.addChildNode(logoNode)

    // MARK: - Đầu
    let head = SCNSphere(radius: 0.48)
    head.firstMaterial = skin

    let headNode = SCNNode(geometry: head)
    headNode.scale = SCNVector3(1, 1.05, 0.9)
    headNode.position = SCNVector3(0, 1.95, 0)
    player.addChildNode(headNode)

    // MARK: - Tóc trắng
    let hair = SCNSphere(radius: 0.49)
    hair.firstMaterial = white

    let hairNode = SCNNode(geometry: hair)
    hairNode.scale = SCNVector3(1.05, 0.55, 1)
    hairNode.position = SCNVector3(0, 2.25, 0.02)
    player.addChildNode(hairNode)

    // Tóc mái
    for i in -2...2 {
        let spike = SCNCone(topRadius: 0.015, bottomRadius: 0.13, height: 0.32)
        spike.firstMaterial = white

        let node = SCNNode(geometry: spike)
        node.position = SCNVector3(Float(i) * 0.15, 2.12, -0.34)
        node.eulerAngles.x = -0.55
        player.addChildNode(node)
    }

    // MARK: - Khuôn mặt
    for x: Float in [-0.17, 0.17] {
        let eye = SCNSphere(radius: 0.055)
        eye.firstMaterial = black

        let eyeNode = SCNNode(geometry: eye)
        eyeNode.scale = SCNVector3(1, 1.2, 0.5)
        eyeNode.position = SCNVector3(x, 1.98, -0.415)
        player.addChildNode(eyeNode)
    }

    // Khẩu trang đỏ
    let mask = SCNBox(width: 0.48, height: 0.2, length: 0.055, chamferRadius: 0.06)
    mask.firstMaterial = red

    let maskNode = SCNNode(geometry: mask)
    maskNode.position = SCNVector3(0, 1.79, -0.42)
    player.addChildNode(maskNode)

    // MARK: - Hai chân quần
    for x: Float in [-0.23, 0.23] {
        let leg = SCNCapsule(capRadius: 0.16, height: 0.85)
        leg.firstMaterial = pantsMat

        let legNode = SCNNode(geometry: leg)
        legNode.name = x < 0 ? "leftLeg" : "rightLeg"
        legNode.position = SCNVector3(x, 0.48, 0)
        player.addChildNode(legNode)

        // Giày
        let shoe = SCNBox(width: 0.3, height: 0.19, length: 0.48, chamferRadius: 0.07)
        shoe.firstMaterial = shoeMat

        let shoeNode = SCNNode(geometry: shoe)
        shoeNode.position = SCNVector3(x, 0.1, -0.1)
        player.addChildNode(shoeNode)

        // Đế giày đỏ
        let sole = SCNBox(width: 0.31, height: 0.045, length: 0.49, chamferRadius: 0.02)
        sole.firstMaterial = red

        let soleNode = SCNNode(geometry: sole)
        soleNode.position = SCNVector3(x, 0.025, -0.1)
        player.addChildNode(soleNode)
    }

    // MARK: - Hai tay áo
    for x: Float in [-0.57, 0.57] {
        let arm = SCNCapsule(capRadius: 0.14, height: 0.76)
        arm.firstMaterial = black

        let armNode = SCNNode(geometry: arm)
        armNode.name = x < 0 ? "leftArm" : "rightArm"
        armNode.position = SCNVector3(x, 1.12, 0)
        armNode.eulerAngles.z = x < 0 ? -0.18 : 0.18
        player.addChildNode(armNode)

        // Bàn tay
        let hand = SCNSphere(radius: 0.14)
        hand.firstMaterial = skin

        let handNode = SCNNode(geometry: hand)
        handNode.position = SCNVector3(x, 0.7, -0.02)
        player.addChildNode(handNode)

        // Viền tay áo đỏ
        let cuff = SCNTorus(ringRadius: 0.13, pipeRadius: 0.035)
        cuff.firstMaterial = red

        let cuffNode = SCNNode(geometry: cuff)
        cuffNode.position = SCNVector3(x, 0.78, 0)
        cuffNode.eulerAngles.x = .pi / 2
        player.addChildNode(cuffNode)
    }

    return player
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

        
// MARK: - Character Animation
let isMoving = abs(inputX) > 0.05 || abs(inputY) > 0.05
let animationTime = Float(time) * (crouching ? 5.0 : 10.0)

let leftLeg = player.childNode(withName: "leftLeg", recursively: false)
let rightLeg = player.childNode(withName: "rightLeg", recursively: false)
let leftArm = player.childNode(withName: "leftArm", recursively: false)
let rightArm = player.childNode(withName: "rightArm", recursively: false)

let runAmount: Float = isMoving ? 1.0 : 0.0

let legSwing = sin(animationTime) * 0.65 * runAmount
let armSwing = sin(animationTime + .pi) * 0.55 * runAmount

leftLeg?.eulerAngles.x = legSwing
rightLeg?.eulerAngles.x = -legSwing

leftArm?.eulerAngles.x = armSwing
rightArm?.eulerAngles.x = -armSwing

// Cúi người khi ngồi xuống
if let body = body {
    body.scale.y = crouching ? 0.65 : 1.0
    body.eulerAngles.x = crouching ? -0.18 : 0
}

        player.position.x += moveX * speed * delta
        player.position.z += moveZ * speed * delta

        if abs(moveX) > 0.05 || abs(moveZ) > 0.05 {
    player.eulerAngles.y = atan2(-moveX, -moveZ)
}

// Đồng bộ hướng camera
camera.eulerAngles.y = cameraYaw - player.eulerAngles.y

        

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
    guard let body = body,
          let player = player else { return }

    body.removeAllActions()

    let rightArm = player.childNode(
        withName: "rightArm",
        recursively: false
    )

    guard let arm = rightArm else { return }

    arm.removeAllActions()

    let windUp = SCNAction.rotateTo(
        x: 0.65, y: 0, z: 0.15,
        duration: 0.10
    )

    let punch = SCNAction.rotateTo(
        x: -1.35, y: 0, z: -0.1,
        duration: 0.09
    )

    let recover = SCNAction.rotateTo(
        x: 0, y: 0, z: 0,
        duration: 0.18
    )

    arm.runAction(
        SCNAction.sequence([
            windUp,
            punch,
            recover
        ])
    )

    body.runAction(
        SCNAction.sequence([
            SCNAction.scale(to: 1.08, duration: 0.08),
            SCNAction.scale(to: 1.0, duration: 0.12)
        ])
    )
}

}
}

struct JoystickView: View {
    @Binding var movement: CGSize

    var body: some View {
        GeometryReader { geo in
            let limit = min(geo.size.width, geo.size.height) / 2 - 27

            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.65))
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.7), lineWidth: 2)
                    }

                Circle()
                    .fill(Color.red)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle().stroke(Color.white, lineWidth: 2)
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
