//
//  Extensions.swift
//  OSS-IOS-Common
//
//  Created by Ricol Wang on 1/11/17.
//  Copyright © 2017 Opensimsim. All rights reserved.
//

import Foundation

extension UIColor
{
    static public func randomColor() -> UIColor
    {
        return UIColor(red: CGFloat(Int(arc4random()) % 255), green: CGFloat(Int(arc4random()) % 255), blue: CGFloat(Int(arc4random()) % 255), alpha: 1)
    }
    
    public func lighter(by percentage: CGFloat = 30.0) -> UIColor?
    {
        return adjust(by: abs(percentage))
    }
    
    public func darker(by percentage: CGFloat = 30.0) -> UIColor?
    {
        return adjust(by: -1 * abs(percentage))
    }
    
    public func adjust(by percentage: CGFloat = 30.0) -> UIColor?
    {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a)
        {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        }
        else
        {
            return nil
        }
    }
}

extension CGRect
{
    public func show()
    {
        print("x: \(self.minX), y: \(self.minY), w: \(self.width), h: \(self.height)")
    }
}

extension CGSize
{
    public func show()
    {
        print("w: \(self.width), h: \(self.height)")
    }
}

extension String
{
    public subscript(i: Int) -> String
    {
        guard i >= 0 && i < count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    // To check text field or String is blank or not
    public var isBlank: Bool
    {
        let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmed.isEmpty
    }
    
    // Validate Email
    public var isEmail: Bool
    {
        do
        {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, count)) != nil
        }
        catch
        {
            return false
        }
    }
}

extension UIView
{
    // MARK: - View Style
    
    public func roundCorners(corners: UIRectCorner, radius: CGFloat)
    {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    public func roundCornersForRadius(radius: CGFloat)
    {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    public func roundCorners()
    {
        self.roundCornersForRadius(radius: self.frame.size.height / 2.0)
    }
    
    // MARK: - Random Color For all Subviews for testing purpose
    
    public func randomColor()
    {
        backgroundColor = UIColor.randomColor()
        
        for view in subviews
        {
            view.randomColor()
        }
    }
    
    public func clearBGColor()
    {
        backgroundColor = UIColor.clear
        
        for v in subviews
        {
            v.clearBGColor()
        }
    }
    
    public func clearText()
    {
        if let lbl = self as? UILabel
        {
            lbl.text = ""
        }else if let tf = self as? UITextField
        {
            tf.text = ""
        }else if let tv = self as? UITextView
        {
            tv.text = ""
        }else
        {
            for v in self.subviews
            {
                v.clearText()
            }
        }
    }
    
    // MARK: - Remove all subviews
    
    public func removeAllSubviews()
    {
        for v in subviews
        {
            v.removeFromSuperview()
        }
    }
    
    public func getAllSubViews() -> [UIView]
    {
        var views = [UIView]()
        
        views += self.subviews
        
        for v in self.subviews
        {
            views += v.getAllSubViews()
        }
        
        return views
    }
    
    public func getExpectHeightForKeyboardOverlap(keyboardFrame: CGRect) -> CGFloat
    {
        if let superView = self.superview, let window = UIApplication.shared.keyWindow
        {
            let rect = superView.convert(frame, to: window)
            let keyboardFrameInWindow = window.convert(keyboardFrame, to: window)
            let height = rect.origin.y + rect.size.height - keyboardFrameInWindow.origin.y
            if height > 0 { return height }
        }
        return 0
    }
    
    // MARK: - Animate Shadow
    
    struct Animation
    {
        static let value = 0.3
        
        struct Rotate
        {
            static var isAnimating = false
            static let key = "ViewRotate"
        }
        
        struct Shake
        {
            static let key = "shake"
        }
    }
    
    private func stopRotating()
    {
        self.layer.removeAnimation(forKey: Animation.Rotate.key)
    }
    
    public func startRotate(_ fun: Block? = nil)
    {
        self.startRotate(2, fun)
    }
    
    public func startRotate(_ atspeed: Double = 2, _ fun: Block? = nil)
    {
        if Animation.Rotate.isAnimating { return }
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        let degree = Double.pi * 2.0 * 100000
        rotateAnimation.toValue = degree
        rotateAnimation.duration = degree / atspeed
        
        self.layer.add(rotateAnimation, forKey: Animation.Rotate.key)
        
        Animation.Rotate.isAnimating = true
        
        if let theFun = fun
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                theFun()
            }
        }
    }
    
    public func stopRotate(_ fun: Block? = nil)
    {
        if !Animation.Rotate.isAnimating { return }
        
        self.stopRotating()
        Animation.Rotate.isAnimating = false
        
        if let theFun = fun
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                theFun()
            }
        }
    }
    
    public func toggleRotate(startRotate: Block?, endRotate: Block?)
    {
        !Animation.Rotate.isAnimating ? self.startRotate(2, startRotate) : self.stopRotate(endRotate)
    }
    
    public func shake()
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.8
        animation.values = [-20.0, 20.0, -20.0, 20.0, -15.0, 15,0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: Animation.Shake.key)
    }
    
    // MARK: - Capture Output as an Image
    
    public func toImage() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        if let context = UIGraphicsGetCurrentContext()
        {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
    
    public func clearConstraints()
    {
        for subview in self.subviews
        {
            subview.clearConstraints()
        }
        
        self.removeConstraints(self.constraints)
    }
}

extension NSNotification
{
    public func getKeyboardRect() -> CGRect
    {
        if let userInfo = self.userInfo, let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            return keyboardRect
        }
        else
        {
            return CGRect.zero
        }
    }
}

extension UINavigationController
{
    public func pop(animated: Bool)
    {
        _ = popViewController(animated: animated)
    }
    
    public func popToRoot(animated: Bool)
    {
        _ = popToRootViewController(animated: animated)
    }
    
