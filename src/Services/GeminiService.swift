import Foundation
import GoogleGenerativeAI
import UIKit

struct GeminiService {
    private let model: GenerativeModel
    
    init(apiKey: String) {
        self.model = GenerativeModel(
            name: "gemini-2.5-flash",
            apiKey: apiKey,
            generationConfig: GenerationConfig(responseMIMEType: "application/json")
        )
    }
    
    func parseReceipt(image: UIImage) async throws -> ReceiptResult {
        let prompt = """
        Analyze this receipt image. Extract all line items with their name, price, and quantity. 
        If quantity is not explicitly stated, infer it or default to 1. 
        Do NOT include tax, service charge, or total lines in the 'items' array. 
        Instead, extract the total absolute value of all Taxes (sum of CGST, SGST, VAT, etc.) into 'totalTax', 
        and any Service Charge into 'totalServiceCharge'. If not present, set them to 0.
        Also, extract the restaurant or store name into 'restaurantName'.
        
        IMPORTANT: Return ONLY raw JSON in this exact format. Do not include any explanations or markdown formatting.
        {
            "restaurantName": "string",
            "items": [{"name": "string", "price": number, "quantity": number}],
            "totalTax": number,
            "totalServiceCharge": number
        }
        """
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw GeminiError.invalidImage
        }
        
        let content = ModelContent(
            role: "user",
            parts: [
                .text(prompt),
                .data(mimetype: "image/jpeg", imageData)
            ]
        )
        let response: GenerateContentResponse
        do {
            response = try await model.generateContent([content])
        } catch {
            print("FULL GEMINI ERROR: \(error)")
            throw error
        }
        
        guard var text = response.text else {
            throw GeminiError.parsingError("Response text is empty")
        }
        print("RAW GEMINI RESPONSE: \(text)")
        
        // Clean markdown JSON formatting if present
        if text.hasPrefix("```") {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let lines = text.components(separatedBy: .newlines)
            if lines.count > 2 {
                text = lines.dropFirst().dropLast().joined(separator: "\n")
            }
        }
        
        guard let data = text.data(using: .utf8) else {
            throw GeminiError.parsingError("Failed to convert text to data")
        }
        
        do {
            return try JSONDecoder().decode(ReceiptResult.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw GeminiError.parsingError("JSON decoding failed: \(error.localizedDescription)")
        }
    }
}

struct ReceiptResult: Codable {
    let restaurantName: String?
    let items: [RawItem]
    let totalTax: Double
    let totalServiceCharge: Double
}

struct RawItem: Codable {
    let name: String
    let price: Double
    let quantity: Int
}

enum GeminiError: Error {
    case invalidImage
    case parsingError(String)
}

extension GeminiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image data is invalid."
        case .parsingError(let message):
            return "Failed to parse receipt: \(message)"
        }
    }
}
