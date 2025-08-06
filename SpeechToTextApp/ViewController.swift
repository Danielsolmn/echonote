//
//  ViewController.swift
//  SpeechToTextApp
//
//  Created by Daniel Woldetsadik on 7/31/25.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var transcriptionTextView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    
    private var generatedFlashcards: [Flashcard] = []
       private var loadingAlert: UIAlertController?
   
    
    @IBAction func generateFlashcardsTapped(_ sender: Any) {
        let transcript = transcriptionTextView.text ?? ""
        if transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || transcript == "Speech will appear here..." {
                   // Show alert if no transcript
                   let alert = UIAlertController(title: "No Transcript", message: "Please record some speech first before generating flashcards.", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default))
                   present(alert, animated: true)
                   return
               }
               
               // Show loading indicator
               let alert = UIAlertController(title: "Generating Flashcards", message: "Please wait...", preferredStyle: .alert)
               loadingAlert = alert
               present(alert, animated: true)
               
               generateFlashcards(from: transcript)
    }
    
    
    @IBAction func startTapped(_ sender: Any) {
        if audioEngine.isRunning {
                    stopTranscribing()
                    startButton.setTitle("Start", for: .normal)
                } else {
                    startTranscribing()
                    startButton.setTitle("Stop", for: .normal)
                }
    }
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier:  "en-US"))
        private let audioEngine = AVAudioEngine()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        transcriptionTextView.text = "Speech will appear here..."
                startButton.isEnabled = false
                requestSpeechAuth()
    }
    
    private func requestSpeechAuth() {
            SFSpeechRecognizer.requestAuthorization { status in
                DispatchQueue.main.async {
                    self.startButton.isEnabled = (status == .authorized)
                    if status != .authorized {
                        self.transcriptionTextView.text = "Speech recognition not authorized."
                    }
                }
            }
        }
    
    private func startTranscribing() {
            resetTranscription()

            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let inputNode = audioEngine.inputNode as AVAudioInputNode?,
                  let recognitionRequest = recognitionRequest else { return }

            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.transcriptionTextView.text = result.bestTranscription.formattedString
                }

                if error != nil || result?.isFinal == true {
                    self.stopTranscribing()
                    self.startButton.setTitle("Start", for: .normal)
                }
            }

            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try? audioEngine.start()

            transcriptionTextView.text = "Listening..."
        }

        private func stopTranscribing() {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        private func resetTranscription() {
            if recognitionTask != nil {
                recognitionTask?.cancel()
                recognitionTask = nil
            }

            if audioEngine.isRunning {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }

            recognitionRequest = nil
        }

//.................................................................
   
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
  //      ..............................................................................................
        func generateFlashcards(from text: String) {
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                         print("Error: No text to generate flashcards from")
                         return
                     }
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

            let prompt = "Generate 20-5 flashcards in Q&A format from this text. Format each as 'Q: [question]' followed by 'A: [answer]' on the next line:\n\n\(text)"

            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a helpful assistant that creates flashcards for students."],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 500
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                                    print("Network error: \(error.localizedDescription)")
                                    DispatchQueue.main.async {
                                        self.loadingAlert?.dismiss(animated: true)
                                        let errorAlert = UIAlertController(title: "Network Error", message: "Failed to connect to the server. Please check your internet connection.", preferredStyle: .alert)
                                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                        self.present(errorAlert, animated: true)
                                    }
                                    return
                                }
                                
                                if let httpResponse = response as? HTTPURLResponse {
                                    print("HTTP Status: \(httpResponse.statusCode)")
                                }
                                
                                if let data = data {
                                    print("Received data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
                                    
                                    if let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
                                       let reply = result.choices.first?.message.content {
                                        print("OpenAI Reply:\n\(reply)")
                                        let cards = parseFlashcards(from: reply)
                                        print("Parsed \(cards.count) flashcards")
                                        
                                        DispatchQueue.main.async {
                                            self.generatedFlashcards = cards
                                            self.performSegue(withIdentifier: "ShowFlashcardsSegue", sender: self)
                                            self.loadingAlert?.dismiss(animated: true)
                                        }
                                    } else {
                                        print("Failed to decode OpenAI response")
                                        DispatchQueue.main.async {
                                            self.loadingAlert?.dismiss(animated: true)
                                            let errorAlert = UIAlertController(title: "Error", message: "Failed to generate flashcards. Please try again.", preferredStyle: .alert)
                                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                            self.present(errorAlert, animated: true)
                                        }
                                    }
                                } else {
                                    print("No data received")
                                    DispatchQueue.main.async {
                                        self.loadingAlert?.dismiss(animated: true)
                                        let errorAlert = UIAlertController(title: "Error", message: "No response received. Please check your internet connection.", preferredStyle: .alert)
                                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                        self.present(errorAlert, animated: true)
                                    }
                                }
                            }.resume()
                        }


       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ShowFlashcardsSegue",
              let flashcardVC = segue.destination as? FlashcardViewController {
               flashcardVC.flashcards = generatedFlashcards
           }
       }

   }