    public func popAndThenPush(vc: UIViewController, animated: Bool, count: Int = 1)
    {
        var navVCs = viewControllers
        var i = 0
        while i < count
        {
            navVCs.removeLast()
            i += 1
        }
        navVCs.append(vc)
        setViewControllers(navVCs, animated: animated)
    }
    
    public func popToRootAndThenPush(vc: UIViewController, animated: Bool)
    {
        if let first = viewControllers.first
        {
            var vcs = [UIViewController]()
            vcs.append(first)
            vcs.append(vc)
            setViewControllers(vcs, animated: animated)
        }
    }
}

extension Array where Element: Equatable
{
    // Remove first collection element that is equal to the given `object`:
    public mutating func remove(object: Element)
    {
        if let index = index(of: object)
        {
            remove(at: index)
        }
    }
}

extension NSNull
{
    public func length() -> Int { return 0 }
    public func count() -> Int { return 0 }
    
    public func integerValue() -> Int { return 0 }
    
    public func floatValue() -> Float { return 0 }
    
    open override var description: String { return "0(NSNull)" }
    
    public func componentsSeparatedByString(separator _: String) -> [AnyObject] { return [AnyObject]() }
    
    public func objectForKey(key _: AnyObject) -> AnyObject? { return nil }
    public func enumerateKeysAndObjectsUsingBlock(_: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {}
    public func enumerateKeysAndObjects(_: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {}
    public func boolValue() -> Bool { return false }
}

extension Date
{
    public func zeroSeconds() -> Date
    {
        let timeInterval = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
}

extension NSDate
{
    public func zeroSeconds() -> NSDate
    {
        let d = self as Date
        return d.zeroSeconds() as NSDate
    }
}

extension NSLayoutConstraint
{
    static public func fullScreenConstraint(view: UIView, parent: UIView, margin: CGFloat, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        let TopConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.top, multiplier: 1, constant: margin)
        
        let BottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -margin)
        
        let LeftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.left, multiplier: 1, constant: margin)
        
        let RightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -margin)
        
        let constraints = [TopConstraint, BottomConstraint, LeftConstraint, RightConstraint]
        if auto_add
        {
            parent.addConstraints(constraints)
        }
        return constraints
    }
    
    static public  func fullScreenConstraint(view: UIView, parent: UIView, margin: CGFloat, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: margin, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    static public func fullScreenConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: 0, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    static public func fullScreenConstraint(view: UIView, parent: UIView, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: 0, translatesAutoresizingMaskIntoConstraints: translatesAutoresizingMaskIntoConstraints, auto_add)
    }
    
    static public func centreConstraint(view: UIView, parent: UIView, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        let horizontalConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height)
        
        let constraints = [horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint]
        if auto_add
        {
            parent.addConstraints(constraints)
        }
        return constraints
    }
    
    static public func centreConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.centreConstraint(view: view, parent: parent, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    static public func normalConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: view.frame.origin.x)
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.top, multiplier: 1, constant: view.frame.origin.y)
        let widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height)
        
        let constraints = [leading, top, widthConstraint, heightConstraint]
        if auto_add
        {
            parent.addConstraints(constraints)
        }
        return constraints
    }
}

extension UIStoryboard
{
    static public func getVC(vc: String, from storyBoard: String) -> UIViewController
    {
        return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: vc)
    }
    
    public func getVC(vc: String) -> UIViewController
    {
        return instantiateViewController(withIdentifier: vc)
    }
}

extension UIImage
{
    public func resizeImage(targetSize: CGSize) -> UIImage
    {
        let image = self
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio)
        {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else
        {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func croppedImage(rect: CGRect) -> UIImage?
    {
        guard let cgimage = self.cgImage else { return nil }
        
        if let imageRef = cgimage.cropping(to: rect)
        {
            let result = UIImage(cgImage: imageRef, scale: 1.0, orientation: self.imageOrientation)
            return result
        }
        return nil
    }
    
    public func cropImage(rect: CGRect) -> UIImage?
    {
        UIGraphicsBeginImageContext(rect.size)
        
        if let context = UIGraphicsGetCurrentContext()
        {
            let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: self.size.width, height: self.size.height)
            context.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
            self.draw(in: drawRect)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func imageWithBackground(_ color: UIColor) -> UIImage?
    {
        UIGraphicsBeginImageContext(self.size)
        
        if let context = UIGraphicsGetCurrentContext(), let cgimage = self.cgImage
        {
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            color.setFill()
            context.fill(rect)
            
            context.draw(cgimage, in: rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func imageWithTintcolor(_ color: UIColor) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext()
        {
            color.setFill()
            
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            context.setBlendMode(CGBlendMode.colorBurn)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context.draw(self.cgImage!, in: rect)
            
            context.setBlendMode(CGBlendMode.sourceIn)
            context.addRect(rect)
            context.drawPath(using: CGPathDrawingMode.fill)
        }
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1))
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension CALayer
{
    public func imageFromLayer() -> UIImage?
    {
        UIGraphicsBeginImageContext(self.frame.size)
        if let context = UIGraphicsGetCurrentContext()
        {
            self.render(in: context)
            let outputImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return outputImage
        }
        return nil
    }
}

extension DispatchQueue
{
    public func runAfter(milliseconds: Int, _ fun: @escaping Block)
    {
        self.asyncAfter(deadline: DispatchTime.now() + .milliseconds(milliseconds), execute: {
            fun()
        })
    }
    
    public func runAfter(seconds: Int, _ fun: @escaping Block)
    {
        self.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds), execute: {
            fun()
        })
    }
}

extension Bundle
{
    public var releaseVersionNumber: String
    {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    public var buildVersionNumber: String
    {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? ""
    }
}
