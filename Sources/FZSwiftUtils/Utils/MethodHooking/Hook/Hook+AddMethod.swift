//
//  Hook+AddMethod.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 11.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension Hook {
    class Add: Hook {
        let hook: AnyHook
        weak var object: AnyObject?
        
        init(for object: NSObject, selector: Selector, hookClosure: AnyObject) throws {
            self.hook = try AddMethodHook(object: object, selector: selector, hookClosure: hookClosure)
            super.init(selector: selector, hookClosure: hookClosure, mode: .instead, class_: type(of: object))
            self.object = object
        }
        
        init<T: NSObject>(for class_: T.Type, selector: Selector, hookClosure: AnyObject) throws {
            self.hook = try AddInstanceMethodHook(class_: class_, selector: selector, hookClosure: hookClosure)
            super.init(selector: selector, hookClosure: hookClosure, mode: .instead, class_: class_)
        }
        
        override var isActive: Bool {
            get { hook.isActive }
            set { newValue ? try? apply() : try? revert() }
        }
        
        override func apply() throws {
            guard !isActive else { return }
            try hookSerialQueue.syncSafely {
                if hook is AddInstanceMethodHook {
                    try hook.apply()
                    ClassHooks(self.class).addHook(self)
                } else if let object = object {
                    try hook.apply()
                    ObjectHooks(object).addHook(self)
                }
            }
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            try hookSerialQueue.syncSafely {
                try hook.revert()
                guard remove else { return }
                if hook is AddInstanceMethodHook {
                    ClassHooks(self.class).removeHook(self)
                } else if let object = object {
                    ObjectHooks(object).removeHook(self)
                }
            }
        }
    }
}
#endif
