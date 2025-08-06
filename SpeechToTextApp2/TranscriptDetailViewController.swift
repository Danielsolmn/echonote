//
//  TranscriptDetailViewController:.swift
//  SpeechToTextApp2
//
//  Created by Daniel Woldetsadik on 8/4/25.
//

import UIKit

class TranscriptDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var summarizeButton: UIButton!
    
   
    
    @IBAction func summarizeTapped(_ sender: UIButton) {
        // 1) Disable the button & give immediate feedback
            sender.isEnabled = false
            sender.setTitle("Loading…", for: .normal)

            let input = textView.text ?? ""
            OpenAIService.shared.callOpenAI(for: input, mode: "summary") { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    sender.isEnabled = true
                    sender.setTitle("Summarize", for: .normal)

                    if let summary = result {
                        self.generatedSummary = summary
                        self.performSegue(withIdentifier: "showSummary", sender: self)
                    } else {
                        // simple error alert
                        let err = UIAlertController(
                          title: "Error",
                          message: "Could not generate summary.",
                          preferredStyle: .alert
                        )
                        err.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(err, animated: true)
                    }
                }
            }
    }
    
    @IBOutlet weak var saveEditButton: UIButton!
    
    
    @IBOutlet weak var editsTableView: UITableView!
    
    
    @IBAction func saveEditTapped(_ sender: Any) {
        guard var transcription = transcription else { return }

            // Move current top to edits
            let oldVersion = EditVersion(text: textView.text, timestamp: Date())
            edits.insert(oldVersion, at: 0)

            // Clear textView for new input (optional)
            textView.text = ""

            // Update storage
            transcription.edits = edits
            TranscriptionStorage.update(transcription)
       editsTableView.reloadData()
        }
        
    
    
     
    let apiKey = Secrets.openAIKey
    var transcription: Transcription?
    var edits: [EditVersion] = []
    var generatedSummary: String?
    var selectedEdit: EditVersion?

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🧪 Transcription passed: \(transcription?.text ?? "nil")")
        textView.text = transcription?.text ?? ""
       
        
        edits = transcription?.edits ?? []
        print("🔍 Loaded \(edits.count) edits")
        
        editsTableView.delegate = self
        editsTableView.dataSource = self
        editsTableView.reloadData()
        
        print("🔍 Table view setup complete")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
      
        }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Don't handle touches on the table view
        let location = touch.location(in: view)
        if editsTableView.frame.contains(location) {
            return false
        }
        return true
    }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return edits.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EditCell")
            let edit = edits[indexPath.row]
            
            cell.textLabel?.text = edit.text.components(separatedBy: "\n").first ?? "Edit"
            let formatted = DateFormatter.localizedString(from: edit.timestamp, dateStyle: .short, timeStyle: .short)
            cell.detailTextLabel?.text = formatted
            
            print("🔍 Configuring cell for row \(indexPath.row): \(edit.text.components(separatedBy: "\n").first ?? "Edit")")

            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            print("🔍 Table view tapped at row: \(indexPath.row)")
            print("🔍 Total edits count: \(edits.count)")
            
            // Check if we have edits to work with
            guard indexPath.row < edits.count else {
                print("❌ Index out of bounds: \(indexPath.row) >= \(edits.count)")
                return
            }
            
            // Get selected edit
            let selectedEdit = edits[indexPath.row]
            print("🔍 Selected edit text: \(selectedEdit.text)")
            
            // Get current text from text view
            let currentText = textView.text ?? ""
            print("🔍 Current text view text: \(currentText)")
            
            // Only save current text as a new edit if it's non-empty and different from the selected edit
            if !currentText.isEmpty && currentText != selectedEdit.text {
                let oldVersion = EditVersion(text: currentText, timestamp: Date())
                edits.insert(oldVersion, at: 0)
                print("🔍 Saved current text as new edit")
            }
            
            // Replace the text view content with the selected edit
            textView.text = selectedEdit.text
            print("✅ New top text: \(textView.text ?? "nil")")
            
            // Update transcription text to reflect new top
            transcription?.text = selectedEdit.text
            transcription?.edits = edits
            
            // Save changes
            if let updated = transcription {
                TranscriptionStorage.update(updated)
                print("🔍 Saved transcription update")
            }
            
            // Deselect the row to provide visual feedback
            tableView.deselectRow(at: indexPath, animated: true)
            
            editsTableView.reloadData()
            
            print("Tapped edit at row \(indexPath.row)")
            print("Selected edit text: \(selectedEdit.text)")
            print("Current top text: \(currentText)")
        }

override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard var transcription = transcription else { return }
        transcription = Transcription(
            id: transcription.id,
            originalText: transcription.originalText,
            text: textView.text,
            date: Date(),
            edits: transcription.edits // ← just reuse existing edits
        )

        var allItems = TranscriptionStorage.loadTranscriptions()

        // Replace the matching item by ID
        if let index = allItems.firstIndex(where: { $0.id == transcription.id }) {
            allItems[index] = transcription
            TranscriptionStorage.saveTranscriptions(allItems)
        }
    }
    
    let summaryModes = ["bullet", "action", "tldr", "tweet"]
    var selectedMode = "bullet"
    
    @IBAction func summaryModeChanged(_ sender: UISegmentedControl) {
        selectedMode = summaryModes[sender.selectedSegmentIndex]
    }
    
    func promptForMode(_ mode: String, transcript: String) -> String {
        switch mode {
        case "bullet":
            return "Summarize the following into bullet points:\n\n\(transcript)"
        case "action":
            return "List key action items from this content:\n\n\(transcript)"
        case "tldr":
            return "Provide a one-sentence TL;DR summary of this text:\n\n\(transcript)"
        case "tweet":
            return "Summarize this into a tweet under 280 characters:\n\n\(transcript)"
        default:
            return "Summarize this:\n\n\(transcript)"
        }
    }
    
    
    
    
    // MARK: - Prepare for Segue
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showSummary",
               let summaryVC = segue.destination as? SummaryViewController {
                summaryVC.summaryText = generatedSummary
            }
        }
    
}
