//
//  ScanTextViewController.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/5/25.
//

import UIKit

import Vision

class ScanTextViewController: UIViewController, UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate , UIPickerViewDelegate, UIPickerViewDataSource {

    // Add property to track camera state
    var isCameraOpen = false

    @IBOutlet weak var textView: UITextView!  
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var languagePicker: UIPickerView!
    
    @IBAction func translateTapped(_ sender: UIButton) {
        let inputText = textView.text ?? ""
        let languageName = selectedLanguage.displayName // "Spanish", "French", etc.
        
        // Show loading alert
        let loadingAlert = UIAlertController(title: "Translating...", message: "Please wait while we translate your text.", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        OpenAIService.shared.callOpenAI(for: inputText, mode: "translation", targetLanguage: languageName) { result in
            DispatchQueue.main.async {
                // Dismiss loading alert
                loadingAlert.dismiss(animated: true) {
                    self.textView.text = result ?? "No translation generated." 
                }
            }
        }
    }
    
    
    var selectedLanguage: Language = .english // Default
    
    // Add rescan method
    @IBAction func rescanTapped(_ sender: UIButton) {
        // Dismiss any existing camera session
        if isCameraOpen {
            dismiss(animated: true) {
                self.openCamera()
            }
        } else {
            openCamera()
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Language.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Language.allCases[row].displayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = Language.allCases[row]
    }
    
    
    
    
    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case arabic = "ar"
        case chinese = "zh"
        case hindi = "hi"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .spanish: return "Spanish"
            case .french: return "French"
            case .german: return "German"
            case .arabic: return "Arabic"
            case .chinese: return "Chinese"
            case .hindi: return "Hindi"
            }
        }
    }
    
    
    
    @IBAction func saveTranslatedTapped(_ sender: UIButton) {
        guard let newText = textView.text, !newText.isEmpty else { return }

        
            let newTranscription = Transcription(
                id: UUID(),
                originalText: newText,
                text: newText,
                date: Date(),
                edits: [],
                type: .scan
            )

            var all = TranscriptionStorage.loadTranscriptions()
            all.insert(newTranscription, at: 0)
            TranscriptionStorage.saveTranscriptions(all)

            // Optional: show alert or pop back to home
            let alert = UIAlertController(title: "Saved", message: "Translation saved to home.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
        
        languagePicker.delegate = self
        languagePicker.dataSource = self
        
           textView.isEditable = false
           textView.isSelectable = true
           textView.isUserInteractionEnabled = true
        

           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleWordTap(_:)))
           textView.addGestureRecognizer(tapGesture)
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func handleWordTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: textView)
        
        // Get the closest position to the tap
        guard let position = textView.closestPosition(to: location),
              let range = textView.tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: UITextDirection.layout(.left)) else {
            return
        }

        // Get the word that was tapped
        let tappedWord = textView.text(in: range) ?? ""

        // Show the definition if it exists
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: tappedWord) {
            let dictVC = UIReferenceLibraryViewController(term: tappedWord)
            present(dictVC, animated: true)
        } else {
            print("❌ No definition found for: \(tappedWord)")
        }
        textView.selectedTextRange = nil
    }



    
    
    
    
    
    
    
    
    
    
    func openCamera() {
       
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        isCameraOpen = true
        present(picker, animated: true)
    }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            isCameraOpen = false
            picker.dismiss(animated: true)

            if let image = info[.originalImage] as? UIImage {
                recognizeText(from: image)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isCameraOpen = false
            picker.dismiss(animated: true)
        }

        func recognizeText(from image: UIImage) {
            guard let cgImage = image.cgImage else { return }

            let request = VNRecognizeTextRequest { request, error in
                guard let results = request.results as? [VNRecognizedTextObservation] else { return }
                let text = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")

                DispatchQueue.main.async {
                    self.textView.text = text
                    self.wordCountLabel.text = "Words: \(text.split(separator: " ").count)"
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    

}
