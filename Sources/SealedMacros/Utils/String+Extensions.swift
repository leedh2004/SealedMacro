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

    private func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }

    func lowerSnakeCased() -> String {
        return self.snakeCased().lowercased()
    }

    func upperSnakeCased() -> String {
        return self.snakeCased().uppercased()
    }

    func mixedSnakeCased() -> String {
        return self.snakeCased()
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
