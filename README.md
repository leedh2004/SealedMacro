# SealedMacro
✨ Swift Macro, Parsing Sealed Class JSON Model. (ex. kotlin server's sealed class json)

## At a Glance

Server's Sealed Class JSON Response
```json
{
  "_type": "IMAGE",
  "imageURL": "https://github.com/images",
  "imageName": "source"
}
```
```json
{
  "_type": "LOTTIE",
  "lottieURL": "https://github.com/lotties"
}
```
```json
{
  "_type": "ICON_TYPE",
  "iconURL": "https://github.com/icons"
}
```

This is can parse with this Swift Model:

```swift
@Sealed(typeKey: "_type", typeParseRule: .upperSnakeCase)
enum ImageSource {
    case image(Image)
    case lottie(Lottie)
    case iconType(Icon)
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

// MARK: Test Decode & Encode 
func testSealedDecoingAndEncoding() {
  let json = """
  {
    "_type": "ICON_TYPE",
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

```
## Installation

Using Swift Package Manager:

```swift
import PackageDescription

let package = Package(
  name: "MyAwesomeApp",
  dependencies: [
    .package(url: "https://github.com/leedh2004/SealedMacro.git", from: "0.1.2")
  ]
)
```

## License
**SealedMacro** is under MIT license. See the [LICENSE](LICENSE) file for more info.
