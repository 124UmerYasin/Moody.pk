//
//  LocalVideoView.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 09/06/2021.
//

import UIKit
import AVKit

protocol LocalVideoViewDelegate: class {
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?)
}

class LocalVideoView: UIView {
    //MARK: - Properties
    weak var delegate: LocalVideoViewDelegate?
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    private let image = UIImage(named: "switchCamera")
    
    lazy private var switchCameraBtn: UIButton = {
        let switchCameraBtn = UIButton(type: .custom)
        switchCameraBtn.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        switchCameraBtn.setImage(image, for: .normal)
        switchCameraBtn.addTarget(self,
                                  action: #selector(didTapSwitchCamera(_:)),
                                  for: .touchUpInside)
        return switchCameraBtn
    }()
    
    lazy private var containerView: UIView = {
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.clear
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        insertSubview(containerView, at: 0)
        return containerView
    }()
    
    //MARK: - Life Circle
    public init(previewlayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame: CGRect.zero)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didTapSwitchCamera(_:)), name: NSNotification.Name(rawValue: "switchCamera"), object: nil)

        videoLayer = layer
        videoLayer?.videoGravity = .resizeAspectFill
        containerView.layer.insertSublayer(layer, at:0)
        
        //addSubview(switchCameraBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.frame = bounds
        videoLayer?.frame = bounds
        let buttonSize = CGSize(width: 72.0 / 2.5, height: 54.0 / 2.5)
        switchCameraBtn.frame = CGRect(x: bounds.size.width - buttonSize.width - 5.0,
                                       y: bounds.size.height - buttonSize.height - 30.0,
                                       width: buttonSize.width, height: buttonSize.height)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    //MARK: - Actions
    @objc private func didTapSwitchCamera(_ sender: UIButton?) {
        delegate?.localVideoView(self, pressedSwitchButton: sender)
    }
    
    //MARK: - Internal Methods
    private func updateOrientationIfNeeded() {
        let previewLayerConnection = videoLayer?.connection
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        let isVideoOrientationSupported = previewLayerConnection?.isVideoOrientationSupported
        
        guard let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue),
            isVideoOrientationSupported == true,
            previewLayerConnection?.videoOrientation != videoOrientation else {
                return
        }
        previewLayerConnection?.videoOrientation = videoOrientation
    }
    
   
}



