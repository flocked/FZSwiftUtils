import Foundation

extension NSObject {
    /// Errors encountered while hooking (swizzling) methods.
    public enum SwizzleError: LocalizedError, Equatable {

        /// The target method could not be found.
        case methodNotFound(AnyClass, Selector)

        /// The implementation (IMP) of the method could not be found, indicating an inconsistent state.
        case nonExistingImplementation(AnyClass, Selector)

        /// A conflict was detected where the method implementation was unexpectedly modified by another operation.
        case unexpectedImplementation(AnyClass, Selector, IMP?)

        /// Failed to allocate a new class pair (subclass) required for object-based interposing.
        case subclassAllocationFailed(class: AnyClass, subclassName: String)

        /// Failed to add a method to the class.
        case unableToAddMethod(AnyClass, Selector)

        /// The object already responds to the selector intended for addition.
        case methodAlreadyExistsOnObject(AnyObject, Selector)

        /// The type encoding (method signature) could not be determined.
        case typeEncodingFailed(AnyClass, Selector)

        /// The object is currently using Key-Value Observing (KVO), which conflicts with swizzling.
        case keyValueObservationDetected(AnyObject)

        /// The object is reporting incorrect class metadata, suggesting interference from other libraries.
        case objectPosingAsDifferentClass(AnyObject, actualClass: AnyClass)

        /// The operation failed due to an invalid state (e.g., trying to apply a hook twice).
        case invalidState(expectedState: String)

        /// The reset (revert) operation is unsupported for the current configuration.
        case resetUnsupported(_ reason: String)

        /// The target object no longer exists (has been deallocated).
        case objectDoesntExistAnymore

        /// A generic failure with a specific reason provided.
        case unknownError(_ reason: String)
        
        public var errorDescription: String? {
            switch self {
            case .methodNotFound(let klass, let selector):
                return "Method '\(selector)' not found on \(klass)."
            case .nonExistingImplementation(let klass, let selector):
                return "Implementation for '\(selector)' on \(klass) could not be found."
            case .unexpectedImplementation(let klass, let selector, let imp):
                return "Unexpected implementation detected for '\(selector)' on \(klass). Current IMP: \(String(describing: imp))."
            case .subclassAllocationFailed(let klass, let subclassName):
                return "Failed to allocate class pair for subclass \(subclassName) of \(klass)."
            case .unableToAddMethod(let klass, let selector):
                return "Unable to add method '\(selector)' to \(klass)."
            case .methodAlreadyExistsOnObject(let object, let selector):
                return "Cannot add method '\(selector)' because the object \(object) already implements it."
            case .typeEncodingFailed(let klass, let selector):
                return "Type encoding failed for '\(selector)' on \(klass)."
            case .keyValueObservationDetected(let object):
                return "Object cannot be hooked while Key-Value Observing (KVO) is active: \(object)."
            case .objectPosingAsDifferentClass(let object, let actualClass):
                return "Object \(type(of: object)) is posing as a different class (\(NSStringFromClass(actualClass))). Hooking rejected."
            case .invalidState(let expectedState):
                return "The operation failed due to an invalid state. Expected state: \(expectedState)."
            case .resetUnsupported:
                return "Reset or revert hook is unsupported."
            case .objectDoesntExistAnymore:
                return "The target object no longer exists."
            case .unknownError:
                return "An unknown error occurred."
            }
        }

        public var failureReason: String? {
            switch self {
            case .methodNotFound:
                return "The selector does not exist on the target class. This often happens when using stringified selectors that are incorrect or non-existent."
            case .nonExistingImplementation:
                return "The class appears to be in an inconsistent state where a method exists but its implementation pointer is missing."
            case .unexpectedImplementation:
                return "The method implementation was unexpectedly modified, likely due to another swizzling operation. Reverting this hook may cause issues."
            case .subclassAllocationFailed:
                return "Unable to register a runtime subclass required for object-based interposing."
            case .unableToAddMethod:
                return "The runtime operation to add the method failed. This may be due to restrictions on the class or system limitations."
            case .methodAlreadyExistsOnObject:
                return "The target object already responds to the selector, preventing the addition of a new implementation."
            case .typeEncodingFailed:
                return "The method signature could not be correctly determined, which is necessary for swizzling."
            case .keyValueObservationDetected:
                return "KVO uses runtime subclasses that conflict with object-based hooking. Attempting to swizzle an object with active KVO can lead to crashes."
            case .objectPosingAsDifferentClass:
                return "This behavior often indicates interference from other swizzling libraries, which can cause instability. Hooking is rejected to prevent crashes."
            case .invalidState:
                return "The current state is not valid for this operation."
            case .resetUnsupported(let reason), .unknownError(let reason):
                return reason
            case .objectDoesntExistAnymore:
                return "The object was deallocated before the operation could complete."
            }
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.errorDescription == rhs.errorDescription
        }
        
        @discardableResult func log() -> NSObject.SwizzleError {
            Interpose.log(self.errorDescription!)
            return self
        }
    }
}
