//
//  ATCComposeNewStoryViewController.swift
//  SocialNetwork
//
//  Created by Osama Naeem on 05/06/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ATCComposeNewStoryViewController : UIViewController {
    
    // MARK: - Properties
    var viewer: ATCUser?
    var dismissButton = ATCDismissButton()
    var editStoryVC : ATCEditStoryViewController!
    var delegate: ATCDidCreateNewStoryDelegate?
    
    lazy var captureButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 80.0 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleCaptureButton), for: .touchUpInside)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongpress))
        button.addGestureRecognizer(longPressGesture)
        return button
    }()

    var libraryButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage.localImage("library-landscape-icon", template: true), for: .normal)
        button.addTarget(self, action: #selector(handleLibraryButton), for: .touchUpInside)
        return button
    }()

    var switchCameraButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(UIImage.localImage("camera-rotate-icon", template: true), for: .normal)
        button.addTarget(self, action: #selector(handleCameraSwitch), for: .touchUpInside)
        return button
    }()

    var captureSession = AVCaptureSession()
    var currentCamera: AVCaptureDevice?
    var movieFileOutput: AVCaptureMovieFileOutput?

    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?

    // MARK: - Init
    init(viewer: ATCUser) {
        self.viewer = viewer
          super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        setupCaptureSession()
        setupDevice()
        setupInputDevice()
        setupPreviewLayer()
        startRunningCaptureLayer()
        configureDismissButton()
        configureCaptureButton()
        configureLibraryButton()
        configureSwitchCameras()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Configurations
    func configureDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(handleDismissButton), for: .touchUpInside)
        
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func configureCaptureButton() {
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }

    func configureLibraryButton() {
        view.addSubview(libraryButton)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 90).isActive = true
        libraryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        libraryButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        libraryButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func configureSwitchCameras() {
        view.addSubview(switchCameraButton)
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        switchCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -90).isActive = true
        switchCameraButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
        switchCameraButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        switchCameraButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }

    func setupCaptureSession() {
        movieFileOutput = AVCaptureMovieFileOutput()
        guard let movieFileOutput = movieFileOutput else { return }
        captureSession.addOutput(movieFileOutput)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }

    func setupDevice() {
        currentCamera = captureDevice(with: AVCaptureDevice.Position.back)
    }

    func setupInputDevice() {
         guard let currentCamera = currentCamera else { return }
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print("Error")
        }
    }

    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }

    func startRunningCaptureLayer() {
        captureSession.startRunning()
    }
    
    // MARK: - Handlers
    @objc func handleDismissButton() {
        self.dismiss(animated: true)
    }

    @objc func handleCaptureButton() {
        let setting = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: setting, delegate: self)
    }

    @objc func handleCameraSwitch() {
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }

        var deviceInput: AVCaptureDeviceInput!
        guard let newdevice = newDevice else { return }
        do {
            deviceInput = try AVCaptureDeviceInput(device: newdevice)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        captureSession.removeInput(input)
        captureSession.addInput(deviceInput)
    }

    @objc func handleLongpress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            print("BEGAN")
            captureButton.backgroundColor = .red
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsURL.appendingPathComponent("videoStory.mp4")
            if FileManager.default.fileExists(atPath: filePath.absoluteString) {
                do {
                    try FileManager.default.removeItem(at: filePath)
                }
                catch {
                    // exception while deleting old cached file
                    // ignore error if any
                }
            }
            movieFileOutput?.startRecording(to: filePath, recordingDelegate: self)
        } else if gesture.state == .ended {
            captureButton.backgroundColor = .white
            print("ENDED")
            debugPrint("longpress ended")
            DispatchQueue.main.async {
                self.movieFileOutput?.stopRecording()
            }
        }
    }

    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position:.unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }

    @objc func handleLibraryButton() {
        didTapAddImageButton(sourceType: UIImagePickerController.SourceType.photoLibrary)
    }

    private func didTapAddImageButton(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            picker.sourceType = sourceType
        } else {
            return
        }
        present(picker, animated: true, completion: nil)
    }

    fileprivate func didSelectImage(image: UIImage) {
        editStoryVC = ATCEditStoryViewController()
        editStoryVC.delegate = self
        editStoryVC.imageCaptured = image
        editStoryVC.viewer = viewer
        self.navigationController?.pushViewController(editStoryVC, animated: false)
    }
}

extension ATCComposeNewStoryViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let imageCaptured = UIImage(data: imageData)
            editStoryVC = ATCEditStoryViewController()
            editStoryVC.delegate = self
            editStoryVC.imageCaptured = imageCaptured
            editStoryVC.viewer = viewer
            self.navigationController?.pushViewController(editStoryVC, animated: false)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ATCComposeNewStoryViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found")
            return
        }
        picker.dismiss(animated: true, completion: nil)
        didSelectImage(image: selectedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ATCComposeNewStoryViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard let data = NSData(contentsOf: outputFileURL as URL) else {
            return
        }
        if error == nil {
         //
        }
        print("File size before compression: \(Double(data.length / 1048576)) mb")
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")

        compressVideo(inputURL: outputFileURL as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.editStoryVC = ATCEditStoryViewController()
                    self.editStoryVC.videoURL = session.outputURL
                    self.editStoryVC.viewer = self.viewer
                    self.navigationController?.pushViewController(self.editStoryVC, animated: false)
                }
                
            case .failed:
                print("Failed")
                break
            case .cancelled:
                break
            }
        }
    }

    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetLowQuality) else {
            handler(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

extension ATCComposeNewStoryViewController: ATStoryUpdateComposeViewControllerDelegate {
    func storyDidGetUpdated() {
        delegate?.didCreateNewStory()
    }
}
