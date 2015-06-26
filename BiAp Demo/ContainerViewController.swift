//
//  ContainerViewController.swift
//  SlideOutNavigation
//
//  Created by James Frost on 03/08/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
  case BothCollapsed
  case LeftPanelExpanded
  case RightPanelExpanded
}

class ContainerViewController: UIViewController {
  
  var centerViewController: CenterViewController!
  
  var currentState: SlideOutState = .BothCollapsed {
    didSet {
      let shouldShowShadow = currentState != .BothCollapsed
      showShadowForCenterViewController(shouldShowShadow)
    }
  }
  
  var leftViewController: SidePanelViewController?
  var rightViewController: SidePanelViewController?

  let centerPanelExpandedOffset: CGFloat = 60
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    centerViewController = UIStoryboard.centerViewController()
    centerViewController.delegate = self
    
    // wrap the centerViewController in a navigation controller, so we can push views to it
    // and display bar button items in the navigation bar

    view.addSubview(centerViewController.view)
    
    centerViewController.didMoveToParentViewController(self)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
    panGestureRecognizer.minimumNumberOfTouches = 4
    centerViewController.view.addGestureRecognizer(panGestureRecognizer)
  }
  
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate {

  func toggleLeftPanel() {
    let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
    
    if notAlreadyExpanded {
//      addLeftPanelViewController()
    }
    
//    animateLeftPanel(shouldExpand: notAlreadyExpanded)
  }
  
  func toggleRightPanel() {
    let notAlreadyExpanded = (currentState != .RightPanelExpanded)
    
    if notAlreadyExpanded {
      addRightPanelViewController()
    }
    
    animateRightPanel(shouldExpand: notAlreadyExpanded)
  }
  
  func collapseSidePanels() {
    switch (currentState) {
    case .RightPanelExpanded:
      toggleRightPanel()
//    case .LeftPanelExpanded:
//      toggleLeftPanel()
    default:
      break
    }
  }
  
  func addLeftPanelViewController() {
    if (leftViewController == nil) {
      leftViewController = UIStoryboard.leftViewController()
      
//      addChildSidePanelController(leftViewController!)
    }
  }
  
  func addChildSidePanelController(sidePanelController: SidePanelViewController) {
    
    view.insertSubview(sidePanelController.view, atIndex: 0)
    
    addChildViewController(sidePanelController)
    sidePanelController.didMoveToParentViewController(self)
  }
  
  func addRightPanelViewController() {
    if (rightViewController == nil) {
      rightViewController = UIStoryboard.rightViewController()

      
        addChildSidePanelController(rightViewController!)
        centerViewController.backButton.alpha = 1
    }
  }
  
  func animateLeftPanel(#shouldExpand: Bool) {
//    if (shouldExpand) {
//      currentState = .LeftPanelExpanded
//      
//      animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerViewController.view.frame) - centerPanelExpandedOffset)
//    } else {
//      animateCenterPanelXPosition(targetPosition: 0) { finished in
//        self.currentState = .BothCollapsed
//        
//        self.leftViewController!.view.removeFromSuperview()
//        self.leftViewController = nil;
//      }
//    }
  }
  
  func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
      self.centerViewController.view.frame.origin.x = targetPosition
      }, completion: completion)
  }
  
  func animateRightPanel(#shouldExpand: Bool) {
    if (shouldExpand) {
      currentState = .RightPanelExpanded
      
        animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerViewController.view.frame) + centerPanelExpandedOffset)
        
        centerViewController.backButton.alpha = 1
    } else {
      animateCenterPanelXPosition(targetPosition: 0) { _ in
        self.currentState = .BothCollapsed
        
        self.rightViewController!.view.removeFromSuperview()
        self.rightViewController = nil;
        
        }
        centerViewController.backButton.alpha = 0
    }
  }
  
  func showShadowForCenterViewController(shouldShowShadow: Bool) {
    if (shouldShowShadow) {
      centerViewController.view.layer.shadowOpacity = 0.8
    } else {
      centerViewController.view.layer.shadowOpacity = 0.0
    }
  }
  
}

extension ContainerViewController: UIGestureRecognizerDelegate {
  // MARK: Gesture recognizer
  
  func handlePanGesture(recognizer: UIPanGestureRecognizer) {
    let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
    if !gestureIsDraggingFromLeftToRight{
        switch(recognizer.state) {
        case .Began:
          if (currentState == .BothCollapsed) {
            if (gestureIsDraggingFromLeftToRight) {
    //          addLeftPanelViewController()
            } else {
              addRightPanelViewController()
            }
            
            showShadowForCenterViewController(true)
          }
        case .Changed:
          recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
          recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
          if (leftViewController != nil) {
            // animate the side panel open or closed based on whether the view has moved more or less than halfway
            let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
    //        animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
          } else if (rightViewController != nil) {
            let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
            animateRightPanel(shouldExpand: hasMovedGreaterThanHalfway)
          }
        default:
          break
        }
    }
  }
}

private extension UIStoryboard {
  class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
  
  class func leftViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
  }
  
  class func rightViewController() -> SidePanelViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? SidePanelViewController
  }
  
  class func centerViewController() -> CenterViewController? {
    return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
  }
  
}