//
//  Functions.swift
//  OSS-IOS-Common
//
//  Created by Ricol Wang on 18/11/17.
//  Copyright © 2017 Opensimsim. All rights reserved.
//

import Foundation

public typealias Block = () -> ()

@objc public class Functions: NSObject
{
    @objc static public func isIphone() -> Bool
    {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    @objc static public func generateUUID() -> String
    {
        if #available(iOS 9.0, *)
        {
            return UUID.init().uuidString.localizedLowercase
        } else
        {
            return ""
        }
    }
    
    static public func parseSeconds(totalSeconds: Int, hour: inout Int, minute: inout Int, second: inout Int)
    {
        var total = totalSeconds
        hour = total / 3600
        total = total - hour * 3600
        minute = total / 60
        second = total - minute * 60
    }
    
    static public func parseSecondsToDay(totalSeconds: Int, day: inout Int, hour: inout Int, minute: inout Int, second: inout Int)
    {
        var total = totalSeconds
        day = total / (24 * 3600)
        total = total - day * 24 * 3600
        hour = total / 3600
        total = total - hour * 3600
        minute = total / 60
        second = total - minute * 60
    }
    
    @objc static public func getRandomRect(_ max: Int) -> CGRect
    {
        let x = Int(arc4random()) % max
        let y = Int(arc4random()) % max
        let w = Int(arc4random()) % max
        let h = Int(arc4random()) % max
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    @objc static public func toJson(from object: Any) -> String
    {
        if let objectData = try? JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions(rawValue: 0))
        {
            let objectString = String(data: objectData, encoding: .utf8)
            return objectString ?? ""
        }
        
        return ""
    }
    
    @objc static public func getDocument() -> String
    {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        return docsDir
    }
    
}
