//
//  PopUpAnimator.swift
//  Ellomix
//
//  Created by Kevin Avila on 1/27/18.
//  Copyright © 2018 Akshay Vyas. All rights reserved.
//

import UIKit

class PopUpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let popUpPlayerView = presenting ? toView : transitionContext.view(forKey: .from)!

        let initialFrame = presenting ? originFrame : popUpPlayerView.frame
        let finalFrame = presenting ? popUpPlayerView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height

        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)

        if (presenting) {
            popUpPlayerView.transform = scaleTransform
            popUpPlayerView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            popUpPlayerView.clipsToBounds = true
        }

        containerView.addSubview(toView)
        containerView.bringSubview(toFront: popUpPlayerView)
        
        UIView.animate(withDuration: duration, delay:0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: {
            popUpPlayerView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            popUpPlayerView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: { _ in
            if (!self.presenting) {
                self.dismissCompletion?()
            }
            transitionContext.completeTransition(true)
        })
    }

}
