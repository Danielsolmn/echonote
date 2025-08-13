//
//  storage.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/4/25.
//

import Foundation
enum TranscriptionType: String, Codable {
    case voice = "voice"
    case scan = "scan" 
    case translation = "translation"
}
struct Transcription: Codable {
    let id: UUID      // unique identifier
    let originalText: String 
    var text: String  // what was said
    let date: Date    // when it was recorded
    var edits: [EditVersion] = []  // list of edits
    var type: TranscriptionType = .voice  // type of transcription
  
}

struct hello {
    static let openAIKey = "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"
}



struct EditVersion: Codable {
    let text: String
        let timestamp: Date
}




struct SummaryEntry: Codable {
    let originalText: String
    let summaryText: String
    let summaryType: String
    let timestamp: String
}



class TranscriptionStorage {
        private static let key = "transcriptions"
    static func saveTranscriptions(_ items: [Transcription]) {
        let defaults = UserDefaults.standard
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: key)
        }
    }
    
    static func loadTranscriptions() -> [Transcription] {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key) {
         let decodedMovies = try! JSONDecoder().decode([Transcription].self, from: data)
        return decodedMovies
        } else {
            return []
        }
    }
    static func add(_ newItem: Transcription) {
        var currentItems = loadTranscriptions()
        currentItems.insert(newItem, at: 0) // most recent first
        saveTranscriptions(currentItems)
    }
    static func addEdit(to id: UUID, editedText: String) {
        var items = loadTranscriptions()

        // Find the transcription by its ID
        if let index = items.firstIndex(where: { $0.id == id }) {
            let newEdit = EditVersion(
                text: editedText,
                timestamp: Date()
            )
            items[index].edits.insert(newEdit, at: 0) // insert most recent first
            saveTranscriptions(items)
        }
    }

        // Helper to get current date/time as a string
        private static func getCurrentTimestamp() -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd h:mm a"
            return formatter.string(from: Date())
        }
    
    static func update(_ updatedItem: Transcription) {
        var items = loadTranscriptions()
        
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveTranscriptions(items)
        }
    }
}
