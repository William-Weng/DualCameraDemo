//
//  Constant.swift
//  DualCameraDemo
//
//  Created by William.Weng on 2024/1/25.
//

import AVKit

// MARK: - Constant
final class Constant: NSObject {}

// MARK: - typealias
extension Constant {
    typealias WideAngleCamera = (front: AVCaptureDevice?, back: AVCaptureDevice?)                       // 前後鏡頭
    typealias DualWideAngleCameraInformation = (wideAngleCamera: WideAngleCamera, isSupported: Bool)    // 雙鏡頭支援 (雙鏡頭 / 是否支援)
}

// MARK: - enum
extension Constant {
    
    /// 自訂錯誤
    enum MyError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }

        case unknown
        case isSupportedWithDualWideAngleCamera
        case notUseFrontWideAngleCamera
        case notUseBackWideAngleCamera
        case notAddFrontWideAngleCamera
        case notAddBackWideAngleCamera
        case notAddFrontWideAngleCameraOutput
        case notAddBackWideAngleCameraOutput
        
        /// 顯示錯誤說明
        /// - Returns: String
        private func errorMessage() -> String {

            switch self {
            case .unknown: return "未知錯誤"
            case .isSupportedWithDualWideAngleCamera: return "不支援同時使用雙鏡頭"
            case .notUseFrontWideAngleCamera: return "不能使用前廣角鏡頭"
            case .notUseBackWideAngleCamera: return "不能使用後廣角鏡頭"
            case .notAddFrontWideAngleCamera: return "加入前廣角鏡頭"
            case .notAddBackWideAngleCamera: return "不能加入後廣角鏡頭"
            case .notAddFrontWideAngleCameraOutput: return "不能設定前廣角鏡頭輸出"
            case .notAddBackWideAngleCameraOutput: return "不能設定後廣角鏡頭輸出"
            }
        }
    }
}
