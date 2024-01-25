//
//  ViewController.swift
//  DualCameraDemo
//
//  Created by William.Weng on 2024/1/25.
//

import UIKit
import AVFoundation
import WWPrint

// MARK: - 使用雙鏡頭
final class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var subView: UIView!
    
    private var multiSession = AVCaptureMultiCamSession()
    private var frontCameraOutput = AVCaptureVideoDataOutput()
    private var backCameraOutput = AVCaptureVideoDataOutput()
    private var frontCameraPreviewLayer: AVCaptureVideoPreviewLayer!
    private var backCameraPreviewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        multiSessionSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayerSetting(mainView: mainView, subView: subView)
        DispatchQueue.global(qos: .background).async { self.multiSession.startRunning() }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        wwPrint(connection)
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 多鏡頭的裝置設定
    func multiSessionSetting() {

        let inputResult = multiSession._addDualCameraInput()

        switch inputResult {
        case .failure(let error): wwPrint(error)
        case .success(let isSuccess): wwPrint(isSuccess)
            
            if (isSuccess) {
                
                let outputResult = multiSession._addDualCameraOutput(front: frontCameraOutput, back: backCameraOutput, delegate: self)

                switch outputResult {
                case .failure(let error): wwPrint(error)
                case .success(let isSuccess): wwPrint(isSuccess)
                }
            }
        }
    }
    
    /// 多鏡頭的輸出畫面設定
    func previewLayerSetting(mainView: UIView, subView: UIView) {
        
        frontCameraPreviewLayer = multiSession._previewLayer(with: mainView.frame, videoGravity: .resizeAspectFill)
        backCameraPreviewLayer = multiSession._previewLayer(with: subView.frame, videoGravity: .resizeAspectFill)
        backCameraPreviewLayer.cornerRadius = subView.frame.width * 0.5
        
        mainView.layer.addSublayer(frontCameraPreviewLayer)
        mainView.layer.addSublayer(backCameraPreviewLayer)
    }
}
