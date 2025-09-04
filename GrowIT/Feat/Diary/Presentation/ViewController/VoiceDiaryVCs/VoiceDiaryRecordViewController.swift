//
//  VoiceDiaryRecordViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/16/25.
//

import UIKit
import AVFoundation

protocol VoiceDiaryRecordDelegate: AnyObject {
    func didFinishRecording(diaryContent: String)
}

class VoiceDiaryRecordViewController: UIViewController, VoiceDiaryErrorDelegate, AVAudioRecorderDelegate {
    
    // MARK: Properties
    let voiceDiaryRecordView = VoiceDiaryRecordView()
    let navigationBarManager = NavigationManager()
    private let welcomeMessageManager = WelcomeMessageManager()
    private var speechAPIProvider = SpeechAPIProvider()
    private let speechToTextUseCase: SpeechToTextUseCase
    private let getSTTResponseUseCase: GetSTTResponseUseCase
    private let textToSpeechUseCase: TextToSpeechUseCase
    private let postVoiceDiaryDateUseCase: PostVoiceDiaryDateUseCase
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var isRecording = false // 녹음 진행 여부 확인
    private var hasPlayedWelcomeMessage = false // 웰컴 메시지 재생 여부 확인
    
    // 대화 상태 관리
    private var isConversationActive = false // 대화 진행 여부 확인
    private var isProcessingAudio = false // 서버 전송/응답 여부 확인
    private var isSpeaking = false  // TTS 재생 여부 확인
    private var conversationTurnCount = 0
    
    // 음성 감지 관련
    private var silenceTimer: Timer?
    private var audioLevelTimer: Timer?
    private var speechDetected = false
    private var silenceThreshold: Float = -40.0  // dB 임계값
    private var silenceDuration: TimeInterval = 1.0  // 침묵 지속 시간 (초)
    private var currentSilenceDuration: TimeInterval = 0.0
    
    private let diaryService = DiaryService()
    
    init(speechToTextUseCase: SpeechToTextUseCase,
         getSTTResponseUseCase: GetSTTResponseUseCase,
         textToSpeechUseCase: TextToSpeechUseCase,
         postVoiceDiaryDateUseCase: PostVoiceDiaryDateUseCase) {
        self.speechToTextUseCase = speechToTextUseCase
        self.getSTTResponseUseCase = getSTTResponseUseCase
        self.textToSpeechUseCase = textToSpeechUseCase
        self.postVoiceDiaryDateUseCase = postVoiceDiaryDateUseCase
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        observeRemainingTime()
        requestMicrophonePermission()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            print("오디오 세션 초기화 완료")
        } catch {
            print("오디오 세션 초기화 실패: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 웰컴 메시지 재생 후 대화 시작
        if !hasPlayedWelcomeMessage {
            playWelcomeMessage()
            hasPlayedWelcomeMessage = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupOnViewDisappear()
    }
    
    // 화면이 사라질 때 완전 정리
    private func cleanupOnViewDisappear() {
        stopConversation()
        voiceDiaryRecordView.stopConversationTimer() // 타이머 완전 정지
        voiceDiaryRecordView.onRemainingTimeChanged = nil // 콜백 제거
    }
    
    private func observeRemainingTime() {
        voiceDiaryRecordView.onRemainingTimeChanged = { [weak self] remainingTime in
            guard let self = self else { return }
            
            // 현재 화면이 활성 상태인지 확인
            guard self.isViewLoaded && self.view.window != nil else {
                print("화면이 비활성 상태 - 토스트 표시 안함")
                return
            }
            
            if remainingTime == 30 {
                CustomToast(containerWidth: 239).show(
                    image: UIImage(named: "warningIcon") ?? UIImage(),
                    message: "30초 후 대화가 종료돼요",
                    font: .heading3SemiBold()
                )
            } else if remainingTime <= 0 {
                // 시간 종료 시 대화 자동 종료
                self.finishConversation()
            }
        }
    }
    
    // MARK: Setup Navigation Bar
    private func setupNavigationBar() {
        navigationBarManager.addBackButton(
            to: navigationItem,
            target: self,
            action: #selector(prevVC),
            tintColor: .white
        )
        
        navigationBarManager.setTitle(
            to: navigationItem,
            title: "",
            textColor: .black
        )
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryRecordView)
        voiceDiaryRecordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 기존 버튼들 숨김 (대화식으로 변경)
        voiceDiaryRecordView.recordButton.isHidden = true
        voiceDiaryRecordView.loadingButton.isHidden = true
        
        voiceDiaryRecordView.endButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
    }
    
    // MARK: @objc methods
    @objc func prevVC() {
        let prevVC = VoiceDiaryRecordErrorViewController()
        prevVC.delegate = self
        let navController = UINavigationController(rootViewController: prevVC)
        navController.modalPresentationStyle = .fullScreen
        
        presentSheet(navController, heightRatio: 0.37)
    }
    
    @objc func nextVC() {
        finishConversation()
    }
    
    func didTapExitButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Conversation Management
    
    private func startConversation() {
        guard !isConversationActive else { return }
        
        isConversationActive = true
        conversationTurnCount = 0
        
        voiceDiaryRecordView.startConversationTimer()
        
        print("대화 시작")
        updateConversationUI(state: .listening)
        
        // 잠시 후 자동으로 첫 번째 녹음 시작
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.startAutoRecording()
        }
    }
    
