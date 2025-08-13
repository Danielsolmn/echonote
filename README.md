# **EchoNote**

---

## **Overview**

### **Description**

**EchoNote** is an **AI-powered productivity app** that transforms spoken words into organized, editable, and actionable notes. Users can **record speech**, instantly **transcribe it to text**, **edit** the transcription, **summarize** it with **AI**, **translate** it into different languages, **scan text** using their **camera**, or **tap on individual words** to instantly see their meanings and definitions. All **notes and edits** are stored for easy access, search, and sharing, making it perfect for **students, professionals**, and **anyone** who needs clear and concise records of conversations, lectures, or meetings.

---
## 📱 App Preview

<p align="center">
  <img src="assets/preview/Home.png" width="220" alt="Home Screen">
  <img src="assets/preview/Record.png" width="220" alt="Record Screen">
  <img src="assets/preview/Scan.png" width="220" alt="Scan Screen">
  <img src="assets/preview/Edit.png" width="220" alt="Edit Screen">
</p>
 
 
## 🎥 Video Walkthrough

<div>
  <a href="https://www.loom.com/share/adf0e4e71b604f118ad25942f6c55b31">
   
  </a>
  <a href="https://www.loom.com/share/adf0e4e71b604f118ad25942f6c55b31">
    <img style="max-width:300px;" src="https://cdn.loom.com/sessions/thumbnails/adf0e4e71b604f118ad25942f6c55b31-4d28a63d5f8b58fd-full-play.gif" alt="EconoNote Walkthrough">
  </a>
</div>

## **Product Spec**
## ✅ User Features

### Required (Must-have) Features

- [ x] **User can record audio** and see **live transcription**.
- [ x] **User can edit** and **save** the transcription to a **list of notes**.
- [ x] **User can tap a note** to open a **detailed view**.
- [x ] **User can generate AI summaries** of a note.
- [x ] **User can scan text** using the **camera** and save it as a note.
- [x ] **User can translate** notes into another language.
- [ x] **User can tap a word** to see its **definition** (via popup or bottom sheet).
- [x ] **All saved notes** appear in the **home screen table view**.
- [x ] **Each edit has a timestamp**, allowing users to track when changes were made.
- [ ] **User can tap a button to listen to the text** using **text-to-speech** (playback screen).

---

### Optional (Nice-to-have) Features

- [ ] **Cloud sync** for cross-device note access.
- [ ] **Collaborative note editing/sharing**.
- [ ] **Tagging** and **categorizing notes** for better organization.
- [ ] **Voice commands** to control recording or trigger summarization.
- [ ] **Export note as PDF** or share with other apps.
- [ ] **Search bar** to filter notes by keyword.
- [ ] **AI-generated flashcards** from transcriptions.
- [ ] **Settings screen** to control theme, language, or default behaviors.

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


## 🖼️ Wireframing

Below is the hand-drawn wireframe for **EconoNote**, showing the key screens and navigation flow of the app.

<<<<<<< HEAD
📄 [View Wireframe Sketch (png)(Wireframing.png)  
=======

This sketch includes:
- Home screen with saved notes
- Record/transcribe screen
- Note detail screen
- Scan screen (OCR)
- Summary and Translate screens
- Playback screen (text-to-speech)
- Tab navigation and screen transitions

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

## 🌐 Networking

This app uses a combination of **local processing** and **OpenAI API calls** for its core features.

---

### 🏠 Home Screen
- **Loads all saved notes** from local storage using `UserDefaults`:
```swift
let notes = TranscriptionStorage.loadTranscriptions()
```
- ✅ **No networking involved**

---

### 🗣️ Speech-to-Text (Recording)
- Powered by **Apple’s `Speech` framework** (`SFSpeechRecognizer`)
- ✅ Runs **entirely on-device** — **no network request**

---

### 📄 Note Detail Screen – Summarize Note
- Sends note text to **OpenAI's Chat API** for summarization

**API Endpoint:**
```
POST https://api.openai.com/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer OPENAI_API_KEY  
Content-Type: application/json
```

**Body:**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant that summarizes text."
    },
    {
      "role": "user",
      "content": "Summarize the following text:\n\nNOTE_TEXT"
    }
  ],
  "temperature": 0.7
}
```

---

### 📷 Scan Screen (OCR)
- Uses **Apple’s Vision framework** for **text recognition**
- ✅ Fully **local** — no networking required

---

### 🌍 Translate Screen
- Sends note text to **OpenAI's Chat API** for translation

**API Endpoint:**
```
POST https://api.openai.com/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer OPENAI_API_KEY  
Content-Type: application/json
```

**Body:**
```json
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant that translates text."
    },
    {
      "role": "user",
      "content": "Translate the following text to LANGUAGE:\n\nNOTE_TEXT"
    }
  ],
  "temperature": 0.7
}
```

---

### 📚 Dictionary / Word Definition Popup
- Planned feature: use **offline dictionary** for tapped word definitions
- Option to integrate external API for live definitions in the future


