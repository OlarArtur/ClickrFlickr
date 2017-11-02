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
    
    var textForSearch: String = ""
    var photo = [Photo]()
    
    let itemsPerRow: CGFloat = 2
    
    @IBAction func searthBarButtomItem(_ sender: UIBarButtonItem) {
        
        tagsForSeachTextField.autocorrectionType = .no
        guard let text = tagsForSeachTextField.text?.replacingOccurrences(of: " ", with: "+") else {
            textForSearch = ""
            return
        }
        textForSearch = text
        loadPhotoFor(searchText: textForSearch)
        tagsForSeachTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPhotoFor(searchText: textForSearch)
    }
    
    func loadPhotoFor(searchText: String) {
        guard let string = CallingFlickrAPIwithOauth.methodPhotosSearch(oauthText: searchText) else {return}
        
        let fetchJSON = FetchJSON()
        fetchJSON.getSerchPhotos(stringUrl: string) { (result) in
            guard let result = result else {return}
            self.photo = result
            
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        cell.spinnerActivityIndicator.startAnimating()
        
        let customImageView = CustomImageView()
        customImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) { (image) in
            
            self.photo[indexPath.item].width = image.size.width
            self.photo[indexPath.item].height = image.size.height
            self.photo[indexPath.item].image = image
            
            DispatchQueue.main.async {
                collectionView.collectionViewLayout.invalidateLayout()
                cell.configure(with: self.photo[indexPath.item])
                cell.spinnerActivityIndicator.stopAnimating()
                cell.spinnerActivityIndicator.isHidden = true
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let cell = sender as? UICollectionViewCell, let indexPath = self.collectionView?.indexPath(for: cell) {
                let detailVC = segue.destination as! SearchDetailViewController
                detailVC.photo = self.photo[indexPath.item]
            }
        }
    }
    
}

extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - (CGFloat(itemsPerRow + 1.0) * 5.0)) / CGFloat(itemsPerRow) - 1
        guard let imageWidth = photo[indexPath.item].width, let imageHeight = photo[indexPath.item].height else {
            let height = width
            return CGSize(width: width, height: height)
        }
        let square = imageHeight/imageWidth
        let height = width * square
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}


