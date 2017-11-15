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
    let imageCache = NSCache<NSString, UIImage>()
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 5
    
    @IBAction func searthBarButtomItem(_ sender: UIBarButtonItem) {
        
        tagsForSeachTextField.autocorrectionType = .no
        guard let text = tagsForSeachTextField.text?.replacingOccurrences(of: " ", with: "+") else {
            textForSearch = ""
            return
        }
        textForSearch = text
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) {[weak self] photo in
            
            guard let strongSelf = self else {return}
            
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
        
        tagsForSeachTextField.text = ""
        imageCache.removeAllObjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.prefetchDataSource = self
        
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) { photo in
            self.photo = photo.searchPhoto
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.spinnerActivityIndicator.startAnimating()
        
        if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
            
            self.photo[indexPath.item].image = imageFromCache
            cell.configure(with: self.photo[indexPath.item])
            
            collectionView.collectionViewLayout.invalidateLayout()
            
            cell.spinnerActivityIndicator.stopAnimating()
            cell.spinnerActivityIndicator.isHidden = true

        } else {
            
            CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                
                guard let strongSelf = self else {return}
                
                strongSelf.photo[indexPath.item].width = image.size.width
                strongSelf.photo[indexPath.item].height = image.size.height
                strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)
                
                collectionView.collectionViewLayout.invalidateLayout()
                
                strongSelf.photo[indexPath.item].image = image
                cell.configure(with: (strongSelf.photo[indexPath.item]))
                
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
        
        var width = (UIScreen.main.bounds.width - (CGFloat(itemsPerRow + 1.0) * spacingItem)) / CGFloat(itemsPerRow) - 1
        
        guard let imageWidth = photo[indexPath.item].width, let imageHeight = photo[indexPath.item].height else {
            let height = width
            return CGSize(width: width, height: height)
        }
        
        if imageWidth < width {
            width = imageWidth
        }
        
        let squareInd = imageHeight/imageWidth
        let height = width * squareInd
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacingItem, left: spacingItem, bottom: spacingItem, right: spacingItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
    
}

extension SearchCollectionViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                guard let strongSelf = self else {return}
                strongSelf.photo[indexPath.item].width = image.size.width
                strongSelf.photo[indexPath.item].height = image.size.height
                strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)
                strongSelf.photo[indexPath.item].image = image
            }
        }
    }

}
