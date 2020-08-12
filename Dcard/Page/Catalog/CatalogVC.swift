//
//  CatalogVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class CatalogVC: UIViewController {
    var myScrollView: UIScrollView!
    var fullSize :CGSize!
    let viewTab = UIView(frame: CGRect(x: 0, y: 60, width: 50, height: 5))
    var current = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        myScrollView = UIScrollView()
        fullSize = UIScreen.main.bounds.size
        
        let lbOne = UILabel()
        lbOne.text = "Ａ"
        lbOne.backgroundColor = .cyan
        lbOne.textAlignment = .center
        let lbTwo = UILabel()
        lbTwo.text = "Ｂ"
        lbTwo.backgroundColor = .cyan
        lbTwo.textAlignment = .center
        let lbThree = UILabel()
        lbThree.text = "Ｃ"
        lbThree.backgroundColor = .cyan
        lbThree.textAlignment = .center
        let stackView = UIStackView(arrangedSubviews: [lbOne, lbTwo, lbThree])
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        let viewContainer = UIView(frame: CGRect(x: 0, y: 50, width: fullSize.width, height: 10))
        stackView.frame = CGRect(x: 0, y: 0, width: viewContainer.bounds.width, height: viewContainer.bounds.height)
        viewContainer.backgroundColor = .darkGray
        viewContainer.addSubview(stackView)
        viewTab.backgroundColor = .systemBlue
        viewTab.center.x = 115 / 2
        
        view.addSubview(viewTab)
        view.addSubview(viewContainer)
        // 設置尺寸 也就是可見視圖範圍
        myScrollView.frame = CGRect(
          x: 0, y: 0, width: fullSize.width,
          height: fullSize.height - 80)

        // 實際視圖範圍 為 3*2 個螢幕大小
        myScrollView.contentSize = CGSize(
          width: fullSize.width * 3,
          height: fullSize.height * 2)
        // 是否顯示水平的滑動條
        myScrollView.showsHorizontalScrollIndicator = true

        // 是否顯示垂直的滑動條
        myScrollView.showsVerticalScrollIndicator = true

        // 滑動條的樣式
        myScrollView.indicatorStyle = .black

        // 是否可以滑動
        myScrollView.isScrollEnabled = true

        // 是否可以按狀態列回到最上方
        myScrollView.scrollsToTop = true

        // 是否限制滑動時只能單個方向 垂直或水平滑動
        myScrollView.isDirectionalLockEnabled = false

        // 滑動超過範圍時是否使用彈回效果
        myScrollView.bounces = true

        // 縮放元件的預設縮放大小
        myScrollView.zoomScale = 1.0

        // 縮放元件可縮小到的最小倍數
        myScrollView.minimumZoomScale = 0.5

        // 縮放元件可放大到的最大倍數
        myScrollView.maximumZoomScale = 2.0

        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        myScrollView.bouncesZoom = true

        // 設置委任對象
        myScrollView.delegate = self

        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        myScrollView.contentOffset = CGPoint(
          x: fullSize.width * 0.5, y: fullSize.height * 0.5)

        // 以一頁為單位滑動
        myScrollView.isPagingEnabled = true
        

        // 加入到畫面中
        self.view.addSubview(myScrollView)
        var myUIView = UIView()
        for i in 0...2 {
            for j in 0...1 {
                myUIView = UIView(frame: CGRect(
                  x: 0, y: 0, width: 100, height: 100))
                myUIView.tag = i * 10 + j + 1
                myUIView.center = CGPoint(
                  x: fullSize.width * (0.5 + CGFloat(i)),
                  y: fullSize.height * (0.5 + CGFloat(j)))
                let color =
                  ((CGFloat(i) + 1) * (CGFloat(j) + 1)) / 12.0
                myUIView.backgroundColor = UIColor.init(
                  red: color, green: color, blue: color, alpha: 1)
                myScrollView.addSubview(myUIView)
            }
        }
    }
}
extension CatalogVC: UIScrollViewDelegate {
    // 開始滑動時
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        self.current = scrollView.contentOffset.x
        if scrollView.isDecelerating && scrollView.contentOffset.x >= 0 {
            if scrollView.contentOffset.x >= self.current{
                self.viewTab.center.x += 115 * scrollView.contentOffset.x / self.fullSize.width
            } else {
                self.viewTab.center.x -= 115 * scrollView.contentOffset.x / self.fullSize.width
            }
            self.current = scrollView.contentOffset.x
        }
        
    }

    // 滑動時
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
        let verticalIndicator = scrollView.subviews[scrollView.subviews.count - 2]
        verticalIndicator.backgroundColor = .systemPink

        if scrollView.isDecelerating && scrollView.contentOffset.x >= 0 {
            current = scrollView.contentOffset.x
            if scrollView.contentOffset.x >= self.current {
                self.viewTab.center.x += 115 * scrollView.contentOffset.x / self.fullSize.width
            } else {
                self.viewTab.center.x -= 115 * scrollView.contentOffset.x / self.fullSize.width
            }
            self.current = scrollView.contentOffset.x
        }
    }

    // 結束滑動時
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if !scrollView.isDecelerating {
            switch scrollView.contentOffset.x {
            case 0..<self.fullSize.width:
                self.viewTab.center.x = 115 / 2
            case self.fullSize.width..<self.fullSize.width * 2:
                self.viewTab.center.x = 115 / 2 + 130
            case self.fullSize.width * 2..<self.fullSize.width * 3:
                self.viewTab.center.x = 115 / 2 + 260
            default:
                break
            }
        }
    }

    // 縮放的元件
    func viewForZoomingInScrollView(scrollView: UIScrollView)
      -> UIView? {
        // 這邊用來示範縮放的元件是 tag 為 1 的 UIView
        // 也就是左上角那個 UIView
        return self.view.viewWithTag(1)
    }

    // 開始縮放時
    func scrollViewWillBeginZooming(scrollView: UIScrollView,
      withView view: UIView?) {
        print("scrollViewWillBeginZooming")
    }

    // 縮放時
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //print("scrollViewDidZoom")
    }

    // 結束縮放時
    func scrollViewDidEndZooming(scrollView: UIScrollView,
      withView view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming")

        // 縮放元件時 會將 contentSize 設為這個元件的尺寸
        // 會導致 contentSize 過小而無法滑動
        // 所以縮放完後再將 contentSize 設回原本大小
        myScrollView.contentSize = CGSize(
          width: fullSize.width * 3, height: fullSize.height * 2)
    }
}