    private func stopConversation() {
        isConversationActive = false
        stopAutoRecording()
        stopAllTimers()
        stopCurrentAudio()
        
        voiceDiaryRecordView.stopConversationTimer()
        
        print("대화 중단")
        updateConversationUI(state: .idle)
    }
    
    private func finishConversation() {
        stopConversation()
        
        // 기존 로직 유지
        let remainingTime = voiceDiaryRecordView.remainingTime
        if remainingTime > 120 {
            CustomToast(containerWidth: 225).show(
                image: UIImage(named: "warningIcon") ?? UIImage(),
                message: "1분 이상 대화해 주세요",
                font: .heading3SemiBold()
            )
            // 대화 재시작
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.startConversation()
            }
        } else {
            let date = UserDefaults.standard.string(forKey: "VoiceDate") ?? ""
            let nextVC = VoiceDiaryLoadingViewController()
            nextVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(nextVC, animated: true)
            
            Task{
                do{
                    let diary = try await postVoiceDiaryDateUseCase.execute(date: date)
                    
                    await MainActor.run {
                        nextVC.navigateToNextScreen(with: diary.content, diaryId: diary.id, date: diary.date)

                    }
                } catch {
                    print("요약된 일기 가져오기 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - Auto Recording with Voice Detection
    
    private func startAutoRecording() {
        guard isConversationActive && !isRecording && !isProcessingAudio && !isSpeaking else {
            print("녹음 시작 조건 불충족 - 대화중: \(isConversationActive), 녹음중: \(isRecording), 처리중: \(isProcessingAudio), 말하는중: \(isSpeaking)")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 16000,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let tempDir = NSTemporaryDirectory()
            let audioFilePath = tempDir + "conversation-\(Date().timeIntervalSince1970).wav"
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true  // 음성 레벨 측정 활성화
            audioRecorder?.record()
            
            isRecording = true
            speechDetected = false
            currentSilenceDuration = 0.0
            
            print("자동 녹음 시작")
            updateConversationUI(state: .listening)
            
            // 음성 레벨 모니터링 시작
            startAudioLevelMonitoring()
            
        } catch {
            print("자동 녹음 오류 발생: \(error.localizedDescription)")
            showRecordingError(message: "녹음을 시작할 수 없습니다: \(error.localizedDescription)")
        }
    }
    
    private func stopAutoRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        stopAllTimers()
        
        print("자동 녹음 중지")
        updateConversationUI(state: .processing)
    }
    
    // MARK: - Audio Level Monitoring
    
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkAudioLevel()
        }
    }
    
    private func checkAudioLevel() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // 음성 감지
        if averagePower > silenceThreshold {
            if !speechDetected {
                speechDetected = true
                print("음성 감지됨 (레벨: \(averagePower) dB)")
                updateConversationUI(state: .speaking)
            }
            currentSilenceDuration = 0.0
        } else {
            // 침묵 감지
            if speechDetected {
                currentSilenceDuration += 0.1
                
                if currentSilenceDuration >= silenceDuration {
                    print("침묵 감지 - 녹음 종료 (침묵 지속: \(currentSilenceDuration)초)")
                    stopAutoRecording()
                }
            }
        }
        
        // 최대 녹음 시간 제한 (30초)
        if recorder.currentTime > 30.0 {
            print("최대 녹음 시간 도달 - 녹음 종료")
            stopAutoRecording()
        }
    }
    
