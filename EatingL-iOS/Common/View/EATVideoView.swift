//
//  EATVideoView.swift
//  PhotoJ-iOS
//
//  Created by admin on 2021/11/17.
//

import AVFoundation
import SDWebImage
import UIKit

class EATVideoView: EATBaseView {

    @objc public var urls: [URL] {
        didSet {
            // 相同的 urls 不再重新加载
            if urls.count != oldValue.count || zip(urls, oldValue).map({ return $0 == $1 }).contains(false) {
                eat_refreshItems()
            }
        }
    }

    @objc public var videoGravity: AVLayerVideoGravity = .resizeAspectFill {
        didSet {
            playerLayer.videoGravity = videoGravity
        }
    }

    @objc public var isMute: Bool = false {
        didSet {
            player.isMuted = isMute
        }
    }

    @objc public var playerItems: [AVPlayerItem] = []
    @objc public var isLoop: Bool = true
    @objc public var isAutoPlayNext: Bool = true
    @objc public var autoPlayWhenAppBeActive: Bool = true

    @objc public var eat_playCompletion: () -> Void = {}
    @objc public var eat_playLoopCompletion: (_ index: Int) -> Void = {_ in}
    @objc public var eat_playReadyCompletion: () -> Void = {}
    // MARK: 新增placeholder, 默认不显示，列表时可更改为true显示
    @objc public var enablePlaceholderImage: Bool = false
    private var isActivePause: Bool = false

    private var rateObservation: NSKeyValueObservation?
    private var statusObservation: NSKeyValueObservation?

    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()

    override static var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer {
        guard let playerLayer = layer as? AVPlayerLayer else {
            fatalError("Layer is not AVPlayerLayer")
        }
        playerLayer.player = player
        playerLayer.shouldRasterize = true
        playerLayer.rasterizationScale = UIScreen.main.scale
        playerLayer.videoGravity = videoGravity
        return playerLayer
    }

    // MARK: 新增placeholder，获取video第一帧，避免列表刷新闪烁
    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    @objc public init(urls: [URL] = []) {
        self.urls = urls
        super.init(frame: .zero)
        self.eat_initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.bounds = bounds
    }

    deinit {
        eat_stopPlay()
        NotificationCenter.default.removeObserver(self)
        rateObservation?.invalidate()
        statusObservation?.invalidate()
    }

