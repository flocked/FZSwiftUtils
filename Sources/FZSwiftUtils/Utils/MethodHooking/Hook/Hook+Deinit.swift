//
//  Hook+Deinit.swift
//  FZSwiftUtils
//
//  Created by Florian Zand on 11.05.25.
//

#if os(macOS) || os(iOS)
import Foundation

extension Hook {
    class Deinit: Hook {
        weak var object: AnyObject?
        var delegate:  DeallocDelegate?
        
        init(_ object: AnyObject, hookClosure: AnyObject) throws {
            super.init(selector: .dealloc, hookClosure: hookClosure, mode: .after, class_: type(of: object))
            self.object = object
        }
        
        override var isActive: Bool {
            get { delegate != nil && object != nil }
            set { newValue ? try? apply() : try? revert() }
        }
        
        override func apply() throws {
            guard !isActive else { return }
            guard let object = object else { return }
            let delegate = getAssociatedValue("deinitDelegate", object: object, initialValue: DeallocDelegate())
            delegate.hookClosures.append(hookClosure)
            self.delegate = delegate
            _AnyObject(object).addHook(self)
        }
        
        override func revert(remove: Bool) throws {
            guard isActive else { return }
            guard let delegate = delegate else { return }
            delegate.hookClosures.removeFirst(where: { $0 === self.hookClosure })
            self.delegate = nil
            guard remove, let object = object else { return }
            _AnyObject(object).removeHook(self)
        }
        
        class DeallocDelegate {
            var hookClosures: [AnyObject] = []
            
            deinit {
                for item in hookClosures.reversed() {
                    unsafeBitCast(item, to: (@convention(block) () -> Void).self)()
                }
            }
        }
    }
}
#endif
