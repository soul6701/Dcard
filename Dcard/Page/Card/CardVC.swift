//
//  CatalogVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import UIKit
import RxCocoa
import RxSwift
import FSPagerView

protocol CardVCDelegate {
    func addFriend(card: Card)
}

class CardVC: UIViewController {
    
    @IBOutlet weak var viewHint: UIView!
    @IBOutlet weak var imageAngel: UIImageView!
    @IBOutlet weak var heightCardView: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var lbHint: UILabel!
    @IBOutlet weak var viewRelative: UIView!
    @IBOutlet weak var widthContainerView: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewCard: UIView!
    private lazy var pageView: FSPagerView = {
        let view = FSPagerView()
        view.dataSource = self
        view.delegate = self
        return view
    }()
    private lazy var selectedCardView: UIView = {
        return UIView()
    }()
    private var itemSize: CGFloat {
        return self.viewCard.bounds.width / 6
    }
    private lazy var copyView = UIView()
    private var viewModel: CardVMInterface!
    private let disposeBag = DisposeBag()
    private var mode: CardMode = CardMode(rawValue: ModelSingleton.shared.userConfig.cardmode)! {
        didSet {
            self.viewModel.getRandomCardBySex(cardMode: self.mode)
        }
    }
    private var cards: [Card] = ModelSingleton.shared.card {
        didSet {
            self.pageView.reloadData()
        }
    }
    private var card = Card()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        subscribe()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.7834974315)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        ToolbarView.shared.show(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.imageAngel.isHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.pageView.frame = self.viewCard.frame
    }
}
// MARK: - SubscribeViewModel
extension CardVC {
    private func subscribe() {
        self.viewModel = CardVM()
        
        self.viewModel.getRandomCardBySexSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            self.cards = result.data
            self.pageView.reloadData()
        }, onError: { (error) in
            CardManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        if self.cards.isEmpty {
            self.viewModel.getRandomCardBySex(cardMode: self.mode)
        }
        self.viewModel.addFriendSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            CardManager.shared.showOKView(mode: .becomeFriend) {
                let vc = ChatRoomVC()
                vc.setContent(mail: Mail(card: self.card, message: [Message](), isNew: true))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }, onError: { (error) in
            CardManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - SetupUI
extension CardVC {
    private func initView() {
        self.heightCardView.constant = self.view.bounds.height / 6
        self.bottomSpace.constant = Size.bottomSpace + 10
        self.widthContainerView.constant = self.view.bounds.width - 10
        self.viewCard.layer.cornerRadius = 15
        self.containerView.layer.cornerRadius = 15
        self.containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewHint.layer.cornerRadius = 15
        self.viewHint.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        confiNav()
        confiPageView()
    }
    private func confiNav() {
        self.navigationItem.title = "抽卡"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "篩選", style: .plain, target: self, action: #selector(didClickSetting)), animated: true)
    }
    @objc private func didClickSetting() {
        CardManager.shared.showFilterView(in: self) { (cardMode) in
            self.pageView.isScrollEnabled = true
            self.imageAngel.isHidden = false
            self.imageAngel.loadGif(name: "小天使")
            self.viewModel.getRandomCardBySex(cardMode: cardMode)
        }
    }
    private func confiPageView() {
        self.pageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.pageView.itemSize = CGSize(width: itemSize, height: itemSize)
        self.pageView.transformer = .init(type: .ferrisWheel)
        self.pageView.isInfinite = true
        self.pageView.decelerationDistance = 5
        self.view.addSubview(self.pageView)
    }
    private func startAnimation(snapView: UIView) {
        self.selectedCardView.bounds.size = CGSize(width: itemSize, height: itemSize)
        self.selectedCardView.center = viewCard.center
        makeShadow(self.selectedCardView)
        self.selectedCardView.setFixedView(snapView)
        self.view.addSubview(selectedCardView)
        UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.selectedCardView.center.y -= 30
        }.startAnimation()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toCenter(_:)))
        self.selectedCardView.addGestureRecognizer(tap)
    }
    @objc private func toCenter(_ tap: UITapGestureRecognizer) {
        guard let view = tap.view else {
            return
        }
        self.copyView.frame = view.frame
        self.copyView.setFixedView(view)
        self.view.insertSubview(self.copyView, belowSubview: self.imageAngel)
        
        let animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            self.copyView.center = self.view.convert(self.containerView.center, from: self.viewRelative)
        }
        animator.addCompletion { (position) in
            if position == .end {
                let _animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
                    let heightScale = (self.containerView.bounds.height - 20) / self.copyView.bounds.height
                    let widthScale = (self.containerView.bounds.width - 20) / self.copyView.bounds.width
                    self.copyView.bounds = CGRect(x: 0, y: 0, width: self.copyView.bounds.width * widthScale, height: self.copyView.bounds.height * heightScale)
                self.copyView.layer.masksToBounds = true
                }
                _animator.addCompletion { (position) in
                    if position == .end {
                        let card = self.cards[self.pageView.currentIndex]
                        let imageView = UIImageView()
                        imageView.kf.setImage(with: URL(string: card.photo))
                        imageView.contentMode = .scaleAspectFit
                        self.card = card
                        UIView.transition(with: self.copyView, duration: 0.5, options: [.transitionFlipFromRight, .repeat], animations: nil, completion: { complete in
                            view.removeFromSuperview()
                            self.copyView.setFixedView(imageView)
                            self.lbHint.text = card.name
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.toNextPage))
                            self.copyView.addGestureRecognizer(tap)
                            
                        })
                        let delayTime = DispatchTime.now() + 0.5 * 4
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.copyView.layer.removeAllAnimations()
                        }
                    }
                }
                _animator.startAnimation()
            }
        }
        animator.startAnimation()
    }
    private func makeShadow(_ view: UIView) {
        view.layer.shadowOpacity = 0.8
        view.layer.shadowColor = UIColor.red.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    @objc private func toNextPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CardInfoVC") as? CardInfoVC {
            vc.setContent(card: self.card, isUser: false, isFriend: false)
            vc.setDelegate(self)
            self.navigationController?.pushViewController(vc, animated: true) {
                vc.navigationItem.setHidesBackButton(false, animated: false)
                vc.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
}
// MARK: - FSPagerViewDelegate
extension CardVC: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.cards.count
    }
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: ImageInfo.dogCard)!
        cell.backgroundColor = .clear
        makeShadow(cell)
        return cell
    }
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if let selectedCell = pagerView.cellForItem(at: pagerView.currentIndex) {
            guard let snapView = selectedCell.imageView?.snapshotView(afterScreenUpdates: true) else {
                return
            }
            startAnimation(snapView: snapView)
            selectedCell.imageView?.image = nil
            pagerView.isScrollEnabled = false
        }
    }
}
// MARK: - CardVCDelegate
extension CardVC: CardVCDelegate {
    func addFriend(card: Card) {
        self.viewModel.addFriend(card: card)
    }
}
