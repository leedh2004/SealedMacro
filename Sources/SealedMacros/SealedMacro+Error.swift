import Foundation

public extension SealedMacro {
    enum Error: Swift.Error, CustomStringConvertible {
        case shouldBeEnum
        case shouldAllCaseHasAssociatedType
        case invalidArgument

        public var description: String {
            switch self {
            case .shouldBeEnum:
                return "SealedMacro can apply only Enum"
            case .shouldAllCaseHasAssociatedType:
                return "SealedMacro can apply only Enum that has all cases with associated type"
            case .invalidArgument:
                return "there is invalid argumnet"
            }
        }
    }
}
