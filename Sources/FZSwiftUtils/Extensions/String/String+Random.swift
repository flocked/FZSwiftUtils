//
//  String+Random.swift
//
//  Parts taken from:
//  Copyright (c) 2014-2021 Lukas Kubanek.
//  https://github.com/lukaskubanek/LoremSwiftum
//
//  Created by Florian Zand on 04.05.23.
//

import Foundation

public extension String {

    /// The type of characters to be used when randomizing a string using ``random(using:length:)-9nshh``.
    struct RandomizationType: OptionSet, Codable {
        /// Numbers.
        public static let numbers = RandomizationType(rawValue: 1 << 0)
        /// Lowercase letters.
        public static let letters = RandomizationType(rawValue: 1 << 1)
        /// Uppercase letters.
        public static let lettersUppercase = RandomizationType(rawValue: 1 << 2)
        /// Symbols.
        public static let symbols = RandomizationType(rawValue: 1 << 3)
        /// Lower- and uppercase letters.
        public static var allLetters: RandomizationType = [.letters, .lettersUppercase]
        /// Lower- and uppercase letters, numbers and symbols.
        public static var all: RandomizationType = [.letters, .lettersUppercase, .numbers, .symbols]
        
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        var characters: String {
            var string = ""
            if contains(.numbers) { string += "0123456789" }
            if contains(.letters) { string += "abcdefghijklmnopqrstuvwxyz" }
            if contains(.lettersUppercase) { string += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
            if contains(.symbols) { string += "+-.,/:;!$%&()=?´`^#'*><-_" }
            return string
        }
    }

    /**
     Generates a random string.

     - Parameters:
        - type: The type of characters to be used.
        - length: The length of the generated random string.

     - Returns: A randomly generated string based on the specified randomization types and length.
     */
    static func random(using type: RandomizationType = .allLetters, length: Int = 8) -> String {
        guard !type.isEmpty else { return "" }
        let characters = type.characters
        return String((0 ..< length).map { _ in characters.randomElement()! })
    }

    /**
     Generates a random string.

     - Parameters:
        - type: The type of characters to be used.
        - length: A range representing the length of the generated random string.

     - Returns: A randomly generated string based on the specified randomization types and a random length within the given range.
     */
    static func random(using types: RandomizationType = .allLetters, length: Range<Int>) -> String {
        random(using: types, length: Int.random(in: length))
    }
}

/// A lorem ipsum generator.
public enum loremIpsum {
    
    /// Generates a single word.
    public static var word: String {
        allWords.randomElement()!
    }

    /**
     Generates multiple words whose count is defined by the given value.

     - Parameter count: The number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ count: Int) -> String {
        _compose(word, count: count, joinBy: .space)
    }

    /**
     Generates multiple words whose count is randomly selected from within the given range.

     - Parameter range: The range of number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ range: Range<Int>) -> String {
        _compose(word, count: Int.random(in: range), joinBy: .space)
    }
    
    /**
     Generates multiple words whose count is randomly selected from within the given range.

     - Parameter range: The range of number of words to generate.
     - Returns: The generated words joined by a space character.
     */
    public static func words(_ range: ClosedRange<Int>) -> String {
        _compose(word, count: Int.random(in: range), joinBy: .space)
    }

    /// Generates a single sentence.
    public static var sentence: String {
        _compose(word, count: Int.random(in: wordsCountInSentence), joinBy: .space, endWith: .dot, decorate: { $0.uppercasedFirst() })
    }

    /**
     Generates multiple sentences whose count is defined by the given value.

     - Parameter count: The number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ count: Int) -> String {
        _compose(sentence, count: count, joinBy: .space)
    }

    /**
     Generates multiple sentences whose count is selected from within the given range.

     - Parameter range: The range of number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ range: Range<Int>) -> String {
        _compose(sentence, count: Int.random(in: range), joinBy: .space)
    }
    
    /**
     Generates multiple sentences whose count is selected from within the given range.

     - Parameter range: The range of number of sentences to generate.
     - Returns: The generated sentences joined by a space character.
     */
    public static func sentences(_ range: ClosedRange<Int>) -> String {
        _compose(sentence, count: Int.random(in: range), joinBy: .space)
    }
    
    /// Generates a single paragraph.
    public static var paragraph: String {
        _compose(sentence, count: Int.random(in: sentencesCountInParagraph), joinBy: .space)
    }
    
    
    /**
     Generates multiple paragraphs whose count is defined by the given value.

     - Parameter count: The number of paragraphs to generate.
     - Returns: The generated paragraphs joined by a new line character.
     */
    public static func paragraphs(_ count: Int) -> String {
        _compose(paragraph, count: count, joinBy: .newLine)
    }
    
