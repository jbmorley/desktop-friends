//
//  CGRect.swift
//  Friends
//
//  Created by Jason Barrie Morley on 07/01/2023.
//

import CoreGraphics

extension CGRect {

    var position: CGPoint {
        return CGPoint(x: midX, y: midY - height)
    }

}
