//
//  ViewController.swift
//  TransitionAnimation
//
//  Created by Miwand Najafe on 2019-08-24.
//  Copyright © 2019 Miwand Najafe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var viewForTransition: UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = .orange
    }
    
    @IBAction func showSecondVC() {
        let secondVC = SecondViewController()
        secondVC.transitioningDelegate = self
        secondVC.modalTransitionStyle = .crossDissolve
        present(secondVC, animated: true, completion: nil)
    }
    
    lazy var animator = {
        Animator(isPresenting: true)
    }()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        animator.originFrame = viewForTransition.superview!.convert(viewForTransition.frame, to: nil)
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        animator.originFrame = viewForTransition.superview!.convert(viewForTransition.frame, to: dismissed.view)
        return animator
    }
}

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMe(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissMe(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
            let viewForTransition = isPresenting ? toView : transitionContext.view(forKey: .from) else
        {
            return
        }
        
        let initialFrame = isPresenting ? originFrame : toView.frame
        let finalFrame = isPresenting ? toView.frame : originFrame
        
        let xScale = isPresenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScale = isPresenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        
        let scaleFactor = CGAffineTransform(scaleX: xScale, y: yScale)
        
        if isPresenting {
            guard let snapShot = toView.snapshotView(afterScreenUpdates: true) else {
                return
            }
            snapShotView = snapShot
            presentedOrientation = UIDevice.current.orientation
            viewForTransition.transform = scaleFactor
            viewForTransition.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
        }
        

        if (self.presentedOrientation.isPortrait && !UIDevice.current.orientation.isPortrait) || (self.presentedOrientation.isLandscape && !UIDevice.current.orientation.isLandscape)  {
            toView.frame = CGRect(x: 0, y: 0, width: snapShotView.frame.height, height: snapShotView.frame.width)
        }
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.bringSubviewToFront(viewForTransition)
        
        UIView.animate(withDuration: 1.0, animations: {
            viewForTransition.transform = self.isPresenting ? .identity : scaleFactor
            viewForTransition.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            viewForTransition.alpha = self.isPresenting ? 1.0 : 0
        }) { _ in
            transitionContext.completeTransition(true)
        }

    }
    
    var isPresenting: Bool
    var originFrame: CGRect = .zero
    var isDifferentOrientation: Bool = true
    var presentedOrientation: UIDeviceOrientation = .portrait
    var snapShotView: UIView = UIView()
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
}
