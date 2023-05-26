//
//  CGPoint+.swift
//
//
//  Created by Florian Zand on 16.03.23.
//

import CoreGraphics
import Foundation

public extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    func offset(by offset: CGPoint) -> CGPoint {
        return CGPoint(x: x + offset.x, y: y + offset.y)
    }

    func offset(x: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: y)
    }

    func offset(x: CGFloat = 0, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }

    func distance(to point: CGPoint) -> CGFloat {
        let xdst = x - point.x
        let ydst = y - point.y
        return sqrt((xdst * xdst) + (ydst * ydst))
    }

    var scaledIntegral: CGPoint {
        CGPoint(x: x.scaledIntegral, y: y.scaledIntegral)
    }

    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        return CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public extension CGPoint {
    static func + (l: CGPoint, r: CGPoint) -> CGPoint {
        return CGPoint(l.x + r.x, l.y + r.y)
    }

    static func + (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(l.x + r, l.y + r)
    }

    static func + (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(l.x + r, l.y + r)
    }

    static func - (l: CGPoint, r: CGPoint) -> CGPoint {
        return CGPoint(l.x - r.x, l.y - r.y)
    }

    static func - (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(l.x - r, l.y - r)
    }

    static func - (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(l.x - r, l.y - r)
    }

    static func * (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(x: l.x * r, y: l.y * r)
    }

    static func * (l: CGFloat, r: CGPoint) -> CGPoint {
        return CGPoint(x: l * r.x, y: l * r.y)
    }

    static func * (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(x: l.x * CGFloat(r), y: l.y * CGFloat(r))
    }

    static func * (l: Double, r: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat(l) * r.x, y: CGFloat(l) * r.y)
    }

    static func * (l: CGPoint, r: CGPoint) -> CGFloat {
        return l.x * r.x + l.y * r.y
    }

    static func / (l: CGPoint, r: CGFloat) -> CGPoint {
        return CGPoint(x: l.x / r, y: l.y / r)
    }

    static func / (l: CGPoint, r: Double) -> CGPoint {
        return CGPoint(x: l.x / CGFloat(r), y: l.y / CGFloat(r))
    }

    static func += (l: inout CGPoint, r: CGPoint) {
        l = CGPoint(x: l.x + r.x, y: l.y + r.y)
    }

    static func += (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x + r, y: l.y + r)
    }

    static func += (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x + r, y: l.y + r)
    }

    static func -= (l: inout CGPoint, r: CGPoint) {
        l = CGPoint(x: l.x - r.x, y: l.y - r.y)
    }

    static func -= (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x - r, y: l.y - r)
    }

    static func -= (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x - r, y: l.y - r)
    }

    static func *= (l: inout CGPoint, r: CGFloat) {
        l = CGPoint(x: l.x * r, y: l.y * r)
    }

    static func *= (l: inout CGPoint, r: Double) {
        l = CGPoint(x: l.x * CGFloat(r), y: l.y * CGFloat(r))
    }
}
