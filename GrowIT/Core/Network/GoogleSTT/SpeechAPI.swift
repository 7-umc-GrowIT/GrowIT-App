import Foundation
import Moya

enum SpeechAPI {
    case recognize(audioContent: String, apiKey: String)
    case synthesizeSpeech(text: String, apiKey: String)
}

extension SpeechAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .recognize:
            return URL(string: "https://speech.googleapis.com/v1")!
        case .synthesizeSpeech:
            return URL(string: "https://texttospeech.googleapis.com/v1")!
        }
        
    }
    
    var path: String {
        switch self {
        case .recognize:
            return "/speech:recognize"
        case .synthesizeSpeech:
            return "/text:synthesize"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .recognize(let audioContent, let apiKey):
            let parameters: [String: Any] = [
                "config": [
                    "encoding": "LINEAR16",
                    "sampleRateHertz": 16000,
                    "languageCode": "ko-KR"
                ],
                "audio": [
                    "content": audioContent
                ]
            ]
            return .requestCompositeParameters(bodyParameters: parameters, bodyEncoding: JSONEncoding.default, urlParameters: ["key": apiKey])
        case .synthesizeSpeech(let text, let apiKey):
            let parameters: [String: Any] = [
                "input": ["text": text],
                "voice": [
                    "languageCode": "ko-KR",
                    "name": "ko-KR-Chirp3-HD-Despina",  // Despina 음성
                    "ssmlGender": "FEMALE"       // Despina는 여성 음성
                ],
                "audioConfig": [
                    "audioEncoding": "LINEAR16",
                    "speakingRate": 1.1,        // 속도 (0.25~4.0)
                    "volumeGainDb": 0.0          // 볼륨 (-96.0~16.0)
                ]
            ]
            return .requestCompositeParameters(bodyParameters: parameters, bodyEncoding: JSONEncoding.default, urlParameters: ["key": apiKey])
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}
