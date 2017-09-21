//
//  SearchCollectionViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

//    https://farm\(farm!).staticflickr.com/\(server!)/\(id!)_\(secret!).jpg

extension SearchCollectionViewController: AuthorizedViewControllerDelegate {
    
    func fillPhotoData(photoData: Data) {
        
        DispatchQueue.global().async{
            self.getPhotosdata(data: photoData, completion: { (arrayPhotosData) in
                self.arrayPhotosData = arrayPhotosData as! [[String : String]]
                
                DispatchQueue.main.async{
                    self.collectionView?.reloadData()
                }
            })
        }
    }
}



class SearchCollectionViewController: UICollectionViewController {
    
    var arrayPhotosData = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthorizedViewController.delegate = self
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrayPhotosData.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
         DispatchQueue.global().async {
    
            guard let title = self.arrayPhotosData[indexPath.row]["title"] else {return}
            
            DispatchQueue.main.async {
                cell.titlePhoto.text = title
            }
        
            guard let farm = self.arrayPhotosData[indexPath.row]["farm"] else {return}
        
            guard let server = self.arrayPhotosData[indexPath.row]["server"] else {return}
        
            guard let id = self.arrayPhotosData[indexPath.row]["id"] else {return}
        
            guard let secret = self.arrayPhotosData[indexPath.row]["secret"] else {return}
    
            let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")
            let data = try? Data(contentsOf: url!)
                
            if let imageData = data {
                DispatchQueue.main.async {
                    cell.photo.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    
    func getPhotosdata (data: Data, completion: @escaping ([[String : Any]]) -> ()) {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            if let photos = jsonData["photos"] as? [String : Any] {
                
                if let photo = photos["photo"] as? [[String : Any]] {
                    
                    for arrayValue in photo {
                        
                        var helpDict: [String: String] = [:]
                        
                        for (key, value) in arrayValue {
                            switch key {
                            case "title", "owner", "server", "id", "secret", "farm":
                                let valueStr = String(describing: value)
                                helpDict[key] = valueStr
                            default:
                                break
                            }
                        }
                        arrayPhotosData.append(helpDict)
                    }
                }
            }
        } catch {
            print("Some ERROR JSONSerialization")
        }
//        print(arrayPhotosData)
        completion(arrayPhotosData)
    }

    
    
}
