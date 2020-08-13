//
//  GameVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import UIView_Shake

enum SegmentedControlType: Int {
    case calculator = 0
    case skitch = 1
}
class GameVC: UIViewController {
    @IBOutlet weak var viewSeg: UISegmentedControl!
    var viewPrintVC: UIViewController!
    var selectedVC: UIViewController?
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        initView()
    }
    
    @IBAction func onClickSeg(_ sender: UISegmentedControl) {
        if selected != viewSeg.selectedSegmentIndex || selectedVC == nil {
            selected = viewSeg.selectedSegmentIndex
            
            selectedVC?.removeFromParent()
            selectedVC?.view.removeFromSuperview()
            
            var vc: UIViewController!
            let type: SegmentedControlType = SegmentedControlType.init(rawValue: selected)!
            switch type {
            case .calculator:
                vc = CalculatorVC()
            case .skitch:
                vc = SkitchVC()
            }
            self.addChild(vc)
            self.view.insertSubview(vc.view, at: 0)
            vc.didMove(toParent: self)
            selectedVC = vc
        }
    }
    func initView() {
        self.onClickSeg(viewSeg)
        self.viewSeg.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
    }
}
