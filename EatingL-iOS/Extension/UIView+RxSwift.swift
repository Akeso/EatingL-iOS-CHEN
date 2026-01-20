//
//  UIView+RxSwift.swift
//  LiveShow
//
//  Created by star on 2021/3/16.
//

import RxCocoa
import RxSwift
import UIKit

extension UIView {

    func rx_scrollView(_ scrollView: UIScrollView, _ disposeBag: DisposeBag) {
        scrollView.rx.contentOffset.subscribe(onNext: { [weak self] (point) in
            if let height = self?.frame.height {
                if point.y >= -height {
                    self?.frame = CGRect(x: 0, y: -(point.y+height), width: SCREEN_WIDTH, height: height)
                } else {
                    self?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: height)
                }
            }
        }).disposed(by: disposeBag)
    }

    func rx_tabScrollView(_ scrollView: UIScrollView, _ disposeBag: DisposeBag) {
        scrollView.rx.contentOffset.subscribe(onNext: { [weak self] (point) in
            if let height = self?.frame.height {
                self?.frame = CGRect(x: 0, y: -max(point.y, 0), width: SCREEN_WIDTH, height: height)
            }
        }).disposed(by: disposeBag)
    }

}
