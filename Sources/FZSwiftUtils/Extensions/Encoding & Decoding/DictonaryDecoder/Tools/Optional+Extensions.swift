import Foundation

extension Optional where Wrapped: Collection {
    internal var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}
