//
//  PostSettingCell.swift
//  Dcard
//
//  Created by Mason on 2020/11/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class PostSettingCell: UITableViewCell {
    
    lazy private var lbTitle: UILabel = UILabel()
    lazy private var imageViewCatalog: UIImageView = self.confiImageViewCatalog()
    
    override func layoutSubviews() {
        self.backgroundColor = .clear
        self.addSubview(self.imageViewCatalog)
        self.imageViewCatalog.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(40)
            maker.width.height.equalTo(40)
            maker.centerY.equalToSuperview()
        }
        self.addSubview(self.lbTitle)
        self.lbTitle.snp.makeConstraints { (maker) in
            maker.leading.equalTo(self.imageViewCatalog.snp.trailing).offset(30)
            maker.height.equalTo(self.imageViewCatalog.snp.height)
            maker.centerY.equalToSuperview()
        }
    }
    func setContent(isSystemImage: Bool, image: String, title: String) {
        if isSystemImage {
            self.imageViewCatalog.image = UIImage(systemName: image)!
        } else {
            self.imageViewCatalog.kf.setImage(with: URL(string: image))
        }
        self.lbTitle.text = title
    }
}
// MARK: - SetupUI
extension PostSettingCell {
    private func confiImageViewCatalog() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }
}
