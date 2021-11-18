//
//  VodPlayerViewController.swift
//  
//
//  Created by Sacha DSO on 18/11/2021.
//
import SwiftUI
import Combine
import AVKit
import Networking

public protocol VodPlayerViewControllerDelegate: AnyObject {
    func vodPlayerViewControllerDidTapClose()
}

/// Wraps LiveVodPlayer to expose a clean UIKit api.
public class VodPlayerViewController: UIHostingController<LiveVodPlayer> {
    
    public weak var delegate: VodPlayerViewControllerDelegate?
    
    public convenience init(url: URL) {
        self.init(rootView: LiveVodPlayer(url: url, close: {}))
        rootView = LiveVodPlayer(url: url, close: { [weak self] in self?.delegate?.vodPlayerViewControllerDidTapClose()
				})
        modalPresentationStyle = .fullScreen
    }
}
