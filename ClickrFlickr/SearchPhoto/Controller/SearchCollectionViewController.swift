//
//  SearchCollectionViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class SearchCollectionViewController: UICollectionViewController {
    
    var textForSearch: String = ""
    var photo = [Photo]()
    let imageCache = NSCache<NSString, UIImage>()
    let layout = WaterfallLayout()
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let layout = WaterfallLayout()
//        collectionView?.collectionViewLayout = layout
//        layout.delegate = self
        
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createSearchBar()
        
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
    }
    
    func createSearchBar() {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.searchBarStyle = .default
        searchBar.placeholder = "Search Photos"
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.spinnerActivityIndicator.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
                
                strongSelf.photo[indexPath.item].image = image
                if let cell = collectionView.cellForItem(at: indexPath) as? SearchCollectionViewCell {
                    cell.configure(with: (strongSelf.photo[indexPath.item]))
                }
                
//                strongSelf.layout.delegate = self
//                collectionView.setCollectionViewLayout(strongSelf.layout, animated: false)
//                strongSelf.layout.prepare()
                
                collectionView.collectionViewLayout.invalidateLayout()
                
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
                DispatchQueue.global().async {
                    UserInfoNetworkservice.getUserInfo(for: self.photo[indexPath.item].owner) { user in
                        detailVC.user = user
                        detailVC.configUserInfo()
                    }
                }
            }
        }
    }
    
}

extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var width = (collectionView.bounds.size.width - (2 * spacingItem))

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
            if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
                self.photo[indexPath.item].image = imageFromCache
            } else {
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

}

extension SearchCollectionViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.replacingOccurrences(of: " ", with: "+") else {
            textForSearch = ""
            return
        }
        textForSearch = text
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.imageCache.removeAllObjects()
            strongSelf.collectionView?.reloadData()
            searchBar.endEditing(true)
        }
        searchBar.text = ""
    }
    
}

//extension SearchCollectionViewController: WaterfallLayoutDelegate {
//    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, with width: CGFloat) -> CGFloat? {
////        let height: CGFloat = photo[indexPath.item].height!
////            / photo[indexPath.item].height!
//        return 100
//    }
//}



