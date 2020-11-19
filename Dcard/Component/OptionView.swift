//
//  OptionView.swift
//  Dcard
//
//  Created by Mason on 2020/11/19.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SwiftMessages
import SnapKit

protocol OptionViewDelegate {
    func didClickAt(_ mode: OptionView.Mode, indexPath: IndexPath)
}
class OptionView: UIView {
    enum Mode {
        case editPost
        case editFavorite
        
        var dataList: [[CellData]] {
            switch self {
            case .editFavorite:
                return [[OptionView.CellData(systemImageString: "trash", rowName: "移除收藏分類"), OptionView.CellData(systemImageString: "pencil", rowName: "重新命名")]]
            case .editPost:
                return [[OptionView.CellData(systemImageString: "square.and.arrow.up", rowName: "分享"), OptionView.CellData(systemImageString: "arrow.uturn.up.circle", rowName: "轉貼到其他看板"), OptionView.CellData(systemImageString: "arrow.swap", rowName: "引用原文發文"), OptionView.CellData(systemImageString: "exclamationmark.circle.fill", rowName: "檢舉文章")]]
            }
        }
    }
    struct CellData {
        var systemImageString: String
        var rowName: String
    }
    static private var _shared: OptionView?
    static var shared: OptionView {
        if _shared == nil {
            _shared = OptionView()
            return _shared!
        }
        return _shared!
    }
    private var viewBG: UIView!
    private var tableView: UITableView!
    private var delegate: OptionViewDelegate?
    private var topConstraint: Constraint?
    private var shouldupdateConstraint: Bool = true
    private var mode: Mode = .editFavorite
    
    private var height: CGFloat {
        var height: CGFloat = 0
        for i in 0...self.mode.dataList.count - 1 {
            height += CGFloat(self.mode.dataList[i].count * 50)
        }
        return max(height, 200)
    }
    private lazy var showAnimaor: UIViewPropertyAnimator = {
        self.topConstraint?.update(offset: -self.height)
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.layoutIfNeeded()
        }
        return animator
    }()
    private lazy var hideAnimaor: UIViewPropertyAnimator = {
        self.topConstraint?.update(offset: 0)
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.layoutIfNeeded()
        }
        animator.addCompletion { (position) in
            if position == .end {
                self.reset()
            }
        }
        return animator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.viewBG = UIView()
        self.viewBG.backgroundColor = .black
        self.viewBG.alpha = 0.6
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hide))
        self.viewBG.addGestureRecognizer(tap)
        
        self.tableView = UITableView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 15
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.shouldupdateConstraint {
            self.setFixedView(self.viewBG)
            self.addSubview(self.tableView)
            self.tableView.snp.makeConstraints { (maker) in
                self.topConstraint = maker.top.equalTo(self.snp.bottom).constraint
                maker.leading.trailing.equalToSuperview()
                maker.height.equalTo(self.height)
            }
            self.shouldupdateConstraint = false
        }
    }
    func configure(_ delegate: OptionViewDelegate, mode: Mode) {
        self.delegate = delegate
        self.mode = mode
    }
    func show() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.setFixedView(self)
        DispatchQueue.main.async {
            self.showAnimaor.startAnimation()
        }
    }
    @objc private func hide() {
        DispatchQueue.main.async {
            self.hideAnimaor.startAnimation()
        }
    }
    private func reset() {
        self.removeFromSuperview()
        OptionView._shared = nil
    }
}
// MARK: - UITableViewDelegate
extension OptionView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.mode.dataList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mode.dataList[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let data = self.mode.dataList[section][row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .blue
        cell.textLabel?.text = data.rowName
        cell.imageView?.tintColor = .systemGray2
        cell.imageView?.image = UIImage(systemName: data.systemImageString)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didClickAt(self.mode, indexPath: indexPath)
        hide()
    }
}
