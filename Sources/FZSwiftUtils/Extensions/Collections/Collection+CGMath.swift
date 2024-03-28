//
//  Collection+Rect.swift
//
//
//  Created by Florian Zand on 28.03.24.
//

#if canImport(simd)
import Foundation
import simd

public extension Collection where Element == CGPoint {
    /// Returns the point with the smallest distance to the specified point.
    func closed(to point: CGPoint) -> CGPoint? {
        compactMap({(point: $0, distance: $0.distance(to: point ))}).sorted(by: \.distance, .smallestFirst).first?.point
    }
}

public extension Collection where Element == CGRect {
    /// Returns the rect in the center.
    func centeredRect() -> CGRect? {
        return centeredRect(in: union().center)
    }
    
    /// Returns the rect in the center of the specified point.
    func centeredRect(in point: CGPoint) -> CGRect? {
        return min { [point = SIMD2(point)] in point.getSignedDistance(to: $0) }
    }
    
    /// Returns the rect in the center of the specified rect.
    func centeredRect(in rect: CGRect) -> CGRect? {
        return centeredRect(in: rect.center)
    }
    
    /// Returns the index of the rect in the center.
    func indexOfCenteredRect() -> Index? {
        if let rect = centeredRect() {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
    
    /// Returns the index of the rect in the center of the specified point.
    func indexOfCenteredRect(in point: CGPoint) -> Index? {
        if let rect = centeredRect(in: point) {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
    
    /// Returns the  index of rect in the center of the specified rect.
    func indexOfCenteredRect(in rect: CGRect) -> Index? {
        if let rect = centeredRect(in: rect) {
            return firstIndex(of: rect) ?? nil
        }
        return nil
    }
    
    func centeredRectAlt() -> CGRect? {
        return centeredRectAlt(in: union().center)
    }
    
    func centeredRectAlt(in point: CGPoint) -> CGRect? {
        guard !isEmpty else { return nil }
        return compactMap({(rect: $0, distance: $0.center.distance(to: point)) }).sorted(by: \.distance, .smallestFirst).first?.rect
    }
    
    func centeredRectAlt(in rect: CGRect) -> CGRect? {
        return centeredRectAlt(in: rect.center)
    }
}

protocol CGFloat2 {
  var x: CGFloat { get }
  var y: CGFloat { get }
}

extension CGPoint: CGFloat2 { }

extension CGSize: CGFloat2 {
  public var x: CGFloat { width }
  public var y: CGFloat { height }
}

extension SIMD2 where Scalar == CGFloat.NativeType {
  init<Float2: CGFloat2>(_ float2: Float2) {
    self.init(x: float2.x, y: float2.y)
  }

  init(x: CGFloat, y: CGFloat) {
    self.init(x: x.native, y: y.native)
  }

  /// Distance to the closest point on the rectangle's boundary.
  /// - Note: Negative if inside the rectangle.
  func getSignedDistance(to rect: CGRect) -> Scalar {
    let distances =
      abs( self - Self(rect.center) )
      - Self(rect.size) / 2
    return
      all(sign(distances) .> 0)
      ? length(distances)
      : distances.max()
  }
}

extension Sequence {
  func min<Comparable: Swift.Comparable>(
    by getComparable: (Element) throws -> Comparable
  ) rethrows -> Element? {
    try self.min {
      try getComparable($0) < getComparable($1)
    }
  }
}
#endif
