//
//  CalendarVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//


protocol CalendarVCDelegate {
    func toMemo(sender: Date)
}

enum MonthButtonType: Int {
    case right = 0
    case left = 1
}
enum PickerMode: Int {
    case year = 0
    case month = 1
}

import UIKit

class CalendarVC: UIViewController {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var pickerYearMonth: UIPickerView!
    @IBOutlet weak var lbYear: UILabel!
    @IBOutlet var imageYear: [UIImageView]!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet weak var collectionViewDay: UICollectionView!
    
    @IBOutlet weak var height: NSLayoutConstraint!
    private let monthList = Date.monthList
    private var yearList = [Int]()
    private var dayList = [(Date, Bool, Bool)]() //(日期, 紀錄, 是否為該月日期)
    private var mode: PickerMode = .year
    private var date = Date()
    private var delegate: CalendarVCDelegate?
    private let space: CGFloat = 5
    private let collectionPadding: CGFloat = 6
    private var rowSelected = 0
    
    private var itemSize: CGSize {
        let width = floor((Double)(collectionViewDay.bounds.width - space * 6 - collectionPadding * 2) / 7)
        return CGSize(width: width, height: width)
    }
    private var headerSize: CGSize {
        return CGSize(width: self.collectionViewDay.bounds.width, height: self.itemSize.height / 2)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    @IBAction func onClickSetMonth(_ sender: UIButton) {
        let type = MonthButtonType.init(rawValue: sender.tag)
        self.date = type == .right ? self.date.nextDateByMonth : self.date.lastDateByMonth
        setupDayList(from: self.date.FirstDayInMonth, totalOfDay: self.date.totalDayInThisMonth)
        self.lbMonth.text = self.date.month.description
        self.lbYear.text = "\(self.date.year)"
    }
    @IBAction func onClickHidePicker(_ sender: UIButton) {
        self.viewBackground.isHidden = true
    }
    func setDelegate(_ delegate: CalendarVCDelegate) {
        self.delegate = delegate
    }
    func reloadData() {
        self.dayList[self.rowSelected].1 = !self.dayList[self.rowSelected].1
        self.collectionViewDay.reloadItems(at: [IndexPath(row: self.rowSelected, section: 0)])
    }
}
// MARK: - SetupUI
extension CalendarVC {
    
    private func initView() {
        self.height.constant = CGFloat(itemSize.height * 6) + collectionPadding * 2 + space * 5 + itemSize.height / 2
        self.date = Date()
        let thisYear = self.date.year
        for i in (thisYear - 100...thisYear + 100) {
            self.yearList.append(i)
        }
        setupDayList(from: self.date.FirstDayInMonth, totalOfDay: self.date.totalDayInThisMonth)
        self.lbMonth.text = self.date.month.description
        self.lbYear.text = "\(self.date.year)"
            
        self.imageYear.forEach { (imageView) in
            imageView.loadGif(name: "柴犬")
        }
        confiPickerView()
        confiCollectionView()
    }
    
    private func confiPickerView() {
        self.pickerYearMonth.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        self.pickerYearMonth.delegate = self
        self.pickerYearMonth.dataSource = self
        self.confiGesture()
    }
    private func confiGesture() {
        var ges = UITapGestureRecognizer(target: self, action: #selector(showPicker(_:)))
        ges.numberOfTapsRequired = 1
        self.lbMonth.addGestureRecognizer(ges)
        ges = UITapGestureRecognizer(target: self, action: #selector(showPicker(_:)))
        ges.numberOfTapsRequired = 1
        self.lbYear.addGestureRecognizer(ges)
    }
    @objc private func showPicker(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else {
            return
        }
        let type = PickerMode.init(rawValue: view.tag)
        switch type {
        case .month:
            self.mode = .month
        case .year:
            self.mode = .year
        default:
            break
        }

        self.pickerYearMonth.reloadAllComponents()
        self.viewBackground.isHidden = false
        
        let selected = type == .year ? self.yearList.firstIndex(of: self.date.year) ?? 0 : self.monthList.firstIndex(of: self.date.month.description) ?? 0
        self.pickerYearMonth.selectRow(selected, inComponent: 0, animated: false)
    }
    
    private func confiCollectionView() {
        self.collectionViewDay.delegate = self
        self.collectionViewDay.dataSource = self
        self.collectionViewDay.register(UINib(nibName: "DayCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionViewDay.register(UINib(nibName: "WeekHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        let _view = UIView(frame: self.collectionViewDay.frame)
        _view.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        self.collectionViewDay.backgroundView = _view
        setCollectionViewLayout()
    }
    private func setCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: collectionPadding, left: collectionPadding, bottom: collectionPadding, right: collectionPadding)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        self.collectionViewDay.collectionViewLayout = layout
    }
    //common
    private func setupDayList(from firstDate: Date, totalOfDay: Int) {
        self.dayList.removeAll()
        let weekDay = firstDate.weekDay
        var a = 0
        var b = 1 - weekDay
        var c = totalOfDay
        
        var _date: Date
        for i in 1..<43 {
            if i < weekDay {
                _date = Date.calendar.date(byAdding: .day, value: b, to: firstDate)!
                dayList.append((_date, false, false))
                b += 1
            } else if i > weekDay + (totalOfDay - 1) {
                _date = Date.calendar.date(byAdding: .day, value: c, to: firstDate)!
                dayList.append((_date, false, false))
                c += 1
            } else {
                _date = Date.calendar.date(byAdding: .day, value: a, to: firstDate)!
                dayList.append((_date, false, true))
                a += 1
            }
        }
        self.collectionViewDay.reloadData()
    }
}

// MARK:- UICollectionViewDelegate
extension CalendarVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DayCell else {
            return UICollectionViewCell()
        }
        cell.contentView.backgroundColor = .systemPink
        let inMonth = dayList[indexPath.row].2
        cell.setContent(date: dayList[indexPath.row].0, marked: dayList[indexPath.row].1, inMonth: inMonth)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.headerSize
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? WeekHeaderView else {
            return UICollectionReusableView()
        }
        return view
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.rowSelected = indexPath.row
        let daySelected = Int(dayList[(self.rowSelected)].0.day)
        self.delegate?.toMemo(sender: self.date.setDay(daySelected))
    }
}

// MARK:- UIPickerViewDelegate
extension CalendarVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.mode == .year ? self.yearList.count : self.monthList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.mode == .year ? "\(self.yearList[row])" : self.monthList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var distance: Int
        if self.mode == .year {
            distance = self.yearList[row] - self.date.year
            self.date = Date.calendar.date(byAdding: .year, value: distance, to: self.date)!
            self.lbYear.text = "\(self.yearList[row])"
        }
        if self.mode == .month {
            distance = row - (self.date.month.number - 1)
            self.date = Date.calendar.date(byAdding: .month, value: distance, to: self.date)!
            self.lbMonth.text = self.monthList[row]
        }
        setupDayList(from: self.date.FirstDayInMonth, totalOfDay: self.date.totalDayInThisMonth)
        self.viewBackground.isHidden = true
    }
}
