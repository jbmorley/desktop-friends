//
//  DesktopScene.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SwiftUI
import SpriteKit

import SpriteMap

class SpriteSheet {

    let image: CGImage
    let size: CGSize

    init?(size: CGSize) {
        guard let image = NSImage(named: "Sheep"),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return nil
        }
        self.image = cgImage
        self.size = size
    }

    func textureAt(index: Int) -> SKTexture? {
        guard let sprite = image.imageAt(index: index, size: size) else {
            return nil
        }
        return SKTexture(cgImage: sprite)
    }

}

class CharacterNode: SKSpriteNode {

    lazy var spriteSheet: SpriteSheet = {
        return SpriteSheet(size: CGSize(width: 40, height: 40))!
    }()

    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 40, height: 40))

        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))

        self.position = CGPoint(x: 200, y: 200)

        let textures = (0..<100).map { index in
            return spriteSheet.textureAt(index: index)!
        }

        let walkAnimation = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.3))
        run(walkAnimation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DesktopScene: SKScene {

    var windows: [Int: SKSpriteNode] = [:]
    var character: CharacterNode? = nil
    var selection: SKNode? = nil

    func setup() {
        let startPoint = CGPoint(x: 0, y: 0)
        let endPoint = CGPoint(x: size.width, y: 0)
        physicsBody = SKPhysicsBody(edgeFrom: startPoint, to: endPoint)
        physicsBody?.restitution = 0.8

        let character = CharacterNode()
        addChild(character)
        self.character = character
    }

    func handle(event: NSEvent) -> Bool {
        if event.type == .leftMouseDown {
            guard let character = nodes(at: event.locationInWindow).filter({ $0 == character }).first else {
                return false
            }
            selection = character
            character.physicsBody?.affectedByGravity = false
            return true
        } else if event.type == .leftMouseDragged {
            guard let selection = selection else {
                return false
            }
            selection.position = CGPoint(x: selection.position.x + event.deltaX, y: selection.position.y - event.deltaY)
            return true
        } else if event.type == .leftMouseUp {
            guard let selection = selection else {
                return false
            }
            selection.physicsBody?.affectedByGravity = true
            self.selection = nil
            return true
        }
        return false
    }

    func add(location: CGPoint) {
        let box = SKSpriteNode(color: .cyan, size: CGSize(width: 40, height: 40))
        box.position = location
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        addChild(box)
    }

    func update(windows: [Int: CGRect]) {

        let currentWindowIDs = Set(self.windows.keys)
        let updatedWindowIDs = Set(windows.keys)

        let removedWindowIDs = currentWindowIDs.subtracting(updatedWindowIDs)
        for windowID in removedWindowIDs {
            self.windows[windowID]?.removeFromParent()
        }
        self.windows = self.windows.filter { !removedWindowIDs.contains($0.key) }

        for windowID in updatedWindowIDs {
            set(windowID: windowID, frame: windows[windowID]!)
        }

    }

    private func set(windowID: Int, frame: CGRect) {
        if let windowSprite = windows[windowID] {
            windowSprite.position = frame.position
            windowSprite.size = frame.size
            // TODO: Update physicsBody shape
        } else {
            let windowSprite = SKSpriteNode(color: .clear, size: frame.size)
            windowSprite.position = frame.position
            let physicsBody = SKPhysicsBody(rectangleOf: frame.size)
            physicsBody.restitution = 0.8
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            windowSprite.physicsBody = physicsBody
            addChild(windowSprite)
            windows[windowID] = windowSprite
        }
    }

}
