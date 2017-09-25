//
//  IntegratedSocialFeed Helpers.swift
//  ADSSocialFeedScrollView
//
//  Created by Jason Pan on 15/02/2016.
//  Copyright © 2016 ANT Development Studios. All rights reserved.
//

import UIKit
import Haneke

let DEVICE_SCREEN_SIZE: CGSize = UIScreen.mainScreen().bounds.size
let DEVICE_SCREEN_WIDTH: CGFloat = UIScreen.mainScreen().bounds.size.width
let DEVICE_SCREEN_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.size.height

func verifyConnectionWithSuccessHandler(successHandler: (() -> Void)?) {
    successHandler?()
}

//internal let ellipsis: String = " …"
internal let ellipsis: String = "… more"

extension NSString {
    
    
    
    func stringByTruncatingToSize(size: CGSize, withFont font: UIFont) -> NSString {
        var size = size
        
        var truncatedString: NSMutableString = self.mutableCopy() as! NSMutableString
        var truncatedPlus: NSMutableString = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
        
        size.width -= 16.0;
        let bigBox: CGSize = CGSizeMake(size.width, CGFloat.max);
        
        if self.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height {
//            var range: NSRange = NSMakeRange(truncatedString.length - 1, 1)
            
            
            
            while truncatedPlus.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > size.height {
                
                var words = truncatedString.componentsSeparatedByString(" ")
                words.removeLast()
                truncatedString = NSMutableString(string: words.joinWithSeparator(" "))
                
                truncatedPlus = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
            }
//            range = NSMakeRange(truncatedString.length - 1, 1)
            truncatedString.appendString(ellipsis)
        }
        return truncatedString;
    }
    
    
    
    
    
//    func stringByTruncatingToSize(size: CGSize, withFont font: UIFont) -> NSString {
//        var size = size
//        
//        let truncatedString: NSMutableString = self.mutableCopy() as! NSMutableString
//        var truncatedPlus: NSMutableString = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
//        
//        size.width -= 16.0;
//        let bigBox: CGSize = CGSizeMake(size.width, CGFloat.max);
//        
//        if self.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height {
//            var range: NSRange = NSMakeRange(truncatedString.length - 1, 1)
//            
////            var currentWordRange = truncatedString.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
////            var nextWordRange = truncatedString.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, currentWordRange.location))
//////            var nextWordLocation = (truncatedString.rangeOfString(" ") as NSRange).location
//////            if nextWordLocation == NSNotFound {
//////                nextWordLocation = 0
//////            }
////            
////            if currentWordRange.location == NSNotFound || currentWordRange.location > truncatedString.length {
////                currentWordRange = NSMakeRange(truncatedString.length - 1, 1)
////            }
////            
//////            var range: NSRange = NSMakeRange(nextWordLocation, truncatedString.length - nextWordLocation)
//////            var range: NSRange = NSMakeRange(0, nextWordLocation)
////            var range: NSRange = NSMakeRange(currentWordRange.location, truncatedString.length - currentWordRange.location - 1)
//            
//            while truncatedPlus.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > size.height {
//                
//                
//                
//                
//                var currentWordRange = truncatedString.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
//                currentWordRange.location += 1
////                currentWordRange.length += 1
////                if currentWordRange.location == NSNotFound || currentWordRange.location >= truncatedString.length || currentWordRange.location + currentWordRange.length >= truncatedString.length {
////                    currentWordRange = NSMakeRange(truncatedString.length - 1, 1)
////                }
//                
//                var range: NSRange = NSMakeRange(currentWordRange.location, truncatedString.length - currentWordRange.location)
////                print(range)
////                print(truncatedString.length)
//                
//                
//                truncatedString.deleteCharactersInRange(range)
//                truncatedPlus = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
////                range.location--
//            }
//            range = NSMakeRange(truncatedString.length - 1, 1)
//            truncatedString.replaceCharactersInRange(range, withString: ellipsis)
//        }
//        return truncatedString;
//    }
    
    
    
    
    
    
    
//    func stringByTruncatingToSize(size: CGSize, withFont font: UIFont) -> NSString {
//        var size = size
//        
//        let truncatedString: NSMutableString = self.mutableCopy() as! NSMutableString
////        let theMore: String = " More .."
//        var truncatedPlus: NSMutableString = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
//        
//        // someone told me “UITextView has 8px of padding on each side” (because it inherits from UIScrollView?)
//        size.width -= 16.0;
//        let bigBox: CGSize = CGSizeMake(size.width, CGFloat.max);
//        
//        if self.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > self.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height {
//            var range: NSRange = NSMakeRange(truncatedString.length - 1, 1)
//            
//            while truncatedPlus.boundingRectWithSize(bigBox, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).height > size.height {
//                truncatedString.deleteCharactersInRange(range)
//                truncatedPlus = (truncatedString.stringByAppendingString(ellipsis) as NSString).mutableCopy() as! NSMutableString
//                range.location--
//            }
//            truncatedString.replaceCharactersInRange(range, withString: ellipsis)
//        }
//        return truncatedString;
//    }
//    
//    func stringByTruncatingToWidth(width: CGFloat, withFont font: UIFont) -> NSString {
//        var width = width
//        
//        // Create copy that will be the returned result
//        let truncatedString: NSMutableString = self.mutableCopy() as! NSMutableString
//        
//        // Make sure string is longer than requested width
//        if self.sizeWithAttributes([NSFontAttributeName : font]).width > width {
//            // Accommodate for ellipsis we'll tack on the end
//            width -= ellipsis.sizeWithAttributes([NSFontAttributeName : font]).width
//            
//            // Get range for last character in string
//            var range: NSRange = NSMakeRange(truncatedString.length - 1, 1)
//            
//            // Loop, deleting characters until string fits within width
//            while truncatedString.sizeWithAttributes([NSFontAttributeName : font]).width > width {
//                // Delete character at end
//                truncatedString.deleteCharactersInRange(range)
//                
//                // Move back another character
//                range.location--;
//            }
//            
//            // Append ellipsis
//            truncatedString.replaceCharactersInRange(range, withString: ellipsis as String)
//        }
//        
//        return truncatedString;
//    }
}

