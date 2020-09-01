//
//  SetBirthDayVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import IQKeyboardManagerSwift

class SetBirthDayVC: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lbHint: UILabel!
    @IBOutlet weak var btnWhy: UIButton!
    
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var viewHaveAccount: UIView!
    @IBOutlet weak var btnNext: UIButton!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    private var pickerView: UIPickerView!
    private var PickerViewIsShowing = true
    private let firstYear = 1900
    private var birthday = ""
    private var yearlist: [String] {
        var list = [String]()
        (0...200).forEach { (i) in
            list.append("\(firstYear + i)年")
        }
        return list
    }
    private var monthlist: [String] {
        var list = [String]()
        (1...12).forEach { (i) in
            list.append("\(i)月")
        }
        return list
    }
    private var daylist: [String] {
        var list = [String]()
        (1...31).forEach { (i) in
            list.append("\(i)日")
        }
        return list
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.birthday = self.nav.birthday
        initView()
        subscribe()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.nav.birthday.isEmpty {
            self.tfBirthday.becomeFirstResponder()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nav.setLoginInfo(birthday: self.birthday)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    @IBAction func didClickBtnWhy(_ sender: UIButton) {
        let vc = DescriptionVC()
        vc.setContent(title: "生日", content: "提供生日資料有助於確保你獲得符合年齡的適當app體驗。你可於稍後選擇誰能看到此內容？如需更多資訊，請瀏覽資料政策。", image: UIImage(named: ImageInfo.description)!)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    @IBAction func didClickBtnNext(_ sender: Any) {
        toNextPage()
    }
}
// MARK: - SetupUI
extension SetBirthDayVC {
    private func initView() {
        self.lbHint.isHidden = !self.birthday.isEmpty
        self.btnWhy.isHidden = !self.birthday.isEmpty
        self.btnNext.layer.cornerRadius = LoginManager.shared.commonCornerRadius
        
        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
        confiPickerView()
        confiTextfield()
    }
    private func confiPickerView() {
        self.pickerView = UIPickerView()
        self.pickerView.frame.size = CGSize(width: self.view.bounds.width, height: UIScreen.main.bounds.height - self.stackView.frame.maxY - self.pickerView.keyboardToolbar.frame.height - 50)
        self.pickerView.delegate = self
        
        var row_year = 0
        var row_month = 0
        var row_day = 0
        
        if self.nav.birthday != "" {
            self.birthday = self.nav.birthday
            self.tfBirthday.text = self.birthday
            let dateFormmater = DateFormatter()
            dateFormmater.dateFormat = "yyyy年MM月dd日"
            if let date = dateFormmater.date(from: self.birthday) {
                row_year = date.year - self.firstYear
                row_month = date.month.number - 1
                row_day = date.day - 1
            }
        } else {
            row_year = Date.today.year - self.firstYear
            row_month = Date.today.month.number - 1
            row_day = Date.today.day - 1
        }
        self.pickerView.selectRow(row_year, inComponent: 0, animated: false)
        self.pickerView.selectRow(row_month, inComponent: 1, animated: false)
        self.pickerView.selectRow(row_day, inComponent: 2, animated: false)
    }
    private func confiTextfield() {
        self.tfBirthday.inputView = self.pickerView
        let imageView = UIImageView(image: UIImage(named: ImageInfo.arrow_open))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView()
        view.addSubview(imageView)
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.widthAnchor.constraint(equalToConstant: self.tfBirthday.bounds.width / 12).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageView.bounds.height / 2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageView.bounds.height / 2).isActive = true
        self.tfBirthday.rightView = view
        self.tfBirthday.rightViewMode = .always
        self.tfBirthday.tintColor = .clear
        self.tfBirthday.addRightButtonOnKeyboardWithText("繼續", target: self, action: #selector(toNextPage))
    }
    @objc private func toNextPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetSexVC") as? SetSexVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - SubscribeRX
extension SetBirthDayVC {
    private func subscribe() {
        self.tfBirthday.rx.controlEvent([.editingDidBegin]).asObservable().subscribe(onNext: { (_) in
            self.btnNext.isHidden = true
            self.lbHint.isHidden = false
            self.btnWhy.isHidden = false
            
            self.PickerViewIsShowing = true
        }).disposed(by: self.disposeBag)
        self.tfBirthday.rx.controlEvent([.editingDidEnd]).asObservable().subscribe(onNext: { (_) in
            self.btnNext.isHidden = false
            self.lbHint.isHidden = true
            self.btnWhy.isHidden = true
            self.PickerViewIsShowing = false
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - UIPickerViewDelegate
extension SetBirthDayVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows: Int
        
        switch component {
        case 0:
            numberOfRows = self.yearlist.count
        case 1:
            numberOfRows = self.monthlist.count
        default:
            numberOfRows = self.daylist.count
        }
        return numberOfRows
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var titleForRow: String
        
        switch component {
        case 0:
            titleForRow = "\(self.yearlist[row])"
        case 1:
            titleForRow = "\(self.monthlist[row])"
        default:
            titleForRow = "\(self.daylist[row])"
        }
        return titleForRow
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tfBirthday.text = self.yearlist[pickerView.selectedRow(inComponent: 0)] + self.monthlist[pickerView.selectedRow(inComponent: 1)] + self.daylist[pickerView.selectedRow(inComponent: 2)]
        self.birthday = self.tfBirthday.text ?? ""
    }
}
