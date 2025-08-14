import Foundation
import Moya

class SpeechAPIProvider {
    private let provider = MoyaProvider<SpeechAPI>()
    private let apiKey: String = Bundle.main.googleSpeechAPIKey
    
    func recognize(audioContent: String, completion: @escaping (Result<String, Error>) -> Void) {
        provider.request(.recognize(audioContent: audioContent, apiKey: apiKey)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let firstResult = results.first,
                       let alternatives = firstResult["alternatives"] as? [[String: Any]],
                       let transcript = alternatives.first?["transcript"] as? String {
                        completion(.success(transcript))
                    } else {
                        completion(.failure(NSError(domain: "SpeechAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "API 응답 형식 오류"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func synthesizeSpeech(text: String, completion: @escaping (Result<Data, Error>) -> Void) {
        provider.request(.synthesizeSpeech(text: text, apiKey: apiKey)) { result in
            switch result {
            case .success(let response):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [String: Any],
                       let audioContent = json["audioContent"] as? String,
                       let audioData = Data(base64Encoded: audioContent) {
                        completion(.success(audioData))
                    } else {
                        completion(.failure(NSError(domain: "SpeechAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "TTS 응답 형식 오류"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension Bundle {
    var googleSpeechAPIKey: String {
        return object(forInfoDictionaryKey: "Google_Speech_API_Key") as? String ?? ""
    }
}
