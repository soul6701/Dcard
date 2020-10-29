//
//  CardInfoTitleCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/6.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

class CardInfoTitleCell: UITableViewCell {

    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var photoBG: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var lbSex: UILabel!
    @IBOutlet weak var lbSchool: UILabel!
    private var _photo: UIImage?
    private lazy var context: CIContext = {
        return CIContext(options: nil)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewBorder.layer.cornerRadius = 12
        self.photo.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setContent(card: Card, isUser: Bool) {
        self.photo.kf.setImage(with: URL(string: card.photo))
        self._photo = self.photo.image
        self.lbSex.text = isUser ? card.name : card.sex == "男性" ? "男同學" : "女同學"
        self.lbSchool.text = card.school + " " + card.department
        setGaussianBlur()
    }
    
    //製作背景模糊頭貼
    private func setGaussianBlur() {
        let image = self._photo ?? UIImage()
        //獲取原始圖片
        let inputImage =  CIImage(image: image)
        //使用高斯模糊濾鏡
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(inputImage, forKey:kCIInputImageKey)
        //設置模糊半徑值（越大越模糊）
        filter.setValue(80, forKey: kCIInputRadiusKey)
        
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        if let output = filter.outputImage {
            let cgImage = context.createCGImage(output, from: rect)
            //顯示生成的模糊圖片
            self.photoBG.image = UIImage(cgImage: cgImage!)
        }
    }
}
