//
//  MemoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: class {
    
    /// 設定頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - numberOfPage: _
    func pageViewController(_ pageViewController: UIPageViewController, didUpdateNumberOfPage numberOfPage: Int)
    
    /// 當 pageViewController 切換頁數時，設定 pageControl 的頁數
    ///
    /// - Parameters:
    ///   - pageViewController: _
    ///   - pageIndex: _
    func pageViewController(_ pageViewController: UIPageViewController, didUpdatePageIndex pageIndex: Int)
}

class MemoVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbCuteValue: UILabel!
    @IBOutlet weak var _image: UIImageView!
    
    private var date = Date()
    var pageViewVC: UIPageViewController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameVC, let _vc = vc.selectedVC as? CalendarVC {
            _vc.reloadData()
        }
    }
    @IBAction func onClickSlider(_ sender: UISlider) {
        lbCuteValue.text = "\(floor(sender.value))"
        
        if sender.value == sender.maximumValue {
            self._image.isHidden = false
            UIView.animate(withDuration: 2, animations: {
                self._image.transform = .init(scaleX: 4, y: 4)
            }) { finished in
//                if finished {
//                    self._image.transform = .init(rotationAngle: CGFloat.pi * 2)
//                }
            }
        }
    }
    func setContent(date: Date) {
        self.date = date
    }
}
extension MemoVC {
    func initView() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.lbTitle.text = formatter.string(from: self.date)
        self.pageViewVC = UIPageViewController()
        self.pageViewVC.view.backgroundColor = .clear
        self.pageViewVC.view.frame = self.viewContainer.bounds
//        self.viewContainer.addSubview(self.pageViewVC.view)
        self.pageViewVC.didMove(toParent: self)
        self.pageViewVC.delegate = self
        self.pageViewVC.dataSource = self
        self.image.loadGif(name: "柴犬2")
        self._image.isHidden = true
    }
}

extension MemoVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = UIViewController()
        vc.view.frame = self.viewContainer.frame
        vc.view.backgroundColor = #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = UIViewController()
        vc.view.frame = self.viewContainer.frame
        vc.view.backgroundColor = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        return vc
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        //
    }
    
}
extension MemoVC: PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didUpdateNumberOfPage numberOfPage: Int) {
        self.pageControl.numberOfPages = 3
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didUpdatePageIndex pageIndex: Int) {
        self.pageControl.currentPage = 1
    }
    
    
}
