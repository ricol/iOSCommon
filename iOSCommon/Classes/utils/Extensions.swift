//
//  Extensions.swift
//  OSS-IOS-Common
//
//  Created by Ricol Wang on 1/11/17.
//  Copyright © 2017 Opensimsim. All rights reserved.
//

import Foundation

public typealias BlockWithValue = (String) -> ()

extension UIColor
{
    @objc static public func randomColor() -> UIColor
    {
        return UIColor(red: CGFloat(Int(arc4random()) % 255) / 255.0, green: CGFloat(Int(arc4random()) % 255) / 255.0, blue: CGFloat(Int(arc4random()) % 255) / 255.0, alpha: 1)
    }
    
    @objc public func lighter(by percentage: CGFloat = 30.0) -> UIColor?
    {
        return adjust(by: abs(percentage))
    }
    
    @objc public func darker(by percentage: CGFloat = 30.0) -> UIColor?
    {
        return adjust(by: -1 * abs(percentage))
    }
    
    @objc public func adjust(by percentage: CGFloat = 30.0) -> UIColor?
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
    
    public func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    public func expected_height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public func expected_width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSString
{
    @objc public func trim() -> NSString
    {
        return (self as String).trim() as NSString
    }
    
    @objc public func expected_height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        return (self as String).expected_height(withConstrainedWidth: width, font: font)
    }
    
    @objc public func expected_width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat
    {
        return (self as String).expected_width(withConstrainedHeight: height, font: font)
    }
}

extension UIView
{
    // MARK: - View Style
    
    @objc public func roundCorners(corners: UIRectCorner, radius: CGFloat)
    {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    @objc public func roundCornersForRadius(radius: CGFloat)
    {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    @objc public func roundCorners()
    {
        self.roundCornersForRadius(radius: self.frame.size.height / 2.0)
    }
    
    // MARK: - Random Color For all Subviews for testing purpose
    
    @objc public func randomColor()
    {
        backgroundColor = UIColor.randomColor()
        
        for view in subviews
        {
            view.randomColor()
        }
    }
    
    @objc public func clearBGColor()
    {
        backgroundColor = UIColor.clear
        
        for v in subviews
        {
            v.clearBGColor()
        }
    }
    
    @objc public func clearText()
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
    
    @objc public func removeAllSubviews()
    {
        for v in subviews
        {
            v.removeFromSuperview()
        }
    }
    
    @objc public func getAllSubViews() -> [UIView]
    {
        var views = [UIView]()
        
        views += self.subviews
        
        for v in self.subviews
        {
            views += v.getAllSubViews()
        }
        
        return views
    }
    
    @objc public func getExpectHeightForKeyboardOverlap(keyboardFrame: CGRect) -> CGFloat
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
            static let key = "ViewRotate"
        }
        
        struct Shake
        {
            static let key = "shake"
        }
    }
    
    @objc public func startRotate(_ fun: Block? = nil)
    {
        self.startRotate(2, fun)
    }
    
