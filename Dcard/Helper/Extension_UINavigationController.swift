//
//  File.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    //navigationBar透明與不透明
    func transparentNavigationBar() {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
    func opaqueNavigationBar() {
        self.navigationBar.shadowImage = nil
        self.navigationBar.setBackgroundImage(nil, for: .default)
    }
}
//    static private var coordinatorHelperKey = "UINavigationController.TransitionCoordinatorHelper"
//
//    var transitionCoordinatorHelper: TransitionCoordinator? {
//        return objc_getAssociatedObject(self, &UINavigationController.coordinatorHelperKey) as? TransitionCoordinator
//    }
//
//    func addCustomTransitioning() {
//        var object = objc_getAssociatedObject(self, &UINavigationController.coordinatorHelperKey)
//
//        guard object == nil else {
//            return
//        }
//
//        object = TransitionCoordinator()
//        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
//        objc_setAssociatedObject(self, &UINavigationController.coordinatorHelperKey, object, nonatomic)
//
//        delegate = object as? TransitionCoordinator
//
//
//        let edgeSwipeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        edgeSwipeGestureRecognizer.edges = .left
//        view.addGestureRecognizer(edgeSwipeGestureRecognizer)
//    }
//
//    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
//        guard let gestureRecognizerView = gestureRecognizer.view else {
//            transitionCoordinatorHelper?.interactionController = nil
//            return
//        }
//
//        let percent = gestureRecognizer.translation(in: gestureRecognizerView).x / gestureRecognizerView.bounds.size.width
//
//        if gestureRecognizer.state == .began {
//            transitionCoordinatorHelper?.interactionController = UIPercentDrivenInteractiveTransition()
//            popViewController(animated: true)
//        } else if gestureRecognizer.state == .changed {
//            transitionCoordinatorHelper?.interactionController?.update(percent)
//        } else if gestureRecognizer.state == .ended {
//            if percent > 0.5 && gestureRecognizer.state != .cancelled {
//                transitionCoordinatorHelper?.interactionController?.finish()
//            } else {
//                transitionCoordinatorHelper?.interactionController?.cancel()
//            }
//            transitionCoordinatorHelper?.interactionController = nil
//        }
//    }

// MARK: - TransitionAnimator
//final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
//    // 1
//    let presenting: Bool
//
//    // 2
//    init(presenting: Bool) {
//        self.presenting = presenting
//    }
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        // 3
//        return TimeInterval(UINavigationController.hideShowBarDuration)
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        // 4
//        guard let fromView = transitionContext.view(forKey: .from) else { return }
//        guard let toView = transitionContext.view(forKey: .to) else { return }
//
//        // 5
//        let duration = transitionDuration(using: transitionContext)
//
//        // 6
//        let container = transitionContext.containerView
//        if presenting {
//            container.addSubview(toView)
//        } else {
//            container.insertSubview(toView, belowSubview: fromView)
//        }
//
//        // 7
//        let toViewFrame = toView.frame
//        toView.frame = CGRect(x: presenting ? toView.frame.width : -toView.frame.width, y: toView.frame.origin.y, width: toView.frame.width, height: toView.frame.height)
//
//        let animations = {
//            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
//                toView.alpha = 1
//                if self.presenting {
//                    fromView.alpha = 0
//                }
//            }
//
//            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1) {
//                toView.frame = toViewFrame
//                fromView.frame = CGRect(x: self.presenting ? -fromView.frame.width : fromView.frame.width, y: fromView.frame.origin.y, width: fromView.frame.width, height: fromView.frame.height)
//                if !self.presenting {
//                    fromView.alpha = 0
//                }
//            }
//
//        }
//
//        UIView.animateKeyframes(withDuration: duration,
//                                delay: 0,
//                                options: .calculationModeCubic,
//                                animations: animations,
//                                completion: { finished in
//                                    // 8
//                                    container.addSubview(toView)
//                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
//    }
//}

// MARK: - TransitionCoordinator
//final class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
//    // 1
//    var interactionController: UIPercentDrivenInteractiveTransition?
//
//    // 2
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        switch operation {
//        case .push:
//            return TransitionAnimator(presenting: true)
//        case .pop:
//            return TransitionAnimator(presenting: false)
//        default:
//            return nil
//        }
//    }
//
//    // 3
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactionController
//    }
//}
