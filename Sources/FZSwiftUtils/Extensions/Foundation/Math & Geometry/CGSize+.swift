//
//  CGSize+.swift
//  
//
//  Created by Florian Zand on 16.03.23.
//

import Foundation
import CoreGraphics

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.width)
        hasher.combine(self.height)
    }
}

public extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
    
    var scaledIntegral: CGSize {
        CGSize(width: width.scaledIntegral, height: height.scaledIntegral)
    }
    
    var aspectRatio: CGFloat {
        if height == 0 { return 1 }
        return width / height
    }
    
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        return CGSize(width: self.width.rounded(rule), height: self.height.rounded(rule))
    }
    
    func scaled(toWidth newWidth: CGFloat) -> CGSize {
        let scale = newWidth / self.width
        let newHeight = self.height * scale
        return CGSize(width: newWidth, height: newHeight)
    }
    
    func scaled(toHeight newHeight: CGFloat) -> CGSize {
        let scale = newHeight / self.height
        let newWidth = self.width * scale
        return CGSize(width: newWidth, height: newHeight)
    }
    
    func scaled(byFactor factor: CGFloat) -> CGSize {
        return CGSize(width: self.width*factor, height: self.height*factor)
    }
    
    func scaled(toFit innerRect: CGSize) -> CGSize {
        let outerRect = self
        
        // the width and height ratios of the rects
        let wRatio = outerRect.width / innerRect.width
        let hRatio = outerRect.height / innerRect.height
        
        // calculate scaling ratio based on the smallest ratio.
        let ratio = (wRatio > hRatio) ? wRatio : hRatio
        
        // aspect fitted origin and size
        return CGSize(
            width: outerRect.width / ratio,
            height: outerRect.height / ratio
        )
    }
    
    func scaled(toFill innerRect: CGSize) -> CGSize {
        let outerRect = self
        
        // the width and height ratios of the rects
        let wRatio = outerRect.width / innerRect.width
        let hRatio = outerRect.height / innerRect.height
        
        // calculate scaling ratio based on the smallest ratio.
        let ratio = (wRatio < hRatio) ? wRatio : hRatio
        
        // aspect fitted origin and size
        return CGSize(
            width: outerRect.width / ratio,
            height: outerRect.height / ratio
        )
    }
}

extension CGSize {
    public static func + (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width + r.width, height: l.height + r.height)
    }
    
    public static func + (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width + r, height: l.height + r)
    }
    
    public static func + (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width + r, height: l.height + r)
    }
    
    public static func - (l: CGSize, r: CGSize) -> CGSize {
        return CGSize(width: l.width - r.width, height: l.height - r.height)
    }
    
    public static func - (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width - r, height: l.height - r)
    }
    
    public static func - (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width - r, height: l.height - r)
    }
    
    public static func * (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width * r, height: l.height * r)
    }
    
    public static func * (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width * r, height: l.height * r)
    }
    
    public static func / (l: CGSize, r: CGFloat) -> CGSize {
        return CGSize(width: l.width / r, height: l.height / r)
    }
    
    public static func / (l: CGSize, r: Double) -> CGSize {
        return CGSize(width: l.width / r, height: l.height / r)
    }
    
    public static func += (l:inout CGSize, r:CGSize) {
        l = CGSize(width:l.width+r.width,height:l.height+r.width)
    }
    
    public static func += (l:inout CGSize, r:CGFloat) {
        l = CGSize(width:l.width+r,height:l.height+r)
    }
    
    public static func += (l:inout CGSize, r:Double) {
        l = CGSize(width:l.width+r,height:l.height+r)
    }
    
    public static func -= (l:inout CGSize, r:CGSize) {
        l = CGSize(width:l.width-r.width,height:l.height-r.width)
    }
    
    public static func -= (l:inout CGSize, r:CGFloat) {
        l = CGSize(width:l.width-r,height:l.height-r)
    }
    
    public static func -= (l:inout CGSize, r:Double) {
        l = CGSize(width:l.width-r,height:l.height-r)
    }
    
    public static func *= (l:inout CGSize, r:CGFloat) {
        l = CGSize(width:l.width*r,height:l.height*r)
    }
    
    public static func *= (l:inout CGSize, r:Double) {
        l = CGSize(width:l.width*r,height:l.height*r)
    }
}

extension CGSize: Comparable {
  public static func > (lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width * lhs.height > rhs.width * rhs.height
  }

  public static func >= (lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width * lhs.height >= rhs.width * rhs.height
  }

  public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width * lhs.height < rhs.width * rhs.height
  }

  public static func <= (lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width * lhs.height <= rhs.width * rhs.height
  }
}