// See: https://medium.com/@sorenlind/three-ways-to-enumerate-the-words-in-a-string-using-swift-7da5504f0062#.fmoxzbq8d
extension String {
    func words() -> [String] {
        
//        let range = Range<String.Index>(start: self.startIndex, end: self.endIndex)
        let range = self.startIndex ... self.endIndex   // TODO: Verify equivalency.
        var words = [String]()
        
        self.enumerateSubstringsInRange(range, options: NSStringEnumerationOptions.ByWords) { (substring, _, _, _) -> () in
            if substring != nil {
                words.append(substring!)
            }
        }
        
        return words
    }
}

// See: https://medium.com/@sorenlind/three-ways-to-enumerate-the-words-in-a-string-using-swift-7da5504f0062#.fmoxzbq8d
extension String {
    
    func tokenize() -> [String] {
        let inputRange = CFRangeMake(0, self.utf16.count)
        let flag = UInt(kCFStringTokenizerUnitWord)
        let locale = CFLocaleCopyCurrent()
        let tokenizer = CFStringTokenizerCreate( kCFAllocatorDefault, self, inputRange, flag, locale)
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        var tokens : [String] = []
        
        while tokenType != CFStringTokenizerTokenType.None
        {
            let currentTokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let substring = self.substringWithRange(currentTokenRange)
            tokens.append(substring)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        
        return tokens
    }
    
    func substringWithRange(aRange : CFRange) -> String {
        
        let nsrange = NSMakeRange(aRange.location, aRange.length)
        let substring = (self as NSString).substringWithRange(nsrange)
        return substring
    }
}

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

extension UIImage {
    
//    class func downloadedFromURL(url: NSURL, handler block: ((UIImage) -> Void)?) {
//        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
//            guard
//                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
//                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
//                let data = data where error == nil,
//                let image = UIImage(data: data)
//                else { return }
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                if block != nil { block!(image) }
//            }
//        }).resume()
//    }
    
    func imageWithSize(size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / self.size.width;
        let aspectHeight:CGFloat = size.height / self.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
//        scaledImageRect.size.width = self.size.width * aspectRatio;
//        scaledImageRect.size.height = self.size.height * aspectRatio;
//        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
//        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
//        
//        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = 0
        scaledImageRect.origin.y = 0
        
        UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, false, 0);
        
        self.drawInRect(scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage;
    }
}

extension UIImageView {
    
