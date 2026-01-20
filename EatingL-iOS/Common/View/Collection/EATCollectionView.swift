//
//  EATCollectionView.swift
//  dsadsd
//
//  Created by Micheal on 2025/12/22.
//

import UIKit

class EATCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        self.backgroundColor = nil
        self.backgroundView = nil
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never

        self.delaysContentTouches = false
        self.canCancelContentTouches = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 这里是为了导航栏返回穿透，如果有问题再处理
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y < 0 {
            return nil
        } else {
            return super.hitTest(point, with: event)
        }
    }

    var eat_registerClass: [AnyClass] = [] {
        didSet {
            for item in eat_registerClass {
                register(item, forCellWithReuseIdentifier: NSStringFromClass(item))
            }
        }
    }

    var eat_registerHeaderClass: [AnyClass] = [] {
        didSet {
            for item in eat_registerHeaderClass {
                register(item, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(item))
            }
        }
    }

    var eat_registerFooterClass: [AnyClass] = [] {
        didSet {
            for item in eat_registerFooterClass {
                register(item, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NSStringFromClass(item))
            }
        }
    }

}

// MARK: - LTR/RTL Layout

class EATCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        if EATConstant.eat_isRightToLeftLayout {
            return true
        } else {
            return false
        }
    }
}

extension UICollectionView {

    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.eat_identify, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.self)")
        }
        return cell
    }

    func dequeueReusableSupplementaryHeaderView<T: UICollectionReusableView>(for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: indexPath)
    }

    func dequeueReusableSupplementaryFooterView<T: UICollectionReusableView>(for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, for: indexPath)
    }

    private func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String,
                                                                               for indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind,
                                                          withReuseIdentifier: T.eat_identify,
                                                          for: indexPath) as? T else {
            fatalError("Unable to dequeue supplementary view of type \(T.self) for kind: \(kind)")
        }
        return view
    }
}
