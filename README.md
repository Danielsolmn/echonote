# **EchoNote**

---

## **Overview**

### **Description**

**EchoNote** is an **AI-powered productivity app** that transforms spoken words into organized, editable, and actionable notes. Users can **record speech**, instantly **transcribe it to text**, **edit** the transcription, **summarize** it with **AI**, **translate** it into different languages, **scan text** using their **camera**, or **tap on individual words** to instantly see their meanings and definitions. All **notes and edits** are stored for easy access, search, and sharing, making it perfect for **students, professionals**, and **anyone** who needs clear and concise records of conversations, lectures, or meetings.

---

## **Product Spec**

### **1. User Stories**

**Required Must-have Stories**

- **User can record audio** and see **live transcription**.  
- **User can edit** and **save** the transcription to a **list of notes**.  
- **User can tap a note** to open a **detailed view**.  
- **User can generate AI summaries** of a note.  
- **User can scan text** using the **camera** and save it.  
- **User can translate notes** into another language.  
- **User can tap a word** in any note to see its **meaning/definition** in a popup or bottom sheet.  
- **All saved notes** appear in the home screen’s **table view**.  

**Optional Nice-to-have Stories**

- **Cloud sync** for cross-device note access.  
- **Collaborative note editing/sharing**.  
- **Tagging** and **categorizing notes**.  
- **Voice commands** to control recording or summarization.  
- **Offline dictionary** for word lookups.  

---

### **2. Screen Archetypes**

**Home Screen (List View)**  
- Shows **original saved notes** in a list.  
- Tap a note to open **details**.  
- Access **Record** and **Scan** buttons from tab bar.  

**Record Screen**  
- User starts/stops **audio recording**.  
- **Live transcription** appears as they speak.  
- Option to **save transcription** to notes.  

**Note Detail Screen**  
- Shows **full note text** in an **editable view**.  
- **Summarize** button to generate **AI summary**.  
- **Save Edit** button to store a **new version** under the original note.  
- List of all **edits** below the original note.  
- **Tap any word** to open a **definition popup** or panel with meaning, synonyms, and usage examples.  

**Summary Screen**  
- Displays **AI-generated summary**.  
- Option to **save summary** as a new note.  

**Scan Screen**  
- Uses **camera** to scan **printed or handwritten text**.  
- Extracted text appears with options to **save** or **translate**.  

**Translate Screen**  
- User selects a **target language** from a picker.  
- **Translated text** replaces or is saved alongside original.  

---

### **3. Navigation**

**Tab Navigation**  
- **Home** – List of saved original notes.  
- **Record** – Opens audio recorder & live transcription.  
- **Scan** – Opens camera for text scanning.  

**Flow Navigation**  
- **Home Screen** → **Note Detail Screen** (tap note)  
- **Note Detail Screen** → **Summary Screen** (tap Summarize)  
- **Note Detail Screen** → **Word Meaning Popup** (tap word)  
- **Scan Screen** → **Translate Screen** (tap Translate)  
- **Record Screen** → **Save to Home** (tap Save)  


## **Tap-to-Define (How it works)**  
- User taps a word in the Note Detail TextView  
- App detects selected word and shows a popup definition (dictionary/lookup)  
- Works for both original and edited notes  

## **Schema**
[This section will be completed in Unit 9]

### **Models**

**Transcription**

| Property      | Type         | Description |
|---------------|--------------|-------------|
| id            | UUID         | Unique identifier for each transcription |
| text          | String       | Main note text (original or edited) |
| originalText  | String?      | Stores the unedited original note (optional) |
| date          | Date         | Date and time the note was created |
| edits         | [EditVersion]| List of all edits made to the original note |
| type          | String       | Type of note (e.g., "original", "summary", "translation") |

**EditVersion**

| Property   | Type   | Description |
|------------|--------|-------------|
| text       | String | Edited text version |
| timestamp  | Date   | When this edit was made |

**SummaryEntry**

| Property     | Type   | Description |
|--------------|--------|-------------|
| originalText | String | The text that was summarized |
| summaryText  | String | The AI-generated summary |
| summaryType  | String | Summary mode (bullet, action, tldr, tweet) |
| timestamp    | Date   | When the summary was generated |

---

## **Networking**

### **Home Screen**
- **Load all notes** from local storage (`UserDefaults`)
```swift
let notes = TranscriptionStorage.loadTranscriptions()


Speech-to-text using Apple’s Speech framework (SFSpeechRecognizer)

No network request; runs locally.

Note Detail Screen
Summarize note with OpenAI API


POST https://api.openai.com/v1/chat/completions
Headers:
  Authorization: Bearer OPENAI_API_KEY
  Content-Type: application/json
Body:
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant that summarizes text."},
    {"role": "user", "content": "Summarize the following text:\n\nNOTE_TEXT"}
  ],
  "temperature": 0.7
}
Scan Screen
OCR with Vision Framework (local, no API call)

Translate Screen
Translate text with OpenAI API


POST https://api.openai.com/v1/chat/completions
Headers:
  Authorization: Bearer OPENAI_API_KEY
  Content-Type: application/json
Body:
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant that translates text."},
    {"role": "user", "content": "Translate the following text to LANGUAGE:\n\nNOTE_TEXT"}
  ],
  "temperature": 0.7
}