    func downloadedFrom(link link: String, contentMode mode: UIViewContentMode, handler block: (() -> Void)?) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
//        contentMode = .ScaleAspectFit
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
//            guard
//                let httpURLResponse = response as? NSHTTPURLResponse where httpURLResponse.statusCode == 200,
//                let mimeType = response?.MIMEType where mimeType.hasPrefix("image"),
//                let data = data where error == nil,
//                let image = UIImage(data: data)
//                else { return }
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                self.image = image
//                if block != nil { block!() }
//            }
//        })
//            
//        task.resume()
//        ADSSocialFeed.addTask(task)        
        
//        let cache = Shared.imageCache
//
//        let ADS_Format = Format<UIImage>(name: "original_ratio", diskCapacity: 100 * 1024 * 1024) { image in
        let ADS_Format = Format<UIImage>(name: "ADSSocialFeedScrollView", diskCapacity: 100 * 1024 * 1024) { image in
        
        
            return image
//            return UIImage(data: UIImageJPEGRepresentation(image, 1.0)!, scale: 1)!
            
////            let size = CGSizeMake(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale, UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)
//            let size = UIScreen.mainScreen().bounds.size
//            return image.imageWithSize(size)
        }
//        cache.addFormat(ADS_Format)
        
        
////        self.hnk_setImageFromURL(url)
//        self.hnk_setImageFromURL(url, format: ADS_Format, success: {
//            image in
////            dispatch_async(dispatch_get_main_queue(), {
////                self.image = image.imageWithSize(UIScreen.mainScreen().bounds.size)
////                let size = CGSizeMake(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale, UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)
////                self.image = image.imageWithSize(size)
//                self.image = UIImage(data: UIImageJPEGRepresentation(image, 1.0)!, scale: 1)!
////                self.image = image
//                
//                if url.absoluteString.containsString("instagram") {
////                    print("size: \(image.size) and self.size: \(self.image?.size)")
////                    print("height: \(self.heightFromScreenWidth())")
//                    print("instagram")
////                    self.frame.size.height = self.image!.size.height
//                }
//            
//                block?()
////            })
//            }, failure: {
//                error in
////                dispatch_async(dispatch_get_main_queue(), {
//                    print(error)
//                
//                if url.absoluteString.containsString("instagram") {
//                    //                    print("size: \(image.size) and self.size: \(self.image?.size)")
//                    //                    print("height: \(self.heightFromScreenWidth())")
//                    print("instagram fail")
//                    //                    self.frame.size.height = self.image!.size.height
//                }
//                    block?()
////                })
//        })
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.hnk_setImageFromURL(url, format: ADS_Format, success: {
                image in
                dispatch_async(dispatch_get_main_queue(), {
                    self.image = image
                    block?()
                    
//                    //                self.image = image.imageWithSize(UIScreen.mainScreen().bounds.size)
//                    //                let size = CGSizeMake(UIScreen.mainScreen().bounds.size.width * UIScreen.mainScreen().scale, UIScreen.mainScreen().bounds.size.height * UIScreen.mainScreen().scale)
//                    //                self.image = image.imageWithSize(size)
//                    self.image = UIImage(data: UIImageJPEGRepresentation(image, 1.0)!, scale: 1)!
//                    //                self.image = image
//                    
//                    if url.absoluteString.containsString("instagram") {
//                        //                    print("size: \(image.size) and self.size: \(self.image?.size)")
//                        //                    print("height: \(self.heightFromScreenWidth())")
//                        print("instagram: \(url.absoluteString)")
//                        print("block: \(block)")
//                        //                    self.frame.size.height = self.image!.size.height
//                        block!()
//                    }else {
//                        block?()
//                    }
                    
                })
                }, failure: {
                    error in
                    dispatch_async(dispatch_get_main_queue(), {
//                        print(error)
//                        
//                        if url.absoluteString.containsString("instagram") {
//                            //                    print("size: \(image.size) and self.size: \(self.image?.size)")
//                            //                    print("height: \(self.heightFromScreenWidth())")
//                            print("instagram fail")
//                            //                    self.frame.size.height = self.image!.size.height
//                        }
                        block?()
                    })
            })
        })
        
        
//        self.hnk_setImageFromURL(url, placeholder: nil, format: ADS_Format, failure: nil, success: {
//            image in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                block?()
//            }
//        })
        