    /**
     Generates multiple paragraphs whose count is selected from within the given range.
     
     - Parameter count: The range of number of paragraphs to generate.
     - Returns: The generated paragraphs joined by a new line character.
     */
    public static func paragraphs(_ range: Range<Int>) -> String {
        _compose(paragraph, count: Int.random(in: range), joinBy: .newLine)
    }
    
    /**
     Generates multiple paragraphs whose count is selected from within the given range.
     
     - Parameter count: The range of number of paragraphs to generate.
     - Returns: The generated paragraphs joined by a new line character.
     */
    public static func paragraphs(_ range: ClosedRange<Int>) -> String {
        _compose(paragraph, count: Int.random(in: range), joinBy: .newLine)
    }
    
    /// Generates a capitalized title.
    public static var title: String {
        _compose(word, count: Int.random(in: wordsCountInTitle), joinBy: .space, decorate: { $0.capitalized })
     }
    
    /// Generates a first name.
    public static var firstName: String {
        firstNames.randomElement()!
    }
    
    /// Generates a last name.
    public static var lastName: String {
        lastNames.randomElement()!
    }
    
    /// Generates a full name.
    public static var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Generates an email address.
    public static var emailAddress: String {
        "\(firstName)\(emailDelimiters.randomElement()!)\(lastName)@\(emailDomains.randomElement()!)".lowercased()
    }
    
    /// Generates a URL.
    public static var url: String {
        "\(urlSchemes.randomElement()!)://\(urlDomains.randomElement()!)"
    }
    
    /// Generates a random tweet which is shorter than `140` characters.
     public static var shortTweet: String {
        _composeTweet(140)
     }
     
     /// Generates a random tweet which is shorter than `280 characters.
     public static var tweet: String {
        _composeTweet(280)
     }

    fileprivate enum Separator: String {
        case none = ""
        case space = " "
        case dot = "."
        case newLine = "\n"
    }

