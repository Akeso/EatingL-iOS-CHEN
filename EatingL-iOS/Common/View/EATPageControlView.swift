//
//  EATPageControlView.swift
//  PhotoK-iOS
//
//  Created by tongshuai on 12/23/25.
//

import UIKit

class EATPageControlView: EATBaseView {

    // MARK: - Public API

    var numberOfPages: Int = 0 {
        didSet { rebuildDots() }
    }

    var currentPage: Int = 0 {
        didSet { updateDots(animated: true) }
    }

    var dotSize: CGFloat = 6 {
        didSet { rebuildDots() }
    }

    var currentDotSize: CGFloat = 8 {
        didSet { updateDots(animated: false) }
    }

    var dotSpacing: CGFloat = 8 {
        didSet { stackView.spacing = dotSpacing }
    }

    var dotColor: UIColor = .lightGray {
        didSet { updateDots(animated: false) }
    }

    var currentDotColor: UIColor = .white {
        didSet { updateDots(animated: false) }
    }

    // MARK: - Private

    private let stackView = UIStackView()
    private var dots: [UIView] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = dotSpacing
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Dots

    private func rebuildDots() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        guard numberOfPages > 0 else { return }

        for _ in 0..<numberOfPages {
            let dot = UIView()
            dot.backgroundColor = dotColor
            dot.layer.cornerRadius = dotSize / 2
            dot.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize)
            ])

            stackView.addArrangedSubview(dot)
            dots.append(dot)
        }

        updateDots(animated: false)
    }

    private func updateDots(animated: Bool) {
        guard dots.indices.contains(currentPage) else { return }

        for (index, dot) in dots.enumerated() {
            let isCurrent = index == currentPage
            let size = isCurrent ? currentDotSize : dotSize
            let color = isCurrent ? currentDotColor : dotColor

            dot.backgroundColor = color
            dot.layer.cornerRadius = size / 2

            dot.constraints.forEach {
                if $0.firstAttribute == .width || $0.firstAttribute == .height {
                    $0.constant = size
                }
            }

            if animated {
                UIView.animate(withDuration: 0.25) {
                    dot.layoutIfNeeded()
                }
            }
        }
    }
}