    private func stopAllTimers() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("자동 녹음 완료")
            processAudioFile(audioFilePath: recorder.url)
        } else {
            print("자동 녹음 실패")
            // 대화 계속 진행
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.startAutoRecording()
            }
        }
    }
    
    // MARK: - Audio Processing
    
    private func processAudioFile(audioFilePath: URL) {
        guard let audioData = try? Data(contentsOf: audioFilePath) else {
            print("오디오 파일을 읽을 수 없습니다.")
            restartListening()
            return
        }
        
        // 오디오 데이터가 너무 작으면 무시 (0.5초 미만)
        if audioData.count < 4000 {
            print("오디오 데이터가 너무 작음 - 무시")
            restartListening()
            return
        }
        
        isProcessingAudio = true
        
        // 단일 Task로 전체 프로세스 처리
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                // 백그라운드에서 STT 처리
                let recognizedText = try await self.speechToTextUseCase.execute(audioData: audioData)
                
                let trimmedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedText.isEmpty || trimmedText.count < 2 {
                    await MainActor.run {
                        self.isProcessingAudio = false
                        self.restartListening()
                    }
                    return
                }
                
                // 백그라운드에서 서버 통신
                let responseText = try await self.getSTTResponseUseCase.execute(chat: trimmedText)
                
                // 결과만 메인 스레드로
                await MainActor.run {
                    print("서버 응답: \(responseText)")
                    self.conversationTurnCount += 1
                    self.isProcessingAudio = false
                    
                    Task {
                        await self.synthesizeSpeech(text: responseText)
                    }
                }
                
            } catch {
                await MainActor.run {
                    print("오디오 처리 실패: \(error.localizedDescription)")
                    self.isProcessingAudio = false
                    self.restartListening()
                }
            }
        }
    }
    
    private func restartListening() {
        guard isConversationActive else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startAutoRecording()
        }
    }
    
    // MARK: - TTS and Audio Playback
    
    private func synthesizeSpeech(text: String) async {
        isSpeaking = true
        
        do {
            print("TTS 변환 중...")
            let data = try await textToSpeechUseCase.execute(text: text)
            print("TTS 변환 완료, 재생 시작")
            
            // 메인 스레드에서 오디오 재생
            playAudio(data: data)
            
        } catch {
            print("TTS 변환 실패: \(error.localizedDescription)")
            finishSpeaking()
        }
    }
    
    private func playAudio(data: Data) { // TTS 재생
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
            
            stopCurrentAudio()
            
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            print("응답 음성 재생 시작")
        } catch {
            print("음성 파일 재생 실패: \(error.localizedDescription)")
            finishSpeaking()
        }
    }
    
    private func stopCurrentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func finishSpeaking() {
        isSpeaking = false
        
        // 응답 완료 후 다시 듣기 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restartListening()
        }
    }
    
    // MARK: - Welcome Message
    
    private func playWelcomeMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.playRandomWelcomeMessage()
        }
    }
    
    private func playRandomWelcomeMessage() {
        let welcomeText = welcomeMessageManager.getRandomWelcomeMessage()
        print("웰컴 메시지: \(welcomeText)")
        
        Task {
            await self.synthesizeSpeech(text: welcomeText)
            
            await MainActor.run {
                self.startConversation()
            }
        }
    }
    
    // MARK: - UI State Management
    
    enum ConversationState {
        case idle
        case listening
        case speaking
        case processing
        case responding
    }
    
    private func updateConversationUI(state: ConversationState) {
        DispatchQueue.main.async {
            switch state {
            case .idle: break
                // 대기 상태 UI
                //self.voiceDiaryRecordView.tipView1?.isHidden = false
                //self.voiceDiaryRecordView.tipView2?.isHidden = true
                
            case .listening: break
                // 듣는 중 UI
                //self.voiceDiaryRecordView.tipView1?.isHidden = true
                //self.voiceDiaryRecordView.tipView2?.isHidden = false
                // 듣는 중 애니메이션이나 표시
                
            case .speaking: break
                // 사용자가 말하는 중 UI
                // 음성 파형이나 녹음 중 표시
                
            case .processing: break
                // 음성 처리 중 UI
                // 로딩 표시
                
            case .responding:
                // AI가 응답하는 중 UI
                // 말하는 중 표시
                break
            }
        }
    }
    
    // MARK: - Error Handling
    
    private func showRecordingError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            // 에러 후 대화 재시작
            self.restartListening()
        })
        present(alert, animated: true)
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("마이크 사용 허용됨")
                } else {
                    print("마이크 사용 거부됨")
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "마이크 권한 필요",
            message: "음성 대화를 위해 마이크 사용 권한이 필요합니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func callPostVoiceDiaryDate() async throws -> Diary{
        let date = UserDefaults.standard.string(forKey: "VoiceDate") ?? ""
        
        return try await postVoiceDiaryDateUseCase.execute(date: date)
    }
}

// MARK: - AVAudioPlayerDelegate

extension VoiceDiaryRecordViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("응답 음성 재생 완료")
        finishSpeaking()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("오디오 디코드 오류: \(error.localizedDescription)")
        }
        finishSpeaking()
    }
}
