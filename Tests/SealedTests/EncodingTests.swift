//
//  File.swift
//  
//
//  Created by 이도현A on 2023/07/01.
//

import Foundation
import XCTest
import Sealed

final class EncodingTests: XCTestCase {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    func testSealedClassEncoding() {
        let json = """
        {
          "type": "ICON",
          "iconURL": "https://github.com/icons"
        }
        """
        let jsonData = Data(json.utf8)
        let imageSource = try? decoder.decode(ImageSource.self, from: jsonData)
        XCTAssertTrue(imageSource != nil)

        let encodedData = try? encoder.encode(imageSource)
        XCTAssertTrue(encodedData != nil)
        let reDecodedImageSource = try? decoder.decode(ImageSource.self, from: encodedData!)

        XCTAssertTrue(reDecodedImageSource != nil)
    }
}

@Sealed(typeParseRule: .upperCase)
private enum ImageSource {
    case image(Image)
    case lottie(Lottie)
    case icon(Icon)
}
extension ImageSource {
  struct Image: Codable {
    var imageURL: String
    var imageName: String
  }

  struct Lottie: Codable {
    var lottieURL: String
  }

  struct Icon: Codable {
    var iconURL: String
  }
}
