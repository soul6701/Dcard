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
    case calendar = 2
}
class GameVC: UIViewController {
    @IBOutlet weak var viewSeg: UISegmentedControl!
    var selectedVC: UIViewController?
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        initView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MemoVC {
            vc.setContent(date: (sender as! Date))
        }
    }
    @IBAction func backToGameVC(_ segue: UIStoryboardSegue) {
        if let _ = segue.destination as? MemoVC {
            print("123")
        }
    }
    @IBAction func onClickSeg(_ sender: UISegmentedControl) {
        if self.selected != viewSeg.selectedSegmentIndex || selectedVC == nil {
            self.selected = viewSeg.selectedSegmentIndex
            
            self.selectedVC?.removeFromParent()
            self.selectedVC?.view.removeFromSuperview()
            
            let type: SegmentedControlType = SegmentedControlType.init(rawValue: selected)!
            switch type {
            case .calculator:
                self.selectedVC = CalculatorVC()
            case .skitch:
                self.selectedVC = SkitchVC()
            case .calendar:
                self.selectedVC = CalendarVC()
                (self.selectedVC as! CalendarVC).setDelegate(self)
            }
            self.addChild(selectedVC!)
            self.view.insertSubview(self.selectedVC!.view, at: 0)
            self.selectedVC!.didMove(toParent: self)
        }
    }
    func initView() {
        self.onClickSeg(viewSeg)
        self.viewSeg.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
    }
}

extension GameVC: CalendarVCDelegate {
    func toMemo(sender: Date) {
        self.performSegue(withIdentifier: "memo", sender: sender)
    }
}
