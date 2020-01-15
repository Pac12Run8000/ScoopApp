//
//  ImageService.swift
//  ScoopApp
//
//  Created by Michelle Grover on 1/15/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit



class ImageService {
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func downloadAndCacheImage(withUrl:URL, completionHandler:@escaping(_ success:Bool, _ image:UIImage?,_ error:Error?) -> ()) {
        
        if let image = cache.object(forKey: withUrl.absoluteString as NSString) {
            completionHandler(true, image, nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: withUrl) { (data, response, error) in
            var downloadedImage:UIImage?
            guard let data = data else {
                print("Data is not available.")
                completionHandler(false, nil, nil)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data) {
                    cache.setObject(downloadedImage, forKey: withUrl.absoluteString as NSString)
                    completionHandler(true, downloadedImage, nil)
                }
            }
        }
        dataTask.resume()
    }
}

//class ImageService {
//
//    static let cache = NSCache<NSString, UIImage>()
//
//    static func downloadAndCacheImage(withUrl:URL, completionHandler:@escaping(_ success:Bool, _ image:UIImage?, _ error:Error?) -> ()) {
//
//        if let image = cache.object(forKey: withUrl.absoluteString as NSString) {
//            completionHandler(true, image, nil)
//            return
//        }
//
//
//        let dataTask = URLSession.shared.dataTask(with: withUrl) { (data, response, error) in
//
//            var downloadedImage:UIImage?
//
//            guard let data = data else {
//                print("Data is not available.")
//                completionHandler(false, nil, nil)
//                return
//            }
//
//            DispatchQueue.main.async {
//
//                if let downloadedImage = UIImage(data: data) {
//                    cache.setObject(downloadedImage, forKey: withUrl.absoluteString as NSString)
//                    completionHandler(true, downloadedImage, nil)
//                }
//            }
//
//        }
//        dataTask.resume()
//
//    }
//
//
//}
