//
//  File.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/5/25.
//

import Foundation


class OpenAIService {
    
    static let shared = OpenAIService()
    private init() {}
    
    func callOpenAI(for text: String,
                    mode: String,
                    targetLanguage: String? = nil,
                    completion: @escaping (String?) -> Void) {
        
        var prompt = ""
        
        switch mode.lowercased() {
        case "summary":
            prompt = "Summarize the following text:\n\n\(text)"
        case "translation":
            let language = targetLanguage ?? "English"
            prompt = "Translate the following text to \(language):\n\n\(text)"
        default:
            prompt = text
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(hello.openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(" Request failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
           
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    completion(content)
                } else {
                    print("Invalid response format.")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
