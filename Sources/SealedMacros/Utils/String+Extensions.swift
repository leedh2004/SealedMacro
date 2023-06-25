import Foundation

extension String {
    var words: [String] {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
    }

    func lowerCamelCased() -> String {
        guard !self.isEmpty else { return "" }
        let words = self.words
        let first = words.first!.lowercased()
        let rest = words.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }

    func upperCamelCased() -> String {
        return self.words.map({ $0.capitalized }).joined()
    }

    func lowerSnakeCased() -> String {
        return self.words.map({ $0.lowercased() }).joined(separator: "_")
    }

    func upperSnakeCased() -> String {
        return self.words.map({ $0.uppercased() }).joined(separator: "_")
    }

    func mixedSnakeCased() -> String {
        return self.words.joined(separator: "_")
    }

    func lowerKebabCased() -> String {
        return self.words.map({ $0.lowercased() }).joined(separator: "-")
    }

    func upperKebabCased() -> String {
        return self.words.map({ $0.uppercased() }).joined(separator: "-")
    }

    func mixedKebabCased() -> String {
        return self.words.joined(separator: "-")
    }
}
