//
//  ViewModel.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//
import MicrosoftCognitiveServicesSpeech
import AVFAudio
import Starscream


let speechKey = "80b39db2d95c494693f4e204b867de8e"
let speechRegion = "westus2"

enum Mode {
    case chat, voice
}

class SharedViewModel: ObservableObject, WebSocketDelegate {
    
    @Published var messages: [Message] = []
    @Published var isRecording: Bool = false
    @Published var inputText: String = ""
    @Published var mode: Mode = .chat
    private var speechConfig: SPXSpeechConfiguration?
    private var speechRecognizer: SPXSpeechRecognizer?
    private var speechSynthesizer: SPXSpeechSynthesizer?
    private var audioSession: AVAudioSession?
    private var audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private var botService: BotService
    private var socket: WebSocket?

    init() {
        botService = BotService()
        
        Task {
            let conv = try? await botService.initChat()
            guard let conv = conv else { return }
            connectSocket(url: conv.streamUrl)
        }
    }
    
    func askPermission() async {
        AVAudioApplication.requestRecordPermission { response in
            print(response ? "Permission granted" : "Permission denied")
        }
    }
    
    func sendMessage(with text: String) async {
        try? await botService.sendMessage(text)
    }
    
    func sendMessage() async {
        guard !self.inputText.isEmpty else { return }
        try? await botService.sendMessage(self.inputText)
        DispatchQueue.main.async {
            self.inputText = ""
        }
    }
    
    func connectSocket(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let text):
            print("Received text: \(text)")
            guard let data = text.data(using: .utf8) else { return }
            do {
                let response = try JSONDecoder().decode(ActivitiesResponse.self, from: data)
                guard let activity = response.activities.first else { return }
                
                DispatchQueue.main.async {
                    guard let msg = activity.text else { return }
                    self.messages.append(Message(text: msg, isUser: activity.from?.role != "bot"))
                    if (activity.from?.role == "bot" && self.mode == .voice) {
                        self.synthesisToSpeaker(msg)
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            print(error ?? "Generic error")
            case .peerClosed:
                   break
        }
    }
        
    private func startAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
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
        
        speechSynthesizer?.addSynthesisStartedEventHandler { [weak self] _,_  in
            do {
                try self?.speechRecognizer?.stopContinuousRecognition()
            } catch {
                print("speechRecognizer..stopped")
            }
        }
        
        speechSynthesizer?.addSynthesisCompletedEventHandler { [weak self] _, _ in
            do {
                try self?.speechRecognizer?.startContinuousRecognition()
            } catch {
                print("speechRecognizer..started")
            }
        }
        

        return true
    }

    private func recognizeVoice() {
        startAudioSession()
        
        speechRecognizer?.addRecognizedEventHandler { [weak self] _, result in
            guard self != nil else { return }
            guard let voiceText = result.result.text else { return }
            guard !voiceText.isEmpty else { return }
            
//            DispatchQueue.main.async {
//                self?.messages.append(Message(text: voiceText, isUser: true))
//                self?.messages.append(Message(text: voiceText, isUser: false))
//            }
            Task {
                await self?.sendMessage(with: voiceText)
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
        do {
            try self.speechSynthesizer?.stopSpeaking()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func stopRecording() {
        do {
            isRecording = false
            try self.speechRecognizer?.stopContinuousRecognition()
            stopAudioSession()
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func synthesisToSpeaker(_ text: String) {
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
