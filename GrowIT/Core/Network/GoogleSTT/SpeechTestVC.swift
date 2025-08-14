import UIKit
import AVFoundation

class SpeechTestVC: UIViewController, AVAudioRecorderDelegate {
    private let transcriptionLabel = UILabel()
    private var audioRecorder: AVAudioRecorder?
    private var isRecording = false // 녹음 상태 관리
    private var speechAPIProvider = SpeechAPIProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestMicrophonePermission()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        transcriptionLabel.text = "음성을 입력하세요"
        transcriptionLabel.textAlignment = .center
        transcriptionLabel.numberOfLines = 0
        transcriptionLabel.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 100)
        view.addSubview(transcriptionLabel)
        
        let recordButton = UIButton(type: .system)
        recordButton.setTitle("녹음 시작", for: .normal)
        recordButton.frame = CGRect(x: 50, y: view.bounds.height - 150, width: view.bounds.width - 100, height: 50)
        recordButton.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        recordButton.tag = 100 // 버튼을 식별하기 위한 태그
        view.addSubview(recordButton)
    }
    
    @objc private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
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
                AVLinearPCMIsFloatKey: false
            ]
            
            let tempDir = NSTemporaryDirectory()
            let audioFilePath = tempDir + "speech-to-text.wav"
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            transcriptionLabel.text = "녹음 중..."
            updateRecordButtonTitle(to: "녹음 멈추기")
        } catch {
            print("녹음 오류 발생: \(error.localizedDescription)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        transcriptionLabel.text = "녹음 완료. 처리 중..."
        updateRecordButtonTitle(to: "녹음 시작")
    }
    
    private func updateRecordButtonTitle(to title: String) {
        if let recordButton = view.viewWithTag(100) as? UIButton {
            recordButton.setTitle(title, for: .normal)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("녹음 성공")
            processAudioFile(audioFilePath: recorder.url)
        } else {
            transcriptionLabel.text = "녹음 실패. 다시 시도해주세요."
        }
    }
    
    private func processAudioFile(audioFilePath: URL) {
        guard let audioData = try? Data(contentsOf: audioFilePath) else {
            print("오디오 파일을 읽을 수 없습니다.")
            return
        }
        
        let audioBase64 = audioData.base64EncodedString()
        print("Base64 인코딩된 오디오 데이터 준비 완료")
        // 여기에서 Google Speech-to-Text API 호출 로직 추가
        speechAPIProvider.recognize(audioContent: audioBase64) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcript):
                    // 변환된 텍스트를 UILabel에 표시
                    self?.transcriptionLabel.text = transcript
                    print("변환된 텍스트: \(transcript)")
                case .failure(let error):
                    self?.transcriptionLabel.text = "변환 실패: \(error.localizedDescription)"
                    print("API 호출 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("마이크 사용 허용됨")
            } else {
                print("마이크 사용 거부됨")
                DispatchQueue.main.async {
                    self.transcriptionLabel.text = "마이크 사용 권한이 필요합니다."
                }
            }
        }
    }
}
