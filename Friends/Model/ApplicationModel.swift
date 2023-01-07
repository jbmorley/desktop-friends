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
    private var timer: Timer?

    lazy var scene: DesktopScene = {
        let scene = DesktopScene()
        scene.size = NSScreen.main!.frame.size
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        scene.setup()
        return scene
    }()

    @MainActor init() {
        start()
    }

    @MainActor func start() {

        eventTap.delegate = self
        eventTap.start()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.updateWindowList()
        }

        DispatchQueue.main.async {
            self.show()
        }
    }

    func updateWindowList() {

        var windows: [Int: CGRect] = [:]

        let screen = NSScreen.main!.frame
        let windowList: CFArray? = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID)
        for entry in windowList! as Array {
            if let windowNumber = entry.object(forKey: kCGWindowNumber) as? NSNumber,
               let bounds = entry.object(forKey: kCGWindowBounds) as? NSDictionary,
               let x = bounds["X"] as? NSNumber,
               let y = bounds["Y"] as? NSNumber,
               let width = bounds["Width"] as? NSNumber,
               let height = bounds["Height"] as? NSNumber {
                let frame = CGRectMake(x.doubleValue, y.doubleValue, width.doubleValue, height.doubleValue)
                if frame == screen {
                    // Ignore full-screen windows
                    continue
                }
                let invertedFrame = CGRectMake(x.doubleValue,
                                               screen.size.height - y.doubleValue,
                                               width.doubleValue,
                                               height.doubleValue)
                windows[windowNumber.intValue] = invertedFrame
            }
        }

        scene.update(windows: windows)
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
        if event.type == .leftMouseDown || event.type == .leftMouseDragged || event.type == .leftMouseUp,
           let location = panel?.convertPoint(fromScreen: event.locationInWindow) {  // TODO: Do we need this?
            return scene.handle(event: event)
        }
        return false
    }

}
