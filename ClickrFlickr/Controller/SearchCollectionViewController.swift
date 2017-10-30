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
    var photo = [Photo]()
    
    @IBAction func searthBarButtomItem(_ sender: UIBarButtonItem) {
        
        tagsForSeachTextField.autocorrectionType = .no
        guard let text = tagsForSeachTextField.text?.replacingOccurrences(of: " ", with: "+") else {
            tags = ""
            return
        }
        tags = text
        loadPhotoFor(tags: tags)
        tagsForSeachTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPhotoFor(tags: tags)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.titlePhoto.text = photo[indexPath.row].title
        
        let customImageView = CustomImageView()
        customImageView.loadImageUsingUrlString(urlString: photo[indexPath.row].url) { (image) in
            cell.photo.image = image
        }
        
        return cell
    }
    
    func getPhotoData(string: String) {
        let fetchJSON = FetchJSON()
        fetchJSON.getSerchPhotos(stringUrl: string) { (result) in
            guard let result = result else {return}
            self.photo = result
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    func loadPhotoFor(tags: String) {
        DispatchQueue.global().async {
            guard let string = CallingFlickrAPIwithOauth.getResponseApi(oauthTags: tags) else {return}
            self.getPhotoData(string: string)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let cell = sender as? UICollectionViewCell, let indexPath = self.collectionView?.indexPath(for: cell) {
                let detailVC = segue.destination as! SearchDetailViewController
                detailVC.photo = self.photo[indexPath.row]
            }
        }
    }
    
}