    fileprivate static func _compose(_ provider: @autoclosure () -> String, count: Int, joinBy middleSeparator: Separator, endWith endSeparator: Separator = .none, decorate decorator: ((String) -> String)? = nil) -> String {
        var string = ""
        for index in 0 ..< count {
            string += provider()
            if index < count - 1 {
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
    
     fileprivate static func _composeTweet(_ maxLength: Int) -> String {
         for numberOfSentences in [4, 3, 2, 1] {
             let tweet = sentences(numberOfSentences)
             if tweet.count < maxLength {
                 return tweet
             }
         }
         return ""
     }
    
    fileprivate static let wordsCountInSentence = 4...16
    fileprivate static let wordsCountInTitle = 2...7
    fileprivate static let sentencesCountInParagraph = 3...9

    fileprivate static let allWords = ["alias", "consequatur", "aut", "perferendis", "sit", "voluptatem", "accusantium", "doloremque", "aperiam", "eaque", "ipsa", "quae", "ab", "illo", "inventore", "veritatis", "et", "quasi", "architecto", "beatae", "vitae", "dicta", "sunt", "explicabo", "aspernatur", "aut", "odit", "aut", "fugit", "sed", "quia", "consequuntur", "magni", "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt", "neque", "dolorem", "ipsum", "quia", "dolor", "sit", "amet", "consectetur", "adipisci", "velit", "sed", "quia", "non", "numquam", "eius", "modi", "tempora", "incidunt", "ut", "labore", "et", "dolore", "magnam", "aliquam", "quaerat", "voluptatem", "ut", "enim", "ad", "minima", "veniam", "quis", "nostrum", "exercitationem", "ullam", "corporis", "nemo", "enim", "ipsam", "voluptatem", "quia", "voluptas", "sit", "suscipit", "laboriosam", "nisi", "ut", "aliquid", "ex", "ea", "commodi", "consequatur", "quis", "autem", "vel", "eum", "iure", "reprehenderit", "qui", "in", "ea", "voluptate", "velit", "esse", "quam", "nihil", "molestiae", "et", "iusto", "odio", "dignissimos", "ducimus", "qui", "blanditiis", "praesentium", "laudantium", "totam", "rem", "voluptatum", "deleniti", "atque", "corrupti", "quos", "dolores", "et", "quas", "molestias", "excepturi", "sint", "occaecati", "cupiditate", "non", "provident", "sed", "ut", "perspiciatis", "unde", "omnis", "iste", "natus", "error", "similique", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollitia", "animi", "id", "est", "laborum", "et", "dolorum", "fuga", "et", "harum", "quidem", "rerum", "facilis", "est", "et", "expedita", "distinctio", "nam", "libero", "tempore", "cum", "soluta", "nobis", "est", "eligendi", "optio", "cumque", "nihil", "impedit", "quo", "porro", "quisquam", "est", "qui", "minus", "id", "quod", "maxime", "placeat", "facere", "possimus", "omnis", "voluptas", "assumenda", "est", "omnis", "dolor", "repellendus", "temporibus", "autem", "quibusdam", "et", "aut", "consequatur", "vel", "illum", "qui", "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla", "pariatur", "at", "vero", "eos", "et", "accusamus", "officiis", "debitis", "aut", "rerum", "necessitatibus", "saepe", "eveniet", "ut", "et", "voluptates", "repudiandae", "sint", "et", "molestiae", "non", "recusandae", "itaque", "earum", "rerum", "hic", "tenetur", "a", "sapiente", "delectus", "ut", "aut", "reiciendis", "voluptatibus", "maiores", "doloribus", "asperiores", "repellat"]
    
    fileprivate static let firstNames = ["Judith", "Angelo", "Margarita", "Kerry", "Elaine", "Lorenzo", "Justice", "Doris", "Raul", "Liliana", "Kerry", "Elise", "Ciaran", "Johnny", "Moses", "Davion", "Penny", "Mohammed", "Harvey", "Sheryl", "Hudson", "Brendan", "Brooklynn", "Denis", "Sadie", "Trisha", "Jacquelyn", "Virgil", "Cindy", "Alexa", "Marianne", "Giselle", "Casey", "Alondra", "Angela", "Katherine", "Skyler", "Kyleigh", "Carly", "Abel", "Adrianna", "Luis", "Dominick", "Eoin", "Noel", "Ciara", "Roberto", "Skylar", "Brock", "Earl", "Dwayne", "Jackie", "Hamish", "Sienna", "Nolan", "Daren", "Jean", "Shirley", "Connor", "Geraldine", "Niall", "Kristi", "Monty", "Yvonne", "Tammie", "Zachariah", "Fatima", "Ruby", "Nadia", "Anahi", "Calum", "Peggy", "Alfredo", "Marybeth", "Bonnie", "Gordon", "Cara", "John", "Staci", "Samuel", "Carmen", "Rylee", "Yehudi", "Colm", "Beth", "Dulce", "Darius", "inley", "Javon", "Jason", "Perla", "Wayne", "Laila", "Kaleigh", "Maggie", "Don", "Quinn", "Collin", "Aniya", "Zoe", "Isabel", "Clint", "Leland", "Esmeralda", "Emma", "Madeline", "Byron", "Courtney", "Vanessa", "Terry", "Antoinette", "George", "Constance", "Preston", "Rolando", "Caleb", "Kenneth", "Lynette", "Carley", "Francesca", "Johnnie", "Jordyn", "Arturo", "Camila", "Skye", "Guy", "Ana", "Kaylin", "Nia", "Colton", "Bart", "Brendon", "Alvin", "Daryl", "Dirk", "Mya", "Pete", "Joann", "Uriel", "Alonzo", "Agnes", "Chris", "Alyson", "Paola", "Dora", "Elias", "Allen", "Jackie", "Eric", "Bonita", "Kelvin", "Emiliano", "Ashton", "Kyra", "Kailey", "Sonja", "Alberto", "Ty", "Summer", "Brayden", "Lori", "Kelly", "Tomas", "Joey", "Billie", "Katie", "Stephanie", "Danielle", "Alexis", "Jamal", "Kieran", "Lucinda", "Eliza", "Allyson", "Melinda", "Alma", "Piper", "Deana", "Harriet", "Bryce", "Eli", "Jadyn", "Rogelio", "Orlaith", "Janet", "Randal", "Toby", "Carla", "Lorie", "Caitlyn", "Annika", "Isabelle", "inn", "Ewan", "Maisie", "Michelle", "Grady", "Ida", "Reid", "Emely", "Tricia", "Beau", "Reese", "Vance", "Dalton", "Lexi", "Rafael", "Makenzie", "Mitzi", "Clinton", "Xena", "Angelina", "Kendrick", "Leslie", "Teddy", "Jerald", "Noelle", "Neil", "Marsha", "Gayle", "Omar", "Abigail", "Alexandra", "Phil", "Andre", "Billy", "Brenden", "Bianca", "Jared", "Gretchen", "Patrick", "Antonio", "Josephine", "Kyla", "Manuel", "Freya", "Kellie", "Tonia", "Jamie", "Sydney", "Andres", "Ruben", "Harrison", "Hector", "Clyde", "Wendell", "Kaden", "Ian", "Tracy", "Cathleen", "Shawn"]
    
    fileprivate static let lastNames = ["Chung", "Chen", "Melton", "Hill", "Puckett", "Song", "Hamilton", "Bender", "Wagner", "McLaughlin", "McNamara", "Raynor", "Moon", "Woodard", "Desai", "Wallace", "Lawrence", "Griffin", "Dougherty", "Powers", "May", "Steele", "Teague", "Vick", "Gallagher", "Solomon", "Walsh", "Monroe", "Connolly", "Hawkins", "Middleton", "Goldstein", "Watts", "Johnston", "Weeks", "Wilkerson", "Barton", "Walton", "Hall", "Ross", "Chung", "Bender", "Woods", "Mangum", "Joseph", "Rosenthal", "Bowden", "Barton", "Underwood", "Jones", "Baker", "Merritt", "Cross", "Cooper", "Holmes", "Sharpe", "Morgan", "Hoyle", "Allen", "Rich", "Rich", "Grant", "Proctor", "Diaz", "Graham", "Watkins", "Hinton", "Marsh", "Hewitt", "Branch", "Walton", "O'Brien", "Case", "Watts", "Christensen", "Parks", "Hardin", "Lucas", "Eason", "Davidson", "Whitehead", "Rose", "Sparks", "Moore", "Pearson", "Rodgers", "Graves", "Scarborough", "Sutton", "Sinclair", "Bowman", "Olsen", "Love", "McLean", "Christian", "Lamb", "James", "Chandler", "Stout", "Cowan", "Golden", "Bowling", "Beasley", "Clapp", "Abrams", "Tilley", "Morse", "Boykin", "Sumner", "Cassidy", "Davidson", "Heath", "Blanchard", "McAllister", "McKenzie", "Byrne", "Schroeder", "Griffin", "Gross", "Perkins", "Robertson", "Palmer", "Brady", "Rowe", "Zhang", "Hodge", "Li", "Bowling", "Justice", "Glass", "Willis", "Hester", "Floyd", "Graves", "Fischer", "Norman", "Chan", "Hunt", "Byrd", "Lane", "Kaplan", "Heller", "May", "Jennings", "Hanna", "Locklear", "Holloway", "Jones", "Glover", "Vick", "O'Donnell", "Goldman", "McKenna", "Starr", "Stone", "McClure", "Watson", "Monroe", "Abbott", "Singer", "Hall", "Farrell", "Lucas", "Norman", "Atkins", "Monroe", "Robertson", "Sykes", "Reid", "Chandler", "Finch", "Hobbs", "Adkins", "Kinney", "Whitaker", "Alexander", "Conner", "Waters", "Becker", "Rollins", "Love", "Adkins", "Black", "Fox", "Hatcher", "Wu", "Lloyd", "Joyce", "Welch", "Matthews", "Chappell", "MacDonald", "Kane", "Butler", "Pickett", "Bowman", "Barton", "Kennedy", "Branch", "Thornton", "McNeill", "Weinstein", "Middleton", "Moss", "Lucas", "Rich", "Carlton", "Brady", "Schultz", "Nichols", "Harvey", "Stevenson", "Houston", "Dunn", "West", "O'Brien", "Barr", "Snyder", "Cain", "Heath", "Boswell", "Olsen", "Pittman", "Weiner", "Petersen", "Davis", "Coleman", "Terrell", "Norman", "Burch", "Weiner", "Parrott", "Henry", "Gray", "Chang", "McLean", "Eason", "Weeks", "Siegel", "Puckett", "Heath", "Hoyle", "Garrett", "Neal", "Baker", "Goldman", "Shaffer", "Choi", "Carver"]
    
    fileprivate static let emailDomains = ["icloud.com", "gmail.com", "yahoo.com", "hotmail.com", "email.com", "live.com", "mac.com", "aol.com", "fastmail.com", "mail.com"]
    
    fileprivate static let emailDelimiters = ["", ".", "-", "_"]
    
    fileprivate static let urlSchemes = ["http", "https"]
    
    fileprivate static let urlDomains = ["twitter.com", "google.com", "youtube.com", "wordpress.org", "adobe.com", "blogspot.com", "godaddy.com", "wikipedia.org", "wordpress.com", "yahoo.com", "linkedin.com", "amazon.com", "flickr.com", "w3.org", "apple.com", "myspace.com", "tumblr.com", "digg.com", "microsoft.com", "vimeo.com", "pinterest.com", "stumbleupon.com", "youtu.be", "miibeian.gov.cn", "baidu.com", "feedburner.com", "bit.ly"]
}