//        let completionBlock = { (_: AnyObject?) -> Void in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                block?()
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue()) { () -> Void in
////        self.hnk_setImageFromURL(url, placeholder: nil, format: ADS_Format, failure: completionBlock, success: completionBlock)
//            self.frame.size.width = UIScreen.mainScreen().bounds.width
//            self.frame.size.height = UIScreen.mainScreen().bounds.width
//            self.hnk_setImageFromURL(url, placeholder: nil, format: nil, failure: completionBlock, success: completionBlock)
//        }
        
//        dispatch_async(dispatch_get_main_queue(), {
//            Shared.imageCache.removeAll({
//                print(Shared.imageCache)
//            })
//        })
    }
    
    private func scaleSize(size: CGSize, toSize size_limit: CGSize) -> CGSize
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size_limit.width / size.width;
        let aspectHeight:CGFloat = size_limit.height / size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = size.width * aspectRatio;
        scaledImageRect.size.height = size.height * aspectRatio;
        scaledImageRect.origin.x = (size_limit.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size_limit.height - scaledImageRect.size.height) / 2.0;
        
        return scaledImageRect.size
    }
    
    func heightFromScreenWidth() -> CGFloat {
        if debugColours { self.backgroundColor = UIColor.orangeColor() }
        
        if let image = self.image {
            let size = image.size
            
            //            let ratio = size.width / size.height
            //
            //            if ratio < 1 {
            //                //Image width is smaller than image height
            //
            //                if size.width
            //            }
            
            //            let DEVICE_SCREEN_SIZE: CGSize = self.frame.size//UIScreen.mainScreen().bounds.size;
//            let DEVICE_SCREEN_SIZE: CGSize = UIScreen.mainScreen().bounds.size;
            
            let specialRatio = size.height / size.width
            let newWidth = DEVICE_SCREEN_WIDTH
            let newHeight = newWidth * specialRatio
            
            //            if specialRatio == 1 { print("newHeight: \(newHeight)") }
            
            return newHeight
        }
        return 0
    }
}

extension Array
{
    func containsObject(object: Any) -> Bool
    {
        if let anObject: AnyObject = object as? AnyObject
        {
            for obj in self
            {
                if let anObj: AnyObject = obj as? AnyObject
                {
                    if anObj === anObject { return true }
                }
            }
        }
        return false
    }
}

//*********************************************************************************************************
// MARK: - GET HTTP Requests + JSON Serialization
//*********************************************************************************************************

func JSONObjectWithData(data: NSData) -> AnyObject? {
    do {
        // Convert the JSON data to a dictionary.
        let resultsDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! Dictionary<NSObject, AnyObject>
        
        return resultsDict
        
    } catch {
        print(error)
    }
    return nil
}

func urlWithUrlString(urlString: String) -> NSURL? {
    return NSURL(string: urlString)
}

func addParamToURLString(urlString: String, paramKey: String, paramValue: String) -> String {
    return urlString + "&" + paramKey + "=" + paramValue
}

func addParamToURL(url: NSURL, paramKey: String, paramValue: String) -> NSURL? {
    let targetURL = NSURL(string: url.absoluteString + "&" + paramKey + "=" + paramValue)
    return targetURL
}

func targetURLStringWithBaseURLString(baseURLString: String, RESTEndpoint endPoint: String, apiKey: String) -> String {
    let urlString = baseURLString + "/" + endPoint + "?key=" + apiKey
    return urlString
}

func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
    let request = NSMutableURLRequest(URL: targetURL)
    request.HTTPMethod = "GET"
    
    let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    let session = NSURLSession(configuration: sessionConfiguration)
    
    let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            guard response != nil else {
//                verifyConnectionWithSuccessHandler() {
//                    performGetRequest(targetURL, completion: completion)
//                }
//                return
//            }
//            
//            completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            
            if let httpStatus = response as? NSHTTPURLResponse {
                completion(data: data, HTTPStatusCode: httpStatus.statusCode, error: error)
            }else {
                completion(data: data, HTTPStatusCode: 500, error: error)
            }
//            ADSSocialFeed.removeTask(task)
        })
    })
    
    ADSSocialFeed.addTask(task)
    task.resume()
}

