//
//  ImageLoader.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


@objc class ImageLoader: NSObject {
    
    private static let imageCashe = NSCache<NSString, UIImage>()
    
    private override init() {}
    
    @objc static func loadImageUsingUrlString (urlString: String, completion: @escaping (UIImage?) ->()) {
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        if let imageFromCashe = imageFromCashe(for: urlString) {
            completion(imageFromCashe)
            return
        }
        
        if let imageFromDocument = getImageFromDocumentDirectory(key: urlString) {
            completion(imageFromDocument)
            return
        }
        
        NetworkServise.shared.getData(url: url) { (data, urlForCashe) in
            
            guard let data = data else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                completion(image)
                saveImageToCashe(image: image, for: urlForCashe.absoluteString)
                saveImageToDocumentDirectory(image: image, for: urlForCashe.absoluteString)
            }
        }
        
    }
    
    static func saveImageToCashe(image: UIImage, for url: String) {
        imageCashe.setObject(image, forKey: url as NSString)
    }
    
    static func imageFromCashe(for url: String) -> UIImage? {
        guard let image = imageCashe.object(forKey: url as NSString) else {
            return nil
        }
        return image
    }
    
    static private func saveImageToDocumentDirectory(image: UIImage, for key: String) {
        
        DispatchQueue.global().async {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            guard let data = UIImagePNGRepresentation(image) else {return}
            let modifyKey = key.replacingOccurrences(of: "/", with: "")
            let fileName = paths.appendingPathComponent("image:\(modifyKey)")
            
            do {
                try data.write(to: fileName)
            } catch {
                print("Error write image to document directory: \(error)")
            }
        }
        
    }
    
    static private func getImageFromDocumentDirectory(key: String) -> UIImage? {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        
        let modifyKey = key.replacingOccurrences(of: "/", with: "")
        let fileName = paths.appendingPathComponent("image:\(modifyKey)")
        
        if fileManager.fileExists(atPath: fileName.path) {
            return UIImage(contentsOfFile: fileName.path)
        }
        return nil
        
    }
    
}
