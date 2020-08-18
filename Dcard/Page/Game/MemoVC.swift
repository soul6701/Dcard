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

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    private var viewControllerList: [UIViewController] = []
    private var date = Date()
    var pageViewVC: UIPageViewController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GameVC, let _vc = vc.selectedVC as? CalendarVC {
            _vc.reloadData()
            ToolbarView.shared.show(true)
        }
    }
    func setContent(date: Date) {
        self.date = date
    }
}
extension MemoVC {
    private func initView() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.lbTitle.text = formatter.string(from: self.date)
        ToolbarView.shared.show(false)
        confiPageViewVC()
    }
    private func confiPageViewVC() {
        self.viewControllerList.append(MemoPageOneVC())
        
        for i in 0...1 {
            let vc = UIViewController()
            vc.view.frame = self.viewContainer.frame
            if i == 0 {
                vc.view.backgroundColor = #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1)
            } else {
                vc.view.backgroundColor = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
            }
            self.viewControllerList.append(vc)
        }
        self.pageViewVC = UIPageViewController()
        self.pageViewVC.view.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.4502889555)
        self.pageViewVC.view.frame = self.viewContainer.bounds
        self.viewContainer.addSubview(self.pageViewVC.view)
        self.pageViewVC.didMove(toParent: self)
        self.pageViewVC.delegate = self
        self.pageViewVC.dataSource = self
        self.pageViewVC.setViewControllers([self.viewControllerList.first!], direction: .forward, animated: true, completion: nil)
        
        for gr in self.pageViewVC.view.gestureRecognizers! {
            gr.delegate = self
        }
    }
}

extension MemoVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.pageControl.currentPage -= 1
        if self.pageControl.currentPage == 0 {
            self.pageControl.currentPage = 3
        }
        return self.viewControllerList[self.pageControl.currentPage - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.pageControl.currentPage += 1
        if self.pageControl.currentPage == 4 {
            self.pageControl.currentPage = 1
        }
        return self.viewControllerList[self.pageControl.currentPage - 1]
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

extension MemoVC: UIGestureRecognizerDelegate {
    //無效化點擊跳頁
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if type(of: gestureRecognizer) == UITapGestureRecognizer.self {
            return false
        }
        return true
    }
}
