import Foundation
import XCTest
import Sealed

final class ParsingTests: XCTestCase {
    func testSealedClassParsing() {
        let json = """
        {
            "type": "LOTTIE",
            "lottieURL": "https://github.com/images"
        }
        """

        let jsonData = Data(json.utf8)
        let decoder = JSONDecoder()
        let imageSource = try? decoder.decode(ImageSource.self, from: jsonData)

        XCTAssertTrue(imageSource != nil)
    }
}

@Sealed(typeParseRule: .upperCase)
private enum ImageSource {
    case image(Image), lottie(Lottie), icon(Icon)
}

public struct Image: Codable {
    var imageURL: String
}

public struct Lottie: Codable {
    var lottieURL: String
}

public struct Icon: Codable {
    var iconURL: String
}
