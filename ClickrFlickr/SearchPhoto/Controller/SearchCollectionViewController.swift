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
    
//    var cellSize = CGSize.zero
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
        let height = width * 1.3
        return CGSize(width: width, height: height)
    }

//    func calculateCellSize(indexPath: IndexPath) -> CGSize {
//        let width = (UIScreen.main.bounds.width - (CGFloat(2.0 + 1.0) * 5.0)) / CGFloat(2.0) - 1
//        let square = photo[indexPath.item].width/photo[indexPath.item].height
//        let height = photo[indexPath.item].width * square
//        return CGSize(width: width, height: height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellSize = calculateCellSize(indexPath: indexPath)
//        return cellSize
//    }
    
}


