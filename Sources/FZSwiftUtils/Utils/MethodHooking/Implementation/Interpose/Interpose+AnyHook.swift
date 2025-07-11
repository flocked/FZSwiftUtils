import Foundation

/// Base class, represents a hook to exactly one method.
public class AnyHook: Hashable {
    /// The class this hook is based on.
    public let `class`: AnyClass

    /// The selector this hook interposes.
    public let selector: Selector

    /// The current state of the hook.
    public internal(set) var state = State.prepared
    
    let id = UUID()

    // else we validate init order
    var replacementIMP: IMP!

    // Fetched at apply time, changes late, thus class requirement
    var origIMP: IMP?
    
    var isActive: Bool {
        state == .interposed
    }

    /// The possible task states
    public enum State: Equatable {
        /// The task is prepared to be nterposed.
        case prepared

        /// The method has been successfully interposed.
        case interposed

        /// An error happened while interposing a method.
        indirect case error(NSObject.SwizzleError)
    }

    init(`class`: AnyClass, selector: Selector, shouldValidate: Bool = true) throws {
        self.selector = selector
        self.class = `class`

        guard shouldValidate else { return }
        try validate()
    }

    func replaceImplementation() throws {
        preconditionFailure("Not implemented")
    }

    func resetImplementation() throws {
        preconditionFailure("Not implemented")
    }

    /// Apply the interpose hook.
    @discardableResult public func apply() throws -> AnyHook {
       // guard state != .
        try execute(newState: .interposed) { try replaceImplementation() }
        return self
    }

    /// Revert the interpose hoook.
    @discardableResult public func revert() throws -> AnyHook {
        try execute(newState: .prepared) { try resetImplementation() }
        return self
    }

    /// Validate that the selector exists on the active class.
    @discardableResult func validate(expectedState: State = .prepared) throws -> Method {
        guard let method = class_getInstanceMethod(`class`, selector) else {
            throw NSObject.SwizzleError.methodNotFound(`class`, selector)
        }
        guard state == expectedState else { throw NSObject.SwizzleError.invalidState(expectedState: expectedState.description) }
        return method
    }

    private func execute(newState: State, task: () throws -> Void) throws {
        do {
            try task()
            state = newState
        } catch let error as NSObject.SwizzleError {
            state = .error(error)
            throw error
        }
    }

    /// Release the hook block if possible.
    public func cleanup() {
        switch state {
        case .prepared:
            Interpose.log("Releasing -[\(`class`).\(selector)] IMP: \(replacementIMP!)")
            imp_removeBlock(replacementIMP)
        case .interposed:
            Interpose.log("Keeping -[\(`class`).\(selector)] IMP: \(replacementIMP!)")
        case let .error(error):
            Interpose.log("Leaking -[\(`class`).\(selector)] IMP: \(replacementIMP!) due to error: \(error)")
        }
    }
    
    public static func == (lhs: AnyHook, rhs: AnyHook) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AnyHook.State {
    var description: String {
        switch self {
        case .prepared: return "prepared"
        case .interposed: return "interposed"
        case .error(let swizzleError): return "error: \(swizzleError)"
        }
    }
}

/// Hook baseclass with generic signatures.
public class TypedHook<MethodSignature, HookSignature>: AnyHook {
    /// The original implementation of the hook. Might be looked up at runtime. Do not cache this.
    public var original: MethodSignature {
        preconditionFailure("Always override")
    }
}
