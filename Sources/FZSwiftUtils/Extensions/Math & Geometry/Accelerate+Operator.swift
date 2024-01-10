//
//  Accelerate+Operator.swift
//
//
//  Created by Florian Zand on 04.12.23.
//

import Accelerate
import Foundation

infix operator .+: AdditionPrecedence
infix operator .-: AdditionPrecedence
infix operator .*: MultiplicationPrecedence
infix operator ./: MultiplicationPrecedence

infix operator .+=: AssignmentPrecedence
infix operator .-=: AssignmentPrecedence
infix operator .*=: AssignmentPrecedence
infix operator ./=: AssignmentPrecedence

public extension AccelerateBuffer where Element == Float {
    static func .+ (lhs: Self, rhs: Self) -> [Float] {
        vDSP.add(lhs, rhs)
    }

    static func .+ (lhs: ArraySlice<Float>, rhs: Self) -> [Float] {
        vDSP.add(lhs, rhs)
    }

    static func .+ (lhs: Self, rhs: ArraySlice<Float>) -> [Float] {
        vDSP.add(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: Self) -> [Float] {
        vDSP.subtract(lhs, rhs)
    }

    static func .- (lhs: ArraySlice<Float>, rhs: Self) -> [Float] {
        vDSP.subtract(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: ArraySlice<Float>) -> [Float] {
        vDSP.subtract(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Self) -> [Float] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: ArraySlice<Float>, rhs: Self) -> [Float] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: ArraySlice<Float>) -> [Float] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Float) -> [Float] {
        vDSP.multiply(rhs, lhs)
    }

    static func ./ (lhs: Self, rhs: Float) -> [Float] {
        vDSP.multiply(1.0 / rhs, lhs)
    }
}

public extension ArraySlice where Element == Float {
    static func .+ (lhs: Self, rhs: Self) -> [Float] {
        vDSP.add(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: Self) -> [Float] {
        vDSP.subtract(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Self) -> [Float] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Float) -> [Float] {
        vDSP.multiply(rhs, lhs)
    }

    static func ./ (lhs: Self, rhs: Float) -> [Float] {
        vDSP.multiply(1.0 / rhs, lhs)
    }
}

public extension AccelerateMutableBuffer where Element == Float {
    static func .+= (lhs: inout Self, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .+= (lhs: inout ArraySlice<Float>, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .+= (lhs: inout Self, rhs: ArraySlice<Float>) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout ArraySlice<Float>, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: ArraySlice<Float>) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout ArraySlice<Float>, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: ArraySlice<Float>) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Float) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    static func ./= (lhs: inout Self, rhs: Float) {
        vDSP.multiply(1.0 / rhs, lhs, result: &lhs)
    }
}

public extension ArraySlice where Element == Float {
    static func .+= (lhs: inout Self, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Float) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    static func ./= (lhs: inout Self, rhs: Float) {
        vDSP.multiply(1.0 / rhs, lhs, result: &lhs)
    }
}

public extension AccelerateBuffer where Element == Double {
    static func .+ (lhs: Self, rhs: Self) -> [Double] {
        vDSP.add(lhs, rhs)
    }

    static func .+ (lhs: ArraySlice<Double>, rhs: Self) -> [Double] {
        vDSP.add(lhs, rhs)
    }

    static func .+ (lhs: Self, rhs: ArraySlice<Double>) -> [Double] {
        vDSP.add(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: Self) -> [Double] {
        vDSP.subtract(lhs, rhs)
    }

    static func .- (lhs: ArraySlice<Double>, rhs: Self) -> [Double] {
        vDSP.subtract(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: ArraySlice<Double>) -> [Double] {
        vDSP.subtract(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Self) -> [Double] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: ArraySlice<Double>, rhs: Self) -> [Double] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: ArraySlice<Double>) -> [Double] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Double) -> [Double] {
        vDSP.multiply(rhs, lhs)
    }

    static func ./ (lhs: Self, rhs: Double) -> [Double] {
        vDSP.multiply(1.0 / rhs, lhs)
    }
}

public extension ArraySlice where Element == Double {
    static func .+ (lhs: Self, rhs: Self) -> [Double] {
        vDSP.add(lhs, rhs)
    }

    static func .- (lhs: Self, rhs: Self) -> [Double] {
        vDSP.subtract(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Self) -> [Double] {
        vDSP.multiply(lhs, rhs)
    }

    static func .* (lhs: Self, rhs: Double) -> [Double] {
        vDSP.multiply(rhs, lhs)
    }

    static func ./ (lhs: Self, rhs: Double) -> [Double] {
        vDSP.multiply(1.0 / rhs, lhs)
    }
}

public extension AccelerateMutableBuffer where Element == Double {
    static func .+= (lhs: inout Self, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .+= (lhs: inout ArraySlice<Double>, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .+= (lhs: inout Self, rhs: ArraySlice<Double>) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout ArraySlice<Double>, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: ArraySlice<Double>) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout ArraySlice<Double>, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: ArraySlice<Double>) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Double) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    static func ./= (lhs: inout Self, rhs: Double) {
        vDSP.multiply(1.0 / rhs, lhs, result: &lhs)
    }
}

public extension ArraySlice where Element == Double {
    static func .+= (lhs: inout Self, rhs: Self) {
        vDSP.add(lhs, rhs, result: &lhs)
    }

    static func .-= (lhs: inout Self, rhs: Self) {
        vDSP.subtract(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Self) {
        vDSP.multiply(lhs, rhs, result: &lhs)
    }

    static func .*= (lhs: inout Self, rhs: Double) {
        vDSP.multiply(rhs, lhs, result: &lhs)
    }

    static func ./= (lhs: inout Self, rhs: Double) {
        vDSP.multiply(1.0 / rhs, lhs, result: &lhs)
    }
}
