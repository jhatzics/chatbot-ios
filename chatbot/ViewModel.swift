//
//  ViewModel.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//
import MicrosoftCognitiveServicesSpeech
import AVFAudio

let speechKey = "80b39db2d95c494693f4e204b867de8e"
let speechRegion = "westus2"

class ViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isRecording: Bool = false
    private var speechConfig: SPXSpeechConfiguration?
    private var speechRecognizer: SPXSpeechRecognizer?
    private var speechSynthesizer: SPXSpeechSynthesizer?
    private var audioSession: AVAudioSession?
    private var audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    
    func askPermission() {
        AVAudioApplication.requestRecordPermission { response in
            print(response ? "Permission granted" : "Permission denied")
        }
    }
    
    private func startAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default)
            try audioSession?.setActive(true)
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        inputNode = audioEngine.inputNode
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    private func stopAudioSession() {
        do {
            try audioSession?.setActive(false)
        } catch {
            print("Error on stopAudioSession: \(error)")
        }
        audioEngine.stop()
    }

    private func setupVoiceAssistant() -> Bool {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: speechKey, region: speechRegion)
        } catch {
            return false
        }
        
        guard let speechConfig else { return false }
        speechConfig.speechRecognitionLanguage = "el-GR"
        speechConfig.speechSynthesisVoiceName = "el-GR-NestorasNeural"

        let audioConfig = SPXAudioConfiguration()
        
        guard let recognizer = try? SPXSpeechRecognizer(speechConfiguration: speechConfig, audioConfiguration: audioConfig) else { return false}
        speechRecognizer = recognizer
        
        guard let synthesizer = try? SPXSpeechSynthesizer(speechConfiguration: speechConfig, audioConfiguration: audioConfig) else { return false}
        
        speechSynthesizer = synthesizer
        

        return true
    }

    func recognizeVoice() {
        startAudioSession()
        
        speechRecognizer?.addRecognizedEventHandler { [weak self] _, result in
            guard self != nil else { return }
            guard let voiceText = result.result.text else { return }
            guard !voiceText.isEmpty else { return }
            
            DispatchQueue.main.async {
                self?.messages.append(Message(text: voiceText, isUser: true))
                self?.messages.append(Message(text: voiceText, isUser: false))
            }
        }
        
        try? speechRecognizer?.startContinuousRecognition()
    }
    
    func startSpeaking() {
        isRecording = true
        let status = setupVoiceAssistant()
        print(status ? "Voice Assistant is ready" : "Error: \(status)")
        recognizeVoice()
    }
    
    func stopSpeaking() {
        isRecording = false
        stopAudioSession()
    }
    
    func synthesisToSpeaker(_ text: String) {
        guard let synthesizer = speechSynthesizer else { return }
        
        DispatchQueue.main.async {
            let result = try! synthesizer.speakText(text)
            switch result.reason {
            case .canceled:
                print("speakText cancelled")
            case .synthesizingAudioCompleted:
                print("speaking completed")
            default:
                print("Other speaking error")
            }
        }
    }
}
