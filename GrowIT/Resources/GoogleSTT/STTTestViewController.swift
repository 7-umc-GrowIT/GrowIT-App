//
//  STTTestViewController.swift
//  GrowIT
//
//  Created by 이수현 on 1/23/25.
//

import UIKit
import googleapis
import AVFoundation
import Speech

class STTTestViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        AudioController.sharedInstance.delegate = self
        startButton.addTarget(self, action: #selector(startBtnClick), for: .touchUpInside)
        requestPermissions()
    }
    
    func requestPermissions() {
        // 마이크 권한 요청
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("✅ 마이크 권한 허용됨")
            } else {
                print("❌ 마이크 권한 거부됨")
            }
        }

        // 음성 인식 권한 요청
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("✅ 음성 인식 권한 허용됨")
            case .denied:
                print("❌ 음성 인식 권한 거부됨")
            case .restricted:
                print("❌ 음성 인식 권한 제한됨")
            case .notDetermined:
                print("❌ 음성 인식 권한 결정되지 않음")
            @unknown default:
                print("❌ 알 수 없는 권한 상태")
            }
        }
    }
    
    var audioData: NSMutableData!
    var check = false

    
    private let sttLabel = UILabel().then {
        $0.textColor = .black
    }
    
    private let startButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        // $0.setTitle("Start", for: .normal)
    }
    
    private let stopButton = UIButton().then {
        $0.backgroundColor = .systemBlue
        $0.setTitle("Stop", for: .normal)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(sttLabel)
        sttLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.top.equalTo(sttLabel.snp.bottom).offset(50)
            make.centerX.equalToSuperview().inset(100)
        }
        
        view.addSubview(stopButton)
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(startButton.snp.bottom).offset(50)
            make.centerX.equalToSuperview().inset(100)
        }
    }
    
    @objc func startBtnClick(sender: UITapGestureRecognizer) {
            print("Tapped")
            if(check){
                //스탑
                self.check = false
                _ = AudioController.sharedInstance.stop()
                SpeechRecognitionService.sharedInstance.stopStreaming()
                startButton.setTitle("말하기 시작", for: .normal)
            }
            else{
                //시작
                startButton.setTitle("말하기 멈추기", for: .normal)
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(AVAudioSession.Category.record)
                } catch {

                }
                audioData = NSMutableData()
                _ = AudioController.sharedInstance.prepare(specifiedSampleRate: 16000)
                SpeechRecognitionService.sharedInstance.sampleRate = 16000
                _ = AudioController.sharedInstance.start()
                
                self.check = true
            }
            
        }
    
}

extension STTTestViewController : AudioControllerDelegate {
    func processSampleData(_ data: Data) {
        func processSampleData(_ data: Data) -> Void {
            audioData.append(data)
            
            // We recommend sending samples in 100ms chunks
            let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
                                                        * Double(16000) /* samples/second */
                                                        * 2 /* bytes/sample */);
            
            if (audioData.length > chunkSize) {
                SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                        completion:
                                                                            { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        print("error")
                        self?.sttLabel.text = error.localizedDescription
                    } else if let response = response {
                        var finished = false
                        print("response: \(response)\n, description: \(response.description)")
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                if result.isFinal {
                                    
                                    print("result: \(result.alternativesArray[0])")
                                    let trans = result.alternativesArray[0] as? SpeechRecognitionAlternative
                                    print("trans: \(trans?.transcript)")
                                    finished = true
                                    self?.sttLabel.text = trans?.transcript
                                }
                            }
                        }
                        if finished {
                            print("말하기종료")
                            self?.check = false
                            _ = AudioController.sharedInstance.stop()
                            SpeechRecognitionService.sharedInstance.stopStreaming()
                            self?.startButton.setTitle("말하기 시작", for: .normal)
                        }
                    }
                })
                self.audioData = NSMutableData()
            }
        }
    }
    
    
}
