//
//  Secrets.swift
//  SpeechToTextApp
//
//  Created by Daniel Woldetsadik on 8/1/25.
//

import Foundation
struct Secrets {
    static let openAIKey = "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" 
}
struct OpenAIResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String
    }
}
struct Flashcard {
  let question: String
  let answer: String
}

func parseFlashcards(from response: String) -> [Flashcard] {
    // Split on blank lines to get each Q&A pair
    let pairs = response.components(separatedBy: "\n\n")
    var cards = [Flashcard]()

    for raw in pairs {
        let lines = raw.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                guard lines.count >= 2 else { continue }
        // Remove the "Q: " and "A: " prefixes
        var question = ""
               var answer = ""
               
               for line in lines {
                   let trimmed = line.trimmingCharacters(in: .whitespaces)
                   if trimmed.lowercased().hasPrefix("q:") || trimmed.lowercased().hasPrefix("question:") {
                       question = trimmed.replacingOccurrences(of: "Q:", with: "")
                           .replacingOccurrences(of: "q:", with: "")
                           .replacingOccurrences(of: "Question:", with: "")
                           .replacingOccurrences(of: "question:", with: "")
                           .trimmingCharacters(in: .whitespaces)
                   } else if trimmed.lowercased().hasPrefix("a:") || trimmed.lowercased().hasPrefix("answer:") {
                       answer = trimmed.replacingOccurrences(of: "A:", with: "")
                           .replacingOccurrences(of: "a:", with: "")
                           .replacingOccurrences(of: "Answer:", with: "")
                           .replacingOccurrences(of: "answer:", with: "")
                           .trimmingCharacters(in: .whitespaces)
                   }
               }
               
               if !question.isEmpty && !answer.isEmpty {
                   cards.append(Flashcard(question: question, answer: answer))
               }
           }
           
           if cards.isEmpty {
               let lines = response.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
               var currentQuestion = ""
               var currentAnswer = ""
               
               for line in lines {
                   let trimmed = line.trimmingCharacters(in: .whitespaces)
                   if trimmed.range(of: "^\\d+\\.", options: .regularExpression) != nil {
                       // This is a numbered item, treat as question
                       if !currentQuestion.isEmpty && !currentAnswer.isEmpty {
                           cards.append(Flashcard(question: currentQuestion, answer: currentAnswer))
                       }
                       currentQuestion = trimmed.replacingOccurrences(of: "^\\d+\\.", with: "", options: .regularExpression).trimmingCharacters(in: .whitespaces)
                       currentAnswer = ""
                   } else if !currentQuestion.isEmpty {
                       // This is part of the answer
                       if !currentAnswer.isEmpty {
                           currentAnswer += " "
                       }
                       currentAnswer += trimmed
                   }
               }
               
               // Add the last card
               if !currentQuestion.isEmpty && !currentAnswer.isEmpty {
                   cards.append(Flashcard(question: currentQuestion, answer: currentAnswer))
               }
           }
           
           return cards
       }
