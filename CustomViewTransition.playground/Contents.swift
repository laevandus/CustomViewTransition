//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

final class CustomTransition: NSObject, CAAnimationDelegate, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        transitionContext.containerView.addSubview(toViewController.view)
        
        if transitionContext.isAnimated {
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            
            let opacity: CABasicAnimation = {
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.duration = transitionDuration(using: transitionContext)
                animation.fromValue = 0.0
                animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                animation.toValue = 1.0
                return animation
            }()
            let rotation: CABasicAnimation = {
                let animation = CABasicAnimation(keyPath: "transform.rotation")
                animation.duration = transitionDuration(using: transitionContext)
                animation.fromValue = 0.0
                animation.toValue = 2.0 * 2.0 * Double.pi
                animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                return animation
            }()
            let scale: CABasicAnimation = {
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.duration = transitionDuration(using: transitionContext)
                animation.fromValue = 0.1
                animation.toValue = 1.0
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                return animation
            }()
            let group: CAAnimationGroup = {
                let group = CAAnimationGroup()
                group.animations = [opacity, rotation, scale]
                group.delegate = self
                group.duration = transitionDuration(using: transitionContext)
                return group
            }()
            self.transitionContext = transitionContext
            toViewController.view.layer.add(group, forKey: "rotateScaleGroup")
        }
        else {
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.completeTransition(true)
        }
    }
    
    private var transitionContext: UIViewControllerContextTransitioning? = nil
    
    func animationDidStop(_ animation: CAAnimation, finished isFinished: Bool) {
        transitionContext?.completeTransition(isFinished)
        transitionContext = nil
    }
}

final class PresentedViewController: UIViewController {
    override func loadView() {
        self.view = {
            let view = UIView()
            view.backgroundColor = .blue
            return view
        }()
    }
}

final class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    override func loadView() {
        self.view = {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }()
        
        let button: UIButton = {
            let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 30)))
            button.addTarget(self, action: #selector(ViewController.showView), for: UIControl.Event.touchUpInside)
            button.setTitle("Present", for: .normal)
            button.setTitleColor(.darkText, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
    @objc func showView() {
        let presentedViewController = PresentedViewController()
        presentedViewController.modalPresentationStyle = .custom
        presentedViewController.transitioningDelegate = self
        present(presentedViewController, animated: true, completion: nil)
    }

    private let transition = CustomTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}

PlaygroundPage.current.liveView = ViewController()
