//
//  DesktopView.swift
//  Friends
//
//  Created by Jason Barrie Morley on 06/01/2023.
//

import SpriteKit
import SwiftUI

struct DesktopView: View {

    var scene: SKScene

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .ignoresSafeArea()
    }

}
