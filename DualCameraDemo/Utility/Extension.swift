//
//  Extension.swift
//  DualCameraDemo
//
//  Created by William.Weng on 2024/1/25.
//

import AVKit

// MARK: - AVCaptureDevice (static function)
extension AVCaptureDevice {
    
    /// [取得該選項的影音裝置](https://www.wwdcnotes.com/notes/wwdc19/249/)
    /// - Parameters:
    ///   - deviceType: [AVCaptureDevice.DeviceType](https://blog.csdn.net/u011686167/article/details/130795604)
    ///   - mediaType: AVMediaType?
    ///   - position: AVCaptureDevice.Position
    /// - Returns: AVCaptureDevice?
    static func _default(_ deviceType: AVCaptureDevice.DeviceType, for mediaType: AVMediaType?, position: AVCaptureDevice.Position) -> AVCaptureDevice? { return AVCaptureDevice.default(deviceType, for: mediaType, position: position) }
    
    /// 取得前後相機 => AVCaptureDevice
    /// - Returns: Constant.WideAngleCamera
    static func _wideAngleCamera() -> Constant.WideAngleCamera {
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices

        var videoDeivce: (front: AVCaptureDevice?, back: AVCaptureDevice?) = (nil, nil)
        
        for device in devices {
            switch device.position {
            case .front: videoDeivce.front = device
            case .back: videoDeivce.back = device
            case .unspecified: break
            @unknown default: fatalError()
            }
        }
        
        return videoDeivce
    }
}

// MARK: - AVCaptureDevice (function)
extension AVCaptureDevice {
    
    /// 取得裝置的Input => NSCameraUsageDescription / NSMicrophoneUsageDescription
    func _captureInput() -> Result<AVCaptureDeviceInput, Error> {
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: self)
            return .success(deviceInput)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - AVCaptureSession (function)
extension AVCaptureSession {
    
    /// 將影音的Input加入Session
    /// - Parameter input: AVCaptureInput
    /// - Returns: Bool
    func _canAddInput(_ input: AVCaptureInput?) -> Bool {
        
        guard let input = input,
              self.canAddInput(input)
        else {
            return false
        }
        
        self.addInput(input)
        return true
    }
    
    /// 將影音的Output加入Session
    /// - Parameter input: AVCaptureOutput
    /// - Returns: Bool
    func _canAddOutput(_ output: AVCaptureOutput?) -> Bool {
        
        guard let output = output,
              self.canAddOutput(output)
        else {
            return false
        }
        
        self.addOutput(output)
        return true
    }
    
    /// [產生、設定AVCaptureVideoPreviewLayer](https://www.jianshu.com/p/95f2cd87ad83)
    /// - Parameters:
    ///   - frame: CGRect
    ///   - videoGravity: AVLayerVideoGravity => .resizeAspectFill
    /// - Returns: AVCaptureVideoPreviewLayer
    func _previewLayer(with frame: CGRect, videoGravity: AVLayerVideoGravity = .resizeAspectFill) -> AVCaptureVideoPreviewLayer {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: self)
        
        previewLayer.frame = frame
        previewLayer.videoGravity = videoGravity
        
        return previewLayer
    }
}

// MARK: - AVCaptureMultiCamSession (static function)
extension AVCaptureMultiCamSession {
    
    /// [是否支援多鏡頭同時動作](https://developer.apple.com/documentation/avfoundation/avcapturemulticamsession/3183002-multicamsupported)
    /// - Returns: Bool
    static func _isSupported() -> Bool {
        return AVCaptureMultiCamSession.isMultiCamSupported
    }
    
    /// [取得雙鏡頭相關資訊](https://blog.csdn.net/u011686167/article/details/130795604)
    /// - Returns: Constant.DualWideAngleCameraInformation
    static func _dualWideAngleCamera() -> Constant.DualWideAngleCameraInformation {
        let info = Constant.DualWideAngleCameraInformation(wideAngleCamera: AVCaptureDevice._wideAngleCamera(), isSupported: AVCaptureMultiCamSession._isSupported())
        return info
    }
}

// MARK: - AVCaptureMultiCamSession (function)
extension AVCaptureMultiCamSession {
    
    /// 加入雙鏡頭輸入裝置
    /// - Returns: Result<Bool, Error>
    func _addDualCameraInput() -> Result<Bool, Error> {
        
        let dualWideAngleCamera = AVCaptureMultiCamSession._dualWideAngleCamera()
        
        guard dualWideAngleCamera.isSupported else { return .failure(Constant.MyError.isSupportedWithDualWideAngleCamera) }
        guard let frontCameraIntputResult = dualWideAngleCamera.wideAngleCamera.front?._captureInput() else { return .failure(Constant.MyError.notUseFrontWideAngleCamera) }
        guard let backCameraInputResult = dualWideAngleCamera.wideAngleCamera.back?._captureInput() else { return .failure(Constant.MyError.notUseBackWideAngleCamera) }
        
        switch frontCameraIntputResult {
        case .failure(let error): return .failure(error)
        case .success(let input):
            let isSuccess = self._canAddInput(input)
            if (!isSuccess) { return .failure(Constant.MyError.notAddFrontWideAngleCamera) }
        }
        
        switch backCameraInputResult {
        case .failure(let error): return .failure(error)
        case .success(let input):
            let isSuccess = self._canAddInput(input)
            if (!isSuccess) { return .failure(Constant.MyError.notAddBackWideAngleCamera) }
        }
        
        return .success(true)
    }
    
    /// 加入雙鏡頭輸出
    /// - Parameters:
    ///   - frontOutput: AVCaptureVideoDataOutput
    ///   - backOutput: AVCaptureVideoDataOutput
    ///   - delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    /// - Returns: Result<Bool, Error>
    func _addDualCameraOutput(front frontOutput: AVCaptureVideoDataOutput, back backOutput: AVCaptureVideoDataOutput, delegate: AVCaptureVideoDataOutputSampleBufferDelegate? = nil) -> Result<Bool, Error> {
        
        if (!self._canAddOutput(frontOutput)) { return .failure(Constant.MyError.notAddFrontWideAngleCameraOutput) }
        if (!self._canAddOutput(backOutput)) { return .failure(Constant.MyError.notAddBackWideAngleCameraOutput) }
        
        frontOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "FrontCameraQueue"))
        backOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "BackCameraQueue"))
        
        return .success(true)
    }
}
