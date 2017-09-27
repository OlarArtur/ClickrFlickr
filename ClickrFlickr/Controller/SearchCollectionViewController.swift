//
//  SearchCollectionViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class SearchCollectionViewController: UICollectionViewController {
    

    @IBOutlet weak var tagsForSeachTextField: UITextField!
    
    var tags: String = ""
    var arrayPhotosData = [[String: String]]()
    
    @IBAction func searthBarButtomItem(_ sender: UIBarButtonItem) {
        guard let text = tagsForSeachTextField.text?.replacingOccurrences(of: " ", with: "+") else {
            tags = ""
            return
        }
        tags = text
        show(tags: tags)
        tagsForSeachTextField.text = ""
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        show(tags: tags)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPhotosData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        guard let title = arrayPhotosData[indexPath.row]["title"] else {return cell}
        
        cell.titlePhoto.text = title
        
        guard let farm = arrayPhotosData[indexPath.row]["farm"] else {return cell}
        
        guard let server = arrayPhotosData[indexPath.row]["server"] else {return cell}
        
        guard let id = arrayPhotosData[indexPath.row]["id"] else {return cell }
        
        guard let secret = arrayPhotosData[indexPath.row]["secret"] else {return cell}
        
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        
        let customImageView = CustomImageView()
        customImageView.loadImageUsingUrlString(urlString: url) { (image) in
            cell.photo.image = image
        }
        
        return cell
    }
    
    func getPhotoData(string: String, completion: @escaping ([[String: String]]) -> ()) {
        let fetchJSON = FetchJSON()
        fetchJSON.jsonToSerchPhoto(stringUrl: string) { (result) in
            guard let result = result else {return}
            completion(result)
        }
    }
    
    func show(tags: String) {
        DispatchQueue.global().async {
            guard let string = CallingFlickrAPIwithOauth.getResponseApi(oauthTags: tags) else {return}
    
            self.getPhotoData(string: string, completion: {(arrayPhotoData) in
                self.arrayPhotosData = arrayPhotoData
    
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }
    }
    
}


