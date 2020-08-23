//
//  MemoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol MemoPageVCDelegate {
    func saveDiary(content: String)
}

class MemoVC: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    private var viewControllerList: [UIViewController] {
        var list = [UIViewController]()
        list.append(self.pageOneVC)
        list.append(self.pageTwoVC)
        list.append(self.pageThreeVC)
        return list
    }
    private var pageOneVC: MemoPageOneVC!
    private var pageTwoVC: MemoPageTwoVC!
    private var pageThreeVC: MemoPageThreeVC!
    private var date = Date()
    private var pageTwoContent = ""
    
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
        self.pageControl.currentPage = 0
        ToolbarView.shared.show(false)
        confiPageViewVC()
    }
    private func confiPageViewVC() {
        
        self.pageViewVC = UIPageViewController()
        self.pageViewVC.view.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.4502889555)
        self.pageViewVC.view.frame = self.viewContainer.bounds
        self.viewContainer.addSubview(self.pageViewVC.view)
        self.pageViewVC.didMove(toParent: self)
        self.pageViewVC.delegate = self
        self.pageViewVC.dataSource = self
        reloadPageData(page: [0, 1, 2])
        self.pageViewVC.setViewControllers([self.viewControllerList.first!], direction: .forward, animated: true, completion: nil)
        
        for gr in self.pageViewVC.view.gestureRecognizers! {
            gr.delegate = self
        }
    }
    private func reloadPageData(page: [Int]) {
        page.forEach { (page) in
            if page == 0 {
                let vc = MemoPageOneVC()
                vc.setContent()
                pageOneVC = vc
            }
            if page == 1 {
                let vc = MemoPageTwoVC()
                vc.setContent(content: self.pageTwoContent)
                pageTwoVC = vc
            }
            if page == 2 {
                let vc = MemoPageThreeVC()
                vc.setContent()
                pageThreeVC = vc
            }
        }
    }
}

extension MemoVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.pageControl.currentPage -= 1
        if let _ = viewController as? MemoPageOneVC {
            self.pageControl.currentPage = 2
        }
        return self.viewControllerList[self.pageControl.currentPage]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.pageControl.currentPage += 1
        if let _ = viewController as? MemoPageThreeVC {
            self.pageControl.currentPage = 0
        }
        return self.viewControllerList[self.pageControl.currentPage]
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

extension MemoVC: MemoPageVCDelegate {
    func saveDiary(content: String) {
//        reloadPageData(page: [1])
    }
}
