//
//  String+Random.swift
//
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public extension String {
    enum RandomizationType: String {
        case numbers = "0123456789"
        case letters = "abcdefghijklmnopqrstuvwxyz"
        case lettersUppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        case symbols = "+-.,/:;!$%&()=?´`^#'*><-_"
    }

    /**
     Generates a random string.

     - Parameters:
        - types: An array of `RandomizationType` values specifying the types of characters to be used.
        - length: The length of the generated random string.

     - Returns: A randomly generated string based on the specified randomization types and length.
     */
    static func random(using types: [RandomizationType] = [.letters, .lettersUppercase], length: Int = 8) -> String {
        let letters = types.map(\.rawValue).reduce("", +)
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    /**
       Generates a random string.

       - Parameters:
          - types: An array of `RandomizationType` values specifying the types of characters to be used.
          - length: A range representing the length of the generated random string.

       - Returns: A randomly generated string based on the specified randomization types and a random length within the given range.
       */
    static func random(using types: [RandomizationType] = [.letters, .lettersUppercase], length: Range<Int>) -> String {
        return random(using: Array(types), length: Int.random(in: length))
    }
}

public struct loremIpsum {
    /// Generates a single word.
    public static var word: String {
        return allWords.randomElement()!
    }
    
    /**
     Generates multiple words whose count is defined by the given value.
     
     - Parameter count: The number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ count: Int) -> String {
        return _compose(
            word,
            count: count,
            joinBy: .space
        )
    }
    
    /**
     Generates multiple words whose count is randomly selected from within the given range.
     
     - Parameter range: The range of number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ range: Range<Int>) -> String {
        return _compose(word, count: Int.random(in: range), joinBy: .space)
    }
    
    /**
     Generates multiple words whose count is randomly selected from within the given closed range.
     
     - Parameter range: The range of number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ range: ClosedRange<Int>) -> String {
        return _compose(word, count: Int.random(in: range), joinBy: .space)
    }
    
    /// Generates a single sentence.
    public static var sentence: String {
        let numberOfWords = Int.random(
            in: minWordsCountInSentence...maxWordsCountInSentence
        )
        
        return _compose(
            word,
            count: numberOfWords,
            joinBy: .space,
            endWith: .dot,
            decorate: { $0.uppercasedFirst() }
        )
    }
    
    /**
     Generates multiple sentences whose count is defined by the given value.
     
     - Parameter count: The number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ count: Int) -> String {
        return _compose(
            sentence,
            count: count,
            joinBy: .space
        )
    }

    /**
     Generates multiple sentences whose count is selected from within the given range.
     
     - Parameter count: The number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ range: Range<Int>) -> String {
        return _compose(sentence, count: Int.random(in: range), joinBy: .space)
    }
    
    /**
     Generates multiple sentences whose count is selected from within the given closed range.
     
     - Parameter count: The number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ range: ClosedRange<Int>) -> String {
        return _compose(sentence, count: Int.random(in: range), joinBy: .space)
    }
    
    fileprivate enum Separator: String {
        case none = ""
        case space = " "
        case dot = "."
        case newLine = "\n"
    }
    
    fileprivate static func _compose(
        _ provider: @autoclosure () -> String,
        count: Int,
        joinBy middleSeparator: Separator,
        endWith endSeparator: Separator = .none,
        decorate decorator: ((String) -> String)? = nil
    ) -> String {
        var string = ""
        
        for index in 0..<count {
            string += provider()
            
            if (index < count - 1) {
                string += middleSeparator.rawValue
            } else {
                string += endSeparator.rawValue
            }
        }
        
        if let decorator = decorator {
            string = decorator(string)
        }
        
        return string
    }
    
    fileprivate static let minWordsCountInSentence = 4
    fileprivate static let maxWordsCountInSentence = 16
    fileprivate static let minWordsCountInTitle = 2
    fileprivate static let maxWordsCountInTitle = 7
    
    fileprivate static let allWords = ["alias", "consequatur", "aut", "perferendis", "sit", "voluptatem", "accusantium", "doloremque", "aperiam", "eaque", "ipsa", "quae", "ab", "illo", "inventore", "veritatis", "et", "quasi", "architecto", "beatae", "vitae", "dicta", "sunt", "explicabo", "aspernatur", "aut", "odit", "aut", "fugit", "sed", "quia", "consequuntur", "magni", "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt", "neque", "dolorem", "ipsum", "quia", "dolor", "sit", "amet", "consectetur", "adipisci", "velit", "sed", "quia", "non", "numquam", "eius", "modi", "tempora", "incidunt", "ut", "labore", "et", "dolore", "magnam", "aliquam", "quaerat", "voluptatem", "ut", "enim", "ad", "minima", "veniam", "quis", "nostrum", "exercitationem", "ullam", "corporis", "nemo", "enim", "ipsam", "voluptatem", "quia", "voluptas", "sit", "suscipit", "laboriosam", "nisi", "ut", "aliquid", "ex", "ea", "commodi", "consequatur", "quis", "autem", "vel", "eum", "iure", "reprehenderit", "qui", "in", "ea", "voluptate", "velit", "esse", "quam", "nihil", "molestiae", "et", "iusto", "odio", "dignissimos", "ducimus", "qui", "blanditiis", "praesentium", "laudantium", "totam", "rem", "voluptatum", "deleniti", "atque", "corrupti", "quos", "dolores", "et", "quas", "molestias", "excepturi", "sint", "occaecati", "cupiditate", "non", "provident", "sed", "ut", "perspiciatis", "unde", "omnis", "iste", "natus", "error", "similique", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollitia", "animi", "id", "est", "laborum", "et", "dolorum", "fuga", "et", "harum", "quidem", "rerum", "facilis", "est", "et", "expedita", "distinctio", "nam", "libero", "tempore", "cum", "soluta", "nobis", "est", "eligendi", "optio", "cumque", "nihil", "impedit", "quo", "porro", "quisquam", "est", "qui", "minus", "id", "quod", "maxime", "placeat", "facere", "possimus", "omnis", "voluptas", "assumenda", "est", "omnis", "dolor", "repellendus", "temporibus", "autem", "quibusdam", "et", "aut", "consequatur", "vel", "illum", "qui", "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla", "pariatur", "at", "vero", "eos", "et", "accusamus", "officiis", "debitis", "aut", "rerum", "necessitatibus", "saepe", "eveniet", "ut", "et", "voluptates", "repudiandae", "sint", "et", "molestiae", "non", "recusandae", "itaque", "earum", "rerum", "hic", "tenetur", "a", "sapiente", "delectus", "ut", "aut", "reiciendis", "voluptatibus", "maiores", "doloribus", "asperiores", "repellat"]
}