func requestWithHTTPMethod(HTTPMethod: String, apiKey: String?, shouldUseBase64Encoding: Bool, params : Dictionary<String, AnyObject>?, url : String, postCompleted : ((succeeded: Bool, parseJSON: NSDictionary?, dataString: String?) -> ())?) {
    do {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = HTTPMethod
        
        if let params = params {
            if HTTPMethod != "GET" {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(rawValue: 0))
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let apiKey = apiKey {
            let loginString = NSString(format: "%@", apiKey)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            let authorization = shouldUseBase64Encoding ? base64LoginString : apiKey
            request.setValue("Basic \(authorization)", forHTTPHeaderField: "Authorization")
        }
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
//                print("Response: \(response)")
                
                guard data != nil else {
//                    print("Error description: \(error?.description)")
                    if postCompleted != nil { postCompleted!(succeeded: false , parseJSON: nil, dataString: nil) }
                    
                    return
                }
                
                let err: NSError? = nil
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    print(err!.localizedDescription)
//                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                    print("Error could not parse JSON: '\(jsonStr)'")
                    if postCompleted != nil { postCompleted!(succeeded: false, parseJSON: nil, dataString: nil) }
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        let success = true
//                        print("Success: \(success)")
                        if postCompleted != nil { postCompleted!(succeeded: success, parseJSON: parseJSON, dataString: nil) }
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding) as String!
//                        print("Error could not parse JSON: \(jsonStr)")
                        if postCompleted != nil { postCompleted!(succeeded: false, parseJSON: nil, dataString: jsonStr) }
                    }
                }
            }catch {
                let jsonStr: String = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                
                if postCompleted != nil { postCompleted!(succeeded: false, parseJSON: nil, dataString: jsonStr) }
            }
        })
        
        ADSSocialFeed.addTask(task)
        task.resume()
    }catch {}
}

public extension NSObject {
    public class var nameOfClass: String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }
}

////SIDENOTE: see http://stackoverflow.com/a/30141700/699963
//// Mapping from XML/HTML character entity reference to character
//// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
//private let characterEntities : [ String : Character ] = [
//    // XML predefined entities:
//    "&quot;"    : "\"",
//    "&amp;"     : "&",
//    "&apos;"    : "'",
//    "&lt;"      : "<",
//    "&gt;"      : ">",
//    
//    // HTML character entity references:
//    "&nbsp;"    : "\u{00a0}",
//    // ...
//    "&diams;"   : "♦",
//]
//
//extension String {
//    
//    /// Returns a new string made by replacing in the `String`
//    /// all HTML character entity references with the corresponding
//    /// character.
//    var stringByDecodingHTMLEntities : String {
//        
//        // ===== Utility functions =====
//        
//        // Convert the number in the string to the corresponding
//        // Unicode character, e.g.
//        //    decodeNumeric("64", 10)   --> "@"
//        //    decodeNumeric("20ac", 16) --> "€"
//        func decodeNumeric(string : String, base : Int32) -> Character? {
//            let code = UInt32(strtoul(string, nil, base))
//            return Character(UnicodeScalar(code))
//        }
//        
//        // Decode the HTML character entity to the corresponding
//        // Unicode character, return `nil` for invalid input.
//        //     decode("&#64;")    --> "@"
//        //     decode("&#x20ac;") --> "€"
//        //     decode("&lt;")     --> "<"
//        //     decode("&foo;")    --> nil
//        func decode(entity : String) -> Character? {
//            
//            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X"){
//                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(3)), base: 16)
//            } else if entity.hasPrefix("&#") {
//                return decodeNumeric(entity.substringFromIndex(entity.startIndex.advancedBy(2)), base: 10)
//            } else {
//                return characterEntities[entity]
//            }
//        }
//        
//        // ===== Method starts here =====
//        
//        var result = ""
//        var position = startIndex
//        
//        // Find the next '&' and copy the characters preceding it to `result`:
//        while let ampRange = self.rangeOfString("&", range: position ..< endIndex) {
//            result.appendContentsOf(self[position ..< ampRange.startIndex])
//            position = ampRange.startIndex
//            
//            // Find the next ';' and copy everything from '&' to ';' into `entity`
//            if let semiRange = self.rangeOfString(";", range: position ..< endIndex) {
//                let entity = self[position ..< semiRange.endIndex]
//                position = semiRange.endIndex
//                
//                if let decoded = decode(entity) {
//                    // Replace by decoded character:
//                    result.append(decoded)
//                } else {
//                    // Invalid entity, copy verbatim:
//                    result.appendContentsOf(entity)
//                }
//            } else {
//                // No matching ';'.
//                break
//            }
//        }
//        // Copy remaining characters to `result`:
//        result.appendContentsOf(self[position ..< endIndex])
//        return result
//    }
//}
