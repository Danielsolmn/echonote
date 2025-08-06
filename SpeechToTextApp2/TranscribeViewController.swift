//
//  TranscribeViewController.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/4/25.
//

import UIKit
import Speech
import AVFoundation

class TranscribeViewController: UIViewController {

    @IBOutlet weak var transcriptionTextView: UITextView!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    // Add this property to track pause state
    var isPaused = false

    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        if isPaused {
            // Resume recording
            resumeRecording()
            isPaused = false
            
            // Change button back to normal color
            pauseButton.backgroundColor = UIColor.systemBlue
            pauseButton.tintColor = UIColor.white
        } else {
            // Pause recording
            pauseRecording()
            isPaused = true
            
            // Change button color to show paused state
            pauseButton.backgroundColor = UIColor.systemRed
            pauseButton.tintColor = UIColor.white
        }
    }
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopTranscribing()
        let transcriptText = transcriptionTextView.text ?? ""
         
        let newItem = Transcription(id: UUID(), originalText: transcriptText, text: transcriptText, date: Date(), edits: [], type: .voice)
        
var savedItems = TranscriptionStorage.loadTranscriptions()
        savedItems.insert(newItem, at: 0) // most recent at the top
        TranscriptionStorage.saveTranscriptions(savedItems)

           transcriptionTextView.text += "\n\n🛑 Saved & returning..."
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
               self.tabBarController?.selectedIndex = 0 // Go back to first tab
           }
        
    }
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transcriptionTextView.text = "Preparing..."
                stopButton.isHidden = true
                requestSpeechAuth()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SFSpeechRecognizer.authorizationStatus() == .authorized && !audioEngine.isRunning {
            startTranscribing()
            stopButton.isHidden = false
        }
    }
    
    private func requestSpeechAuth() {
           SFSpeechRecognizer.requestAuthorization { status in
               DispatchQueue.main.async {
                   if status != .authorized {
                       self.transcriptionTextView.text = "Speech recognition not authorized."
                       self.stopButton.isHidden = true
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
                 let recognitionRequest = recognitionRequest else {
               transcriptionTextView.text = "Failed to set up audio input."
               return
           }

           recognitionRequest.shouldReportPartialResults = true

           recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
               if let result = result {
                   self.transcriptionTextView.text = result.bestTranscription.formattedString
               }

               if error != nil || result?.isFinal == true {
                   self.stopTranscribing()
               }
           }

           let format = inputNode.outputFormat(forBus: 0)
           inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
               self.recognitionRequest?.append(buffer)
           }

           audioEngine.prepare()
           try? audioEngine.start()

           transcriptionTextView.text = "Listening..."
           
           // Reset pause state and enable pause button
           isPaused = false
           pauseButton.isEnabled = true
       }

       private func stopTranscribing() {
           audioEngine.stop()
           audioEngine.inputNode.removeTap(onBus: 0)
           recognitionRequest?.endAudio()
           recognitionTask?.cancel()
           recognitionTask = nil

           stopButton.isHidden = true
           pauseButton.isEnabled = false
           isPaused = false
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

    // Add these methods for pause/resume functionality
    func pauseRecording() {
        audioEngine.pause()
    }

    func resumeRecording() {
        do {
            try audioEngine.start()
        } catch {
            print("Error resuming recording: \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
