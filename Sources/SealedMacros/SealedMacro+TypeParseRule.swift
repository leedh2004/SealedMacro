import Foundation

enum TypeParseRule {
    case upperCase
    case lowerCase
    case lowerCamelCase
    case upperCamelCase
    case lowerSnakeCase
    case mixSnakeCase
    case upperSnakeCase
    case lowerKebabCase
    case mixedKebabCase
    case upperKebabCase
    case sameAsCaseName

    init?(rawValue: String) {
        switch rawValue {
        case ".upperCase":
            self = .upperCase
        case ".lowerCase":
            self = .lowerCase
        case ".lowerCamelCase":
            self = .lowerCamelCase
        case ".upperCamelCase":
            self = .upperCamelCase
        case ".lowerSnakeCase":
            self = .lowerSnakeCase
        case ".mixSnakeCase":
            self = .mixSnakeCase
        case ".upperSnakeCase":
            self = .upperSnakeCase
        case ".lowerKebabCase":
            self = .lowerKebabCase
        case ".mixedKebabCase":
            self = .mixedKebabCase
        case ".upperKebabCase":
            self = .upperKebabCase
        case ".sameAsCaseName":
            self = .sameAsCaseName
        default:
            return nil
        }
    }
}
