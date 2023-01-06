
import Foundation
import SwiftUI

// See https://stackoverflow.com/questions/31891002/how-do-you-use-cgeventtapcreate-in-swift
private func eventTapCallback(proxy: CGEventTapProxy,
                      type: CGEventType,
                      event: CGEvent,
                      refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else {
        return Unmanaged.passRetained(event)
    }
    let eventTap = Unmanaged<EventTap>.fromOpaque(refcon).takeUnretainedValue()
    return eventTap.handleEvent(proxy: proxy, type: type, event: event)
}

protocol EventTapDelegate: AnyObject {

    func eventTap(_ eventTap: EventTap, handleEvent event: NSEvent) -> Bool

}

class EventTap {

    var eventTap: CFMachPort? = nil

    weak var delegate: EventTapDelegate?

    init() {
    }

    func createEventTapIfNecessry() {
        guard eventTap == nil else {
            return
        }

        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: .allEvents,
                                               callback: eventTapCallback,
                                               userInfo: Unmanaged.passUnretained(self).toOpaque()) else {
            print("Failed to create event tap")
            exit(1)
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        self.eventTap = eventTap
    }

    func start() {
        createEventTapIfNecessry()
        guard let eventTap = eventTap else {
            print("No event tap to disable")
            return
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func stop() {
        print("disableTap")
        guard let eventTap = eventTap else {
            return
        }
        CGEvent.tapEnable(tap: eventTap, enable: false)
    }

    func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard let nsEvent = NSEvent(cgEvent: event),
              delegate?.eventTap(self, handleEvent: nsEvent) ?? false
        else {
            return Unmanaged.passRetained(event)
        }
        return nil
    }

}
