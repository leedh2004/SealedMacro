public enum AccessLevel: String, CaseIterable {
    case `private` = "private"
    case `fileprivate` = "fileprivate"
    case `internal` = "internal"
    case `public` = "public"
    case `open` = "open"
}

extension AccessLevel {
    public var initalizerModifier: String {
        switch self {
        case .private:
            return "internal"
        case .fileprivate, .internal, .public:
            return self.rawValue
        case .open:
            return "public"
        }
    }
}