    open func eat_initViews() {
        eat_refreshItems()
        eat_addObserver()

        addSubview(placeholderImageView)
        sendSubviewToBack(placeholderImageView)
        placeholderImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func eat_addObserver() {
        rateObservation = player.observe(\.rate, options: [.new, .old]) { [weak self] _, change in
            if let rate = change.newValue {
                if rate == 0.0 && UIApplication.shared.applicationState == .active {
                    self?.isActivePause = true
                } else {
                    self?.isActivePause = false
                }
            }
        }

        statusObservation = player.observe(\.status, options: [.new, .old]) { [weak self] _, change in
            if let status = change.newValue, status == .readyToPlay {
                self?.eat_playReadyCompletion()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(eat_itemDidPlayToEndTime(notification:)), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eat_applicationDidBecomeActive(notifcation:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eat_applicationDidEnterBackground(notification:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        // 添加内存警告通知监听，在内存不足时清理placeholder缓存
        NotificationCenter.default.addObserver(self, selector: #selector(eat_applicationDidReceiveMemoryWarning(notification:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    private func eat_refreshItems() {
        player.replaceCurrentItem(with: nil)
        playerItems.removeAll()
        for url in urls {
            let item = AVPlayerItem(url: url)
            playerItems.append(item)
        }
        player.replaceCurrentItem(with: playerItems.first)
        // 加载placeholder
        eat_loadPlaceholderImageIfNeeded()
    }

    @objc public func eat_startPlay() {
        player.play()
    }

    @objc public func eat_restartPlay() {
        player.seek(to: .zero)
        player.play()
    }

    @objc public func eat_stopPlay(isReset: Bool = false) {
        player.pause()
        if isReset {
            player.seek(to: .zero)
        }
    }
}

extension EATVideoView {

    @objc private func eat_itemDidPlayToEndTime(notification: Notification) {
        guard let item = notification.object as? AVPlayerItem,
              var index = playerItems.firstIndex(of: item) else {
            return
        }

        index += 1
        if index >= playerItems.count {
            if !isLoop {
                eat_playCompletion()
                return
            }
            index = 0
        }

        eat_playLoopCompletion(index)

        eat_handlePlayToEndTime(nextIndex: index)
    }

    /// 处理视频播放完成后的行为，子类可以重写此方法来自定义行为
    /// - Parameter nextIndex: 下一个要播放的视频索引
    @objc open func eat_handlePlayToEndTime(nextIndex: Int) {
        if isAutoPlayNext {
            player.replaceCurrentItem(with: playerItems[nextIndex])
            player.seek(to: .zero)
            player.play()
        } else {
            player.replaceCurrentItem(with: playerItems[nextIndex])
            player.seek(to: .zero)
        }
    }

    @objc private func eat_applicationDidBecomeActive(notifcation: Notification) {
        if autoPlayWhenAppBeActive && !isActivePause {
            eat_startPlay()
        }
    }

    @objc private func eat_applicationDidEnterBackground(notification: Notification) {
        if autoPlayWhenAppBeActive && !isActivePause {
            eat_stopPlay()
        }
    }

    // 处理内存警告，清理placeholder以释放内存
    @objc private func eat_applicationDidReceiveMemoryWarning(notification: Notification) {
        EATVideoViewPlaceholderCacheManager.shared.eat_clear()
    }
}

// MARK: - placeholder
extension EATVideoView {

    // 加载第一帧作为占位图
    private func eat_loadPlaceholderImageIfNeeded() {
        guard enablePlaceholderImage else {
            placeholderImageView.image = nil
            return
        }

        guard let firstURL = urls.first else {
            placeholderImageView.image = nil
            return
        }

        if let cachedImage = EATVideoViewPlaceholderCacheManager.shared.eat_image(for: firstURL) {
            placeholderImageView.image = cachedImage
            return
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let asset = AVAsset(url: firstURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.apertureMode = .encodedPixels
            do {
                let cgImage = try generator.copyCGImage(at: CMTime(seconds: 0.1, preferredTimescale: 600), actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    EATVideoViewPlaceholderCacheManager.shared.eat_store(image, for: firstURL)
                    self.placeholderImageView.image = image
                }
            } catch {
                debugPrint("❌ 获取视频第一帧失败: \(error.localizedDescription)")
            }
        }
    }
}

/// 用于缓存视频第一帧占位图的工具类，确保在 App 生命周期内可复用，避免重复生成第一帧图像
private class EATVideoViewPlaceholderCacheManager {

    static let shared = EATVideoViewPlaceholderCacheManager()
    // 添加串行队列确保线程安全，避免多线程访问 imageCache 导致崩溃
    private let cacheQueue = DispatchQueue(label: "com.eat.videocache.queue")
    private var imageCache: [String: UIImage] = [:]

    private init() {}

    private func eat_cacheKey(for url: URL) -> String? {
        /** 支持 file://、http://、https://，其余直接跳过 */
        guard url.isFileURL || url.scheme?.lowercased().hasPrefix("http") == true else {
            return nil
        }
        // whitespacesAndNewlines 去除字符串所有的空白字符和换行字符
        let absolute = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !absolute.isEmpty else {
            return nil
        }
        return "eat_placeholder_\(absolute)"
    }

    func eat_image(for url: URL) -> UIImage? {
        guard let key = eat_cacheKey(for: url) else { return nil }
        return cacheQueue.sync {
            return imageCache[key]
        }
    }

    func eat_store(_ image: UIImage, for url: URL) {
        guard let key = eat_cacheKey(for: url) else { return }
        cacheQueue.sync {
            self.imageCache[key] = image
        }
    }

    func eat_removeImage(for url: URL) {
        guard let key = eat_cacheKey(for: url) else { return }
        _ = cacheQueue.sync {
            self.imageCache.removeValue(forKey: key)
        }
    }

    func eat_clear() {
        cacheQueue.sync {
            self.imageCache.removeAll()
        }
    }
}
