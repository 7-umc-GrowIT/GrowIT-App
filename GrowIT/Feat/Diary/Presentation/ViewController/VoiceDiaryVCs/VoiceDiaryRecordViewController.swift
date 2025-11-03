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
    private var isRecording = false
    private var hasPlayedWelcomeMessage = false
    private var isPlayingWelcomeMessage = false

    // 대화 상태 관리
    private var isConversationActive = false
    private var isProcessingAudio = false
    private var isSpeaking = false
    private var conversationTurnCount = 0
    private var hasSpokenBefore = false

    // 음성 감지 관련
    private var silenceTimer: Timer?
    private var audioLevelTimer: Timer?
    private var speechDetected = false
    private var silenceThreshold: Float = -40.0
    private var silenceDuration: TimeInterval = 1.0
    private var currentSilenceDuration: TimeInterval = 0.0
    
    // 이어 말하기 관련
    private var isNewConversation: Bool = true
    private var isAddedChat: Bool = false
    private var isManualRecording = false
    private var suppressRestartListening = false
    private var suppressAutoProcessing = false

    private let diaryService = DiaryService()

    init(speechToTextUseCase: SpeechToTextUseCase,
         getSTTResponseUseCase: GetSTTResponseUseCase,
         textToSpeechUseCase: TextToSpeechUseCase,
         postVoiceDiaryUseCase: PostVoiceDiaryDateUseCase) {
        self.speechToTextUseCase = speechToTextUseCase
        self.getSTTResponseUseCase = getSTTResponseUseCase
        self.textToSpeechUseCase = textToSpeechUseCase
        self.postVoiceDiaryDateUseCase = postVoiceDiaryUseCase
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
        observeAudioRouteChanges()
    }

    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // 에어팟/이어폰 연결 여부에 따라 자동으로 라우팅
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            try audioSession.setActive(true)
            
            // 현재 오디오 라우트 확인
            configureAudioRouting()
            
            print("오디오 세션 초기화 완료")
        } catch {
            print("오디오 세션 초기화 실패: \(error)")
        }
    }
    
    // 오디오 라우팅 설정
    private func configureAudioRouting() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        
        // 현재 출력 장치 확인
        var hasBluetoothOutput = false
        var hasHeadphones = false
        
        for output in currentRoute.outputs {
            switch output.portType {
            case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
                hasBluetoothOutput = true
                print("블루투스 장치 연결됨: \(output.portName)")
            case .headphones:
                hasHeadphones = true
                print("유선 이어폰 연결됨: \(output.portName)")
            default:
                break
            }
        }
        
        do {
            if hasBluetoothOutput || hasHeadphones {
                // 에어팟/이어폰이 연결된 경우: 자동으로 해당 장치로 라우팅
                print("외부 오디오 장치로 라우팅")
            } else {
                // 연결된 장치가 없는 경우: 기기 스피커 사용
                try audioSession.overrideOutputAudioPort(.speaker)
                print("기기 스피커로 라우팅")
            }
        } catch {
            print("오디오 라우팅 설정 실패: \(error)")
        }
    }
    
    // 오디오 라우트 변경 감지
    private func observeAudioRouteChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            print("새 오디오 장치 연결됨")
            configureAudioRouting()
        case .oldDeviceUnavailable:
            print("오디오 장치 연결 해제됨")
            configureAudioRouting()
        default:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !hasPlayedWelcomeMessage {
            playWelcomeMessage()
            hasPlayedWelcomeMessage = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllInteractions()
        cleanupOnViewDisappear()
        
        // Observer 제거
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }

    private func cleanupOnViewDisappear() {
        stopConversation()
        voiceDiaryRecordView.stopConversationTimer()
        voiceDiaryRecordView.onRemainingTimeChanged = nil
    }

    private func observeRemainingTime() {
        voiceDiaryRecordView.onRemainingTimeChanged = { [weak self] remainingTime in
            guard let self = self else { return }

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
            textColor: .gray900
        )
    }

    // MARK: Setup UI
    private func setupUI() {
        view.addSubview(voiceDiaryRecordView)
        voiceDiaryRecordView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        voiceDiaryRecordView.recordButton.isHidden = true
        voiceDiaryRecordView.loadingButton.isHidden = true
        voiceDiaryRecordView.addLabel.isHidden = true

        voiceDiaryRecordView.endButton.addTarget(self, action: #selector(nextVC), for: .touchUpInside)
        voiceDiaryRecordView.helpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(helpTapped)))
        voiceDiaryRecordView.addLabel.isUserInteractionEnabled = true
        voiceDiaryRecordView.addLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTapped)))
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

    @objc func helpTapped() {
        let accountInquiryVC = AccountInquiryViewController()
        accountInquiryVC.setDarkMode()
        presentSheet(accountInquiryVC, heightRatio: 314/932, fixedHeight: 314)
    }
    
    @objc func addTapped() {
        print("할 말이 더 있어요 버튼 눌림")

        if !isManualRecording {
            // 자동 녹음 중단
            stopAutoRecording()
            isManualRecording = true
            
            suppressRestartListening = true
            suppressAutoProcessing = true

            // UI 수정
            voiceDiaryRecordView.loadingButton.isHidden = true
            voiceDiaryRecordView.addLabel.text = "끝났어요"

            // 수동 녹음 시작
            startManualRecording()
        } else {
            // 수동 녹음 종료 → 이 시점에서 서버에 전달
            stopManualRecording()
            suppressRestartListening = false
            isManualRecording = false
            isAddedChat = true

            // 버튼 텍스트 원래대로
            voiceDiaryRecordView.addLabel.isHidden = true

            // 수동 녹음 파일 처리
            if let recorder = audioRecorder {
                processAudioFile(audioFilePath: recorder.url)
            }
        }
    }

    func startManualRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            configureAudioRouting()

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
            let audioFilePath = tempDir + "manual-\(Date().timeIntervalSince1970).wav"
            let audioFileURL = URL(fileURLWithPath: audioFilePath)

            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true
            print("수동 녹음 시작")
        } catch {
            print("수동 녹음 오류: \(error.localizedDescription)")
        }
    }

    func stopManualRecording() {
        guard isRecording else { return }
        audioRecorder?.stop()
        isRecording = false
        print("수동 녹음 중지")
        
        DispatchQueue.main.async {
            self.voiceDiaryRecordView.loadingButton.isHidden = false
            self.voiceDiaryRecordView.addLabel.text = "할 말이 더 있어요"
            self.voiceDiaryRecordView.addLabel.isHidden = false
        }
    }

    func didTapExitButton() {
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            if viewControllers.count > 1 {
                let targetVC = viewControllers[1]
                navigationController.setViewControllers([viewControllers[0], targetVC], animated: true)
            }
        }
    }

    // MARK: - Conversation Management

    private func startConversation() {
        guard !isConversationActive else {
            print("대화가 이미 활성화됨")
            return
        }

        isConversationActive = true
        conversationTurnCount = 0

        voiceDiaryRecordView.startConversationTimer()

        print("대화 시작 - 타이머 시작됨")

        startAutoRecording()
    }

    private func stopConversation() {
        isConversationActive = false
        stopAllTimers()
        stopCurrentAudio()
        stopAllInteractions()

        voiceDiaryRecordView.stopConversationTimer()

        print("대화 중단")
    }

    private func finishConversation() {
        stopConversation()

        let remainingTime = voiceDiaryRecordView.remainingTime
        if remainingTime > 120 {
            CustomToast(containerWidth: 225).show(
                image: UIImage(named: "warningIcon") ?? UIImage(),
                message: "1분 이상 대화해 주세요",
                font: .heading3SemiBold()
            )
        } else {
            stopAllInteractions()
            let date = UserDefaults.standard.string(forKey: "VoiceDate") ?? ""

            Task{
                do{
                    let diary = try await postVoiceDiaryDateUseCase.execute(date: date)

                    await MainActor.run {
                        let nextVC = VoiceDiaryLoadingViewController(diary: diary)
                        nextVC.hidesBottomBarWhenPushed = true
                        navigationController?.pushViewController(nextVC, animated: true)
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
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            configureAudioRouting()

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
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true
            speechDetected = false
            currentSilenceDuration = 0.0

            print("자동 녹음 시작")

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

        DispatchQueue.main.async {
            self.voiceDiaryRecordView.loadingButton.isHidden = false
            self.voiceDiaryRecordView.addLabel.text = "할 말이 더 있어요"
            self.voiceDiaryRecordView.addLabel.isHidden = false
        }
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

        if averagePower > silenceThreshold {
            if !speechDetected {
                speechDetected = true
                hasSpokenBefore = true
                print("음성 감지됨 (레벨: \(averagePower) dB)")
            }
            currentSilenceDuration = 0.0
        } else {
            if speechDetected {
                currentSilenceDuration += 0.1

                if currentSilenceDuration >= silenceDuration {
                    print("침묵 감지 - 녹음 종료 (침묵 지속: \(currentSilenceDuration)초)")
                    stopAutoRecording()
                }
            }
        }

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
    
    func stopAllInteractions() {
        audioRecorder = nil
        isRecording = false
        
        stopCurrentAudio()
        audioPlayer = nil
        isSpeaking = false

        stopAllTimers()

        voiceDiaryRecordView.stopConversationTimer()
        
        voiceDiaryRecordView.loadingButton.isHidden = true
        voiceDiaryRecordView.addLabel.isHidden = true

        view.isUserInteractionEnabled = false
        
        voiceDiaryRecordView.onRemainingTimeChanged = nil

        isConversationActive = false
        isProcessingAudio = false
        isSpeaking = false
        isRecording = false
        hasPlayedWelcomeMessage = false
        isPlayingWelcomeMessage = false
    }

    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if isManualRecording {
            print("수동 녹음 중이므로 자동 녹음 처리 무시")
            return
        }

        if suppressAutoProcessing {
            print("자동 녹음 처리 억제됨")
            suppressAutoProcessing = false
            return
        }

        if flag {
            print("자동 녹음 완료")
            processAudioFile(audioFilePath: recorder.url)
        } else {
            print("자동 녹음 실패")
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.startAutoRecording()
            }
        }
    }

    // MARK: - Audio Processing

    private func processAudioFile(audioFilePath: URL) {
        guard let audioData = try? Data(contentsOf: audioFilePath) else {
            print("오디오 파일을 읽을 수 없습니다.")
            restartListening(withMessage: "다시 한 번 더 말씀해 주세요.")
            return
        }
        
        if audioData.count < 4000 {
            print("오디오 데이터가 너무 작음 - 무시")
            restartListening(withMessage: "다시 한 번 더 말씀해 주세요.")
            self.voiceDiaryRecordView.loadingButton.isHidden = true
            self.voiceDiaryRecordView.addLabel.isHidden = true
            return
        }
        
        isProcessingAudio = true
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let recognizedText = try await self.speechToTextUseCase.execute(audioData: audioData)
                let trimmedText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedText.isEmpty || trimmedText.count < 2 {
                    await MainActor.run {
                        self.isProcessingAudio = false
                        self.restartListening(withMessage: "다시 한 번 더 말씀해 주세요.")
                        self.voiceDiaryRecordView.loadingButton.isHidden = true
                        self.voiceDiaryRecordView.addLabel.isHidden = true
                    }
                    return
                }
                
               let responseText = try await self.getSTTResponseUseCase.execute(
                   data: DiaryVoiceRequestDTO(
                       isNewConversation: self.isNewConversation,
                       chat: trimmedText,
                       hasAdditionalChat: self.isAddedChat
                   )
               )
                
                await MainActor.run {
                    print("서버 응답: \(responseText)")
                    self.conversationTurnCount += 1
                    self.isProcessingAudio = false
                    
                    if !self.isManualRecording {
                        Task {
                            self.voiceDiaryRecordView.loadingButton.isHidden = true
                            self.voiceDiaryRecordView.addLabel.isHidden = true
                            self.isAddedChat = false
                            self.isNewConversation = false
                            await self.synthesizeSpeech(text: responseText)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isProcessingAudio = false
                    self.restartListening(withMessage: "다시 한 번 더 말씀해 주세요")
                    self.voiceDiaryRecordView.loadingButton.isHidden = true
                    self.voiceDiaryRecordView.addLabel.isHidden = true
                }
            }
        }
    }

    private func restartListening(withMessage message: String? = nil) {
        guard isConversationActive else { return }
        
        if suppressRestartListening {
            print("restartListening 억제됨")
            suppressRestartListening = false
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let message = message {
                Task {
                    await self.synthesizeSpeech(text: message)
                }
            } else {
                self.startAutoRecording()
            }
        }
    }

    // MARK: - TTS and Audio Playback

    private func synthesizeSpeech(text: String) async {
        isSpeaking = true

        do {
            print("TTS 변환 중...")
            let data = try await textToSpeechUseCase.execute(text: text)
            print("TTS 변환 완료, 재생 시작")

            playAudio(data: data)

        } catch {
            print("TTS 변환 실패: \(error.localizedDescription)")
            finishSpeaking()
        }
    }

    private func playAudio(data: Data) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // 오디오 재생 전에도 라우팅 설정
            configureAudioRouting()

            stopCurrentAudio()

            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.volume = 1.0
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startAutoRecording()
        }
    }

    // MARK: - Welcome Message

    private func playWelcomeMessage() {
        isPlayingWelcomeMessage = true
        let welcomeText = welcomeMessageManager.getRandomWelcomeMessage()
        print("웰컴 메시지: \(welcomeText)")

        Task {
            await self.synthesizeSpeech(text: welcomeText)
        }
    }

    // MARK: - Error Handling

    private func showRecordingError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
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
        print("오디오 재생 완료 (성공 여부: \(flag))")

        if isPlayingWelcomeMessage {
            print("웰컴 메시지 재생 완료. 대화 시작.")
            isPlayingWelcomeMessage = false
            isSpeaking = false
            startConversation()
        } else {
            finishSpeaking()
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("오디오 디코드 오류: \(error.localizedDescription)")
        }

        isSpeaking = false
        if isPlayingWelcomeMessage {
            isPlayingWelcomeMessage = false
            startConversation()
        } else {
            finishSpeaking()
        }
    }
}
