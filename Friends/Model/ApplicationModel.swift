//
//  ApplicationModel.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI

class ApplicationModel: ObservableObject {

    private let eventTap = EventTap()
    private var panel: NSPanel?

    lazy var scene: DesktopScene = {
        let scene = DesktopScene()
        scene.size = NSScreen.main!.frame.size
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }()

    @MainActor init() {
        start()
    }

    @MainActor func start() {

        eventTap.delegate = self
        eventTap.start()

        DispatchQueue.main.async {
            self.show()
        }
    }

    @MainActor func show() {

        let panel = NSPanel(contentViewController: NSHostingController(rootView: DesktopView(scene: scene)))
        panel.setFrame(CGRectMake(0, 0, 400, 400), display: false)
        panel.backgroundColor = .clear
        panel.isMovable = false
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isFloatingPanel = true
        panel.styleMask = [.borderless, .hudWindow, .nonactivatingPanel]
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.setFrame(NSScreen.main!.frame, display: true)
        panel.orderFrontRegardless()

        self.panel = panel
    }

}

extension ApplicationModel: EventTapDelegate {

    func eventTap(_ eventTap: EventTap, handleEvent event: NSEvent) -> Bool {
        if event.type == .leftMouseDown, let location = panel?.convertPoint(fromScreen: event.locationInWindow) {
            scene.add(location: location)
        }
        return false
    }

}
