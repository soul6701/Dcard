//
//  GameVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import UIView_Shake

private enum SegmentedControlType: Int {
    case calculator = 0
    case skitch
    case calendar
}
class GameVC: UIViewController {
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    var calculatorVC: CalculatorVC!
    var skitchVC: SkitchVC!
    var calendarVC: CalendarVC!
    var selectedVC: UIViewController!
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        ToolbarView.shared.show(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MemoVC {
            vc.setContent(date: (sender as! Date))
        }
    }
    @IBAction func backToGameVC(_ segue: UIStoryboardSegue) {
        if let _ = segue.destination as? MemoVC {
            //
        }
    }
    @IBAction func onClickSeg(_ sender: UISegmentedControl) {
        if self.selectedIndex != control.selectedSegmentIndex || selectedVC == nil {
            self.selectedIndex = control.selectedSegmentIndex
            
            self.selectedVC?.removeFromParent()
            self.selectedVC?.view.removeFromSuperview()
            
            let type: SegmentedControlType = SegmentedControlType.init(rawValue: selectedIndex)!
            switch type {
            case .calculator:
                self.selectedVC = self.calculatorVC
            case .skitch:
                self.selectedVC = self.skitchVC
            case .calendar:
                self.selectedVC = self.calendarVC
            }
            self.addChild(selectedVC)
            self.viewContainer.setFixedView(selectedVC.view)
            selectedVC.didMove(toParent: self)
        }
    }
}
// MARK: - SetupUI
extension GameVC {
    func initView() {
        self.bottomSpace.constant = Size.bottomSpace + (UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero).bottom
        self.control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
        confiAllVC()
    }
    private func confiAllVC() {
        self.calculatorVC = CalculatorVC()
        self.skitchVC = SkitchVC()
        self.calendarVC = CalendarVC()
        self.calendarVC.setDelegate(self)
        onClickSeg(self.control)
    }
}
// MARK: - CalendarVCDelegate
extension GameVC: CalendarVCDelegate {
    func toMemo(sender: Date) {
        self.performSegue(withIdentifier: "memo", sender: sender)
    }
}
