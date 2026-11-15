
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(
            rootView: GameRootView()
        )
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return .landscape
    }
}

import SwiftUI

struct GameLoginView: View {
    @AppStorage("chibi_guest_started")
    private var guestStarted = false

    @State private var enterGame = false
    @State private var showLoginInfo = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Nền thành phố phong cách neon
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.04, blue: 0.19),
                        Color(red: 0.45, green: 0.10, blue: 0.20),
                        Color(red: 0.95, green: 0.32, blue: 0.12),
                        Color(red: 0.08, green: 0.04, blue: 0.13)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Ánh sáng thành phố
                GeometryReader { backgroundGeo in
                    ForEach(0..<22, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                i % 2 == 0
                                ? Color.pink.opacity(0.45)
                                : Color.cyan.opacity(0.35)
                            )
                            .frame(
                                width: CGFloat(12 + (i % 4) * 8),
                                height: CGFloat(45 + (i % 5) * 15)
                            )
                            .position(
                                x: CGFloat(i) * backgroundGeo.size.width / 21,
                                y: backgroundGeo.size.height * 0.78
                            )
                    }
                }
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    Spacer()

                    Text("CHIBI")
                        .font(.system(size: 55, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .red, radius: 15)

                    Text("GANG WAR")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 5)

                    Text("CITY DOMINATION")
                        .font(.system(size: 15, weight: .heavy))
                        .tracking(6)
                        .foregroundColor(.yellow)

                    Spacer()

                    VStack(spacing: 12) {
                        Button {
                            enterGame = true
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("VÀO GAME VỚI TƯ CÁCH KHÁCH")
                            }
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                            .frame(maxWidth: 340)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [.red, Color(red: 0.55, green: 0, blue: 0.08)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white, lineWidth: 2)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            showLoginInfo = true
                        } label: {
                            Text("ĐĂNG NHẬP / LIÊN KẾT TÀI KHOẢN")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .buttonStyle(.plain)
                    }

                    Text("OFFLINE MODE • PHIÊN BẢN ĐẦU TIÊN")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 8)

                    Spacer()
                }
                .padding()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .fullScreenCover(isPresented: $enterGame) {
                GameRootView()
                    .preferredColorScheme(.dark)
            }
            .alert("Đăng nhập tài khoản", isPresented: $showLoginInfo) {
                Button("Đóng", role: .cancel) {}
            } message: {
                Text("Đăng nhập Apple và liên kết tài khoản online sẽ được bổ sung ở phiên bản sau. Hiện tại bạn có thể chơi offline bằng tài khoản khách.")
            }
        }
    }
}