    @objc public func startRotate(_ atspeed: Double = 4, _ fun: Block? = nil)
    {
        if self.layer.animation(forKey: Animation.Rotate.key) != nil { return }
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        let degree = Double.pi * 2.0
        rotateAnimation.toValue = degree
        rotateAnimation.duration = degree / atspeed
        rotateAnimation.repeatCount = 1000
        
        self.layer.add(rotateAnimation, forKey: Animation.Rotate.key)
        if let theFun = fun
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                theFun()
            }
        }
    }
    
    @objc public func stopRotate(_ fun: Block? = nil)
    {
        if self.layer.animation(forKey: Animation.Rotate.key) == nil { return }
        
        self.layer.removeAnimation(forKey: Animation.Rotate.key)
        
        if let theFun = fun
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                theFun()
            }
        }
    }
    
    @objc public func toggleRotate(startRotate: Block?, endRotate: Block?)
    {
        self.layer.animation(forKey: Animation.Rotate.key) == nil ? self.startRotate(2, startRotate) : self.stopRotate(endRotate)
    }
    
    @objc public func shake()
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.8
        animation.values = [-20.0, 20.0, -20.0, 20.0, -15.0, 15,0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: Animation.Shake.key)
    }
    
    // MARK: - Capture Output as an Image
    
    @objc public func toImage() -> UIImage?
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
    
    @objc public func clearConstraints()
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
    @objc public func getKeyboardRect() -> CGRect
    {
        if let userInfo = self.userInfo, let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
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
    @objc public func pop(animated: Bool)
    {
        _ = popViewController(animated: animated)
    }
    
    @objc public func popToRoot(animated: Bool)
    {
        _ = popToRootViewController(animated: animated)
    }
    
    @objc public func popAndThenPush(vc: UIViewController, animated: Bool, count: Int = 1)
    {
        var navVCs = viewControllers
        var i = 0
        while i < count
        {
            navVCs.removeLast()
            i += 1
        }
        setViewControllers(navVCs, animated: false)
        pushViewController(vc, animated: animated)
    }
    
    @objc public func popToRootAndThenPush(vc: UIViewController, animated: Bool)
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
    @objc public func length() -> Int { return 0 }
    @objc public func count() -> Int { return 0 }
    
    @objc public func integerValue() -> Int { return 0 }
    
    @objc public func floatValue() -> Float { return 0 }
    
    @objc open override var description: String { return "0(NSNull)" }
    
    @objc public func componentsSeparatedByString(separator _: String) -> [AnyObject] { return [AnyObject]() }
    
    @objc public func objectForKey(key _: AnyObject) -> AnyObject? { return nil }
    @objc public func enumerateKeysAndObjectsUsingBlock(_: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {}
    @objc public func enumerateKeysAndObjects(_: (Any, Any, UnsafeMutablePointer<ObjCBool>) -> Void) {}
    @objc public func boolValue() -> Bool { return false }
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
    @objc public func zeroSeconds() -> NSDate
    {
        let d = self as Date
        return d.zeroSeconds() as NSDate
    }
}

extension NSLayoutConstraint
{
    @objc static public func fullScreenConstraint(view: UIView, parent: UIView, margin: CGFloat, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        let TopConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: margin)
        
        let BottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -margin)
        
        let LeftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: margin)
        
        let RightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: -margin)
        
        let constraints = [TopConstraint, BottomConstraint, LeftConstraint, RightConstraint]
        if auto_add
        {
            parent.addConstraints(constraints)
        }
        return constraints
    }
    
    @objc static public  func fullScreenConstraint(view: UIView, parent: UIView, margin: CGFloat, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: margin, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    @objc static public func fullScreenConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: 0, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    @objc static public func fullScreenConstraint(view: UIView, parent: UIView, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.fullScreenConstraint(view: view, parent: parent, margin: 0, translatesAutoresizingMaskIntoConstraints: translatesAutoresizingMaskIntoConstraints, auto_add)
    }
    
    @objc static public func centreConstraint(view: UIView, parent: UIView, translatesAutoresizingMaskIntoConstraints: Bool, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        
        let horizontalConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: view.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height)
        
        let constraints = [horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint]
        if auto_add
        {
            parent.addConstraints(constraints)
        }
        return constraints
    }
    
    @objc static public func centreConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        return NSLayoutConstraint.centreConstraint(view: view, parent: parent, translatesAutoresizingMaskIntoConstraints: false, auto_add)
    }
    
    @objc static public func normalConstraint(view: UIView, parent: UIView, _ auto_add: Bool = true) -> [NSLayoutConstraint]
    {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: view.frame.origin.x)
        let top = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: parent, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: view.frame.origin.y)
        let widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: view.frame.size.width)
        let heightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: view.frame.size.height)
        
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
    @objc static public func getVC(vc: String, from storyBoard: String) -> UIViewController
    {
        return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: vc)
    }
    
    @objc public func getVC(vc: String) -> UIViewController
    {
        return instantiateViewController(withIdentifier: vc)
    }
}

extension UIImage
{
    @objc public func resizeImage(targetSize: CGSize) -> UIImage
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
    
    @objc public func croppedImage(rect: CGRect) -> UIImage?
    {
        guard let cgimage = self.cgImage else { return nil }
        
        if let imageRef = cgimage.cropping(to: rect)
        {
            let result = UIImage(cgImage: imageRef, scale: 1.0, orientation: self.imageOrientation)
            return result
        }
        return nil
    }
    
    @objc public func cropImage(rect: CGRect) -> UIImage?
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
    
    @objc public func imageWithBackground(_ color: UIColor) -> UIImage?
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
    
    @objc public func imageWithTintcolor(_ color: UIColor) -> UIImage?
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
    
    @objc public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1))
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
    @objc public func imageFromLayer() -> UIImage?
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
    @objc public var releaseVersionNumber: String
    {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }
    
    @objc public var buildVersionNumber: String
    {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? ""
    }
}

func areEqual (_ left: Any, _ right: Any) -> Bool
{
    if  type(of: left) == type(of: right) &&
        String(describing: left) == String(describing: right) { return true }
    if let left = left as? [Any], let right = right as? [Any] { return left == right }
    if let left = left as? [AnyHashable: Any], let right = right as? [AnyHashable: Any] { return left == right }
    return false
}

extension Array where Element: Any
{
    public static func == (left: [Element], right: [Element]) -> Bool
    {
        if left.count != right.count { return false }
        for (index, leftValue) in left.enumerated()
        {
            guard areEqual(leftValue, right[index]) else { return false }
        }
        return true
    }
    
    public static func != (left: [Element], right: [Element]) -> Bool
    {
        return !(left == right)
    }
}
extension Dictionary where Value: Any
{
    public static func == (left: [Key : Value], right: [Key : Value]) -> Bool
    {
        if left.count != right.count { return false }
        for element in left
        {
            guard   let rightValue = right[element.key],
                areEqual(rightValue, element.value) else { return false }
        }
        return true
    }
    
    public static func != (left: [Key : Value], right: [Key : Value]) -> Bool
    {
        return !(left == right)
    }
}

extension NSArray
{
    @objc public func compare(array: NSArray) -> Bool
    {
        return (self as Array) == (array as Array)
    }
}

extension NSDictionary
{
    @objc public func compare(dictionary: NSDictionary) -> Bool
    {
        return (self as Dictionary) == (dictionary as Dictionary)
    }
}

extension UIViewController
{
    @objc public func popup(msg: String, title: String, complete: Block? = nil)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            complete?()
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc public func confirm(msg: String, title: String, confirm: Block? = nil)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            confirm?()
        }
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc public func input(msg: String, title: String, complete: @escaping BlockWithValue)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addTextField { (tf) in
            
        }
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            if let text = alert.textFields?.first?.text
            {
                complete(text)
            }
        }
        let cancel = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
