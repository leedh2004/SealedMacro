@attached(member, names: named(init), named(encode), named(TypeCodingKey), named(ParseCodingKey))
public macro Sealed(typeKey: String = "type", typeParseRule: TypeParseRule) = #externalMacro(module: "SealedMacros", type: "SealedMacro")

public enum TypeParseRule {
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
}
