//
//  ChallengeImageModalController.swift
//  GrowIT
//
//  Created by 허준호 on 1/29/25.
//

import UIKit
import Photos

class ChallengeImageModalController: UIViewController {

    private lazy var challengeImageModal = ChallengeImageModal()
    private lazy var challengeVerifyView = ChallengeVerifyView()
    private let imagePicker = UIImagePickerController()
    private var uploadImage: UIImage? // 인증샷 이미지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = challengeImageModal
        view.backgroundColor = .white
        
        imagePicker.delegate = self
        
        challengeImageModal.cameraBtn.addTarget(self, action: #selector(cameraBtnTapped), for: .touchUpInside)
        
        challengeImageModal.galleryBtn.addTarget(self, action: #selector(galleryBtnTapped), for: .touchUpInside)
    }
    
    @objc private func cameraBtnTapped(){
        imagePicker.sourceType = .camera
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.openImagePicker(sourceType: .camera)
                    }
                }
            }
        case .authorized:
            openImagePicker(sourceType: .camera)
        case .restricted, .denied:
            showPermissionDeniedAlert()
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    @objc private func galleryBtnTapped(){
        imagePicker.sourceType = .photoLibrary
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch authorizationStatus {
        case .notDetermined:
            // 권한이 아직 요청되지 않았다면 권한 요청
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        // 권한이 허용되면 이미지 피커 표시
                        self.present(self.imagePicker, animated: true, completion: nil)
                    } else {
                        // 권한 거부 처리
                        self.showPermissionDeniedAlert()
                    }
                }
            }
        case .authorized:
            // 권한이 이미 있으면 바로 이미지 피커 표시
            self.present(self.imagePicker, animated: true, completion: nil)
        case .restricted, .denied:
            // 권한이 거부되었거나 제한된 경우
            self.showPermissionDeniedAlert()
        case .limited:
            self.present(self.imagePicker, animated: true, completion: nil)
        @unknown default:
            // 예상치 못한 상태 처리
            break
        }
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "권한 필요", message: "사진 앨범 접근 권한이 필요합니다. 설정에서 이 앱의 사진 접근 권한을 허용해주세요.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ChallengeImageModalController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        //크기 변경 됐을 경우
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension ChallengeImageModalController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            uploadImage = image
            if let uploadImage = uploadImage {
                NotificationCenter.default.post(name: NSNotification.Name("ImageSelected"), object: nil, userInfo: ["image": image])
                
            }
            
        }
        // 이미지 피커를 닫은 후 모달 뷰 컨트롤러도 닫기
        picker.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 이미지 피커를 닫은 후 모달 뷰 컨트롤러도 닫기
        picker.dismiss(animated: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

