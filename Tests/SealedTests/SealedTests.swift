import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SealedMacros

private let testMacros: [String: Macro.Type] = [
    "Sealed": SealedMacro.self
]

final class SealedGeneratorTests: XCTestCase {
    func testSealedMacros_UpperCase() {
        let source = """
        @Sealed(typeKey: "kind", typeParseRule: .upperCase)
        public enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon(Icon)
        }
        """
        let expected = """
        public enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon(Icon)
            public init(from decoder: Decoder) throws {
                let typeContainer = try decoder.container(keyedBy: ImageSourceTypeCodingKey.self)
                let type = try typeContainer.decode(ImageSourceType.self, forKey: .kind)
                let container = try decoder.singleValueContainer()
                switch type {
                case .image:
                    self = .image(try container.decode(Image.self))
                case .lottie:
                    self = .lottie(try container.decode(Lottie.self))
                case .icon:
                    self = .icon(try container.decode(Icon.self))
                }
            }
        }
        private enum ImageSourceTypeCodingKey: String, CodingKey {
            case kind
        }
        private enum ImageSourceType: String, CodingKey, Codable {
            case image = "IMAGE"
            case lottie = "LOTTIE"
            case icon = "ICON"
        }
        extension ImageSource: Codable {
        }
        """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testSealedMacros_LowerCase() {
        let source = """
        @Sealed(typeParseRule: .lowerCase)
        enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon(Icon)
        }
        """
        let expected = """
        enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon(Icon)
            internal init(from decoder: Decoder) throws {
                let typeContainer = try decoder.container(keyedBy: ImageSourceTypeCodingKey.self)
                let type = try typeContainer.decode(ImageSourceType.self, forKey: .type)
                let container = try decoder.singleValueContainer()
                switch type {
                case .image:
                    self = .image(try container.decode(Image.self))
                case .lottie:
                    self = .lottie(try container.decode(Lottie.self))
                case .icon:
                    self = .icon(try container.decode(Icon.self))
                }
            }
        }
        private enum ImageSourceTypeCodingKey: String, CodingKey {
            case type
        }
        private enum ImageSourceType: String, CodingKey, Codable {
            case image = "image"
            case lottie = "lottie"
            case icon = "icon"
        }
        extension ImageSource: Codable {
        }
        """
        assertMacroExpansion(source, expandedSource: expected, macros: testMacros)
    }

    func testSealedMacros_FailCase() {
        let source = """
        @Sealed(typeParseRule: .lowerCase)
        enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon
        }
        """
        let expected = """
        enum ImageSource {
            case image(Image)
            case lottie(Lottie)
            case icon
        }
        private enum ImageSourceTypeCodingKey: String, CodingKey {
            case type
        }
        private enum ImageSourceType: String, CodingKey, Codable {
            case image = "image"
            case lottie = "lottie"
            case icon = "icon"
        }
        extension ImageSource: Codable {
        }
        """
        assertMacroExpansion(
            source,
            expandedSource: expected,
            diagnostics: [.init(
                message: "SealedMacro can apply only Enum that has all cases with associated type",
                line: 1,
                column: 1
            )],
            macros: testMacros
        )
    }
}
