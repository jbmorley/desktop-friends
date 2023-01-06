//
//  FriendsApp.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI
import SpriteKit

struct Boxes: View {

    var scene: SKScene

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
//            .frame(width: 400, height: 400)
            .ignoresSafeArea()
//            .allowsHitTesting(false)
    }

}

class GameScene: SKScene {

    func add(location: CGPoint) {
        let box = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 40))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        addChild(box)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        add(location: location)
    }

    override func mouseMoved(with event: NSEvent) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func contains(_ p: CGPoint) -> Bool {
        return false
    }

}

class ApplicationModel: ObservableObject {

    private let eventTap = EventTap()
    private var panel: NSPanel?

    lazy var scene: GameScene = {
        let scene = GameScene()
//        scene.size = CGSize(width: 400, height: 400)
        scene.size = NSScreen.main!.frame.size
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }()

    @MainActor init() {
        start()
    }

    @MainActor func start() {
        DispatchQueue.main.async {
            self.show()
        }
    }

    @MainActor func show() {

        eventTap.delegate = self
        eventTap.start()

        dispatchPrecondition(condition: .onQueue(.main))

        let panel = NSPanel(contentViewController: NSHostingController(rootView: Boxes(scene: scene)))
        panel.setFrame(CGRectMake(0, 0, 400, 400), display: false)
        panel.backgroundColor = .clear
        panel.isMovable = false
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isFloatingPanel = true
        panel.styleMask = [.borderless, .hudWindow, .nonactivatingPanel]
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        if let screen = NSScreen.main {
            panel.setFrame(screen.frame, display: true)
//            scene.size = screen.frame.size
        }

        panel.orderFrontRegardless()

        self.panel = panel
    }

}

extension ApplicationModel: EventTapDelegate {

    func eventTap(_ eventTap: EventTap, handleEvent event: NSEvent) -> Bool {
        if event.type == .leftMouseDown {
            guard let location = panel?.convertPoint(fromScreen: event.locationInWindow) else {
                return false
            }
            scene.add(location: location)
            print(location)
        }
        return false
    }

}

@main
struct FriendsApp: App {

    @StateObject var applicationModel = ApplicationModel()

    var body: some Scene {
        MenuBarExtra {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "face.smiling")
        }
    }

}
