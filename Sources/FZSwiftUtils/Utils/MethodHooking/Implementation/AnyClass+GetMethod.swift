//
//  Utilities.swift
//
//
//  Created by Yanni Wang on 7/5/20.
//  Copyright © 2020 Yanni. All rights reserved.
//

import Foundation

func getMethodWithoutSearchingSuperClasses(targetClass: AnyClass, selector: Selector) -> Method? {
    var methodCount: UInt32 = 0
    guard let methodList = class_copyMethodList(targetClass, &methodCount) else { return nil }
    defer { free(methodList) }
    for index in 0..<Int(methodCount) {
        let method = methodList[index]
        if method_getName(method) == selector {
            return method
        }
    }
    return nil
}
