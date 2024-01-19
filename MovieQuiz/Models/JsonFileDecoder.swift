import Foundation


final class JsonFileDecoder {
    
    private struct Actor: Codable {
        let id: String
        let image: String
        let name: String
        let asCharacter: String
    }
    
    struct Movie: Codable {
        let id: String
        let rank: String
        let title: String
        let fullTitle: String
        let year: String
        let image: String
        let crew: String
        let imDbRating: String
        let imDbRatingCount: String
        
        enum CodingKeys: CodingKey {
            case id, rank, title, fullTitle, year, image, crew, imDbRating, imDbRatingCount
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(String.self, forKey: .id)
            rank = try container.decode(String.self, forKey: .rank)
            title = try container.decode(String.self, forKey: .title)
            fullTitle = try container.decode(String.self, forKey: .fullTitle)
            year = try container.decode( String.self, forKey: .year)
            image = try container.decode(String.self, forKey: .image)
            crew = try container.decode(String.self, forKey: .crew)
            imDbRating = try container.decode(String.self, forKey: .imDbRating)
            imDbRatingCount = try container.decode(String.self, forKey: .imDbRatingCount)
            
        }
        
    }
    
    struct Top: Decodable {
        let items: [Movie]
    }
    
    
    func string(from documentsURL: URL) throws -> String {
        
        if !FileManager.default.fileExists(atPath: documentsURL.path) {
            
            throw FileManagerError.fileDoesntExist
        }
        
        return try String(contentsOf: documentsURL)
    }
}

enum FileManagerError: Error {
    case fileDoesntExist
}
