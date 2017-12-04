//
//  SearchCollectionViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class SearchCollectionViewController: UICollectionViewController, UISearchControllerDelegate {
    
    var textForSearch: String = ""
    var photo = [Photo]()
    let imageCache = NSCache<NSString, UIImage>()
    let layout = WaterfallLayout()
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.collectionViewLayout = layout
        layout.delegate = self
        
        collectionView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        createSearchBar()
        
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    private func createSearchBar() {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.searchBarStyle = .default
        searchBar.placeholder = "Search Photos"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.spinnerActivityIndicator.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.spinnerActivityIndicator.startAnimating()
        
        if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
            
            self.photo[indexPath.item].image = imageFromCache
            cell.configure(with: self.photo[indexPath.item])
            
            cell.spinnerActivityIndicator.stopAnimating()
            cell.spinnerActivityIndicator.isHidden = true

        } else {
            
            CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                
                guard let strongSelf = self else {return}
                
                strongSelf.photo[indexPath.item].width = image.size.width
                strongSelf.photo[indexPath.item].height = image.size.height
                strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)
                
                strongSelf.photo[indexPath.item].image = image
                if cell == collectionView.cellForItem(at: indexPath) {
                    cell.configure(with: (strongSelf.photo[indexPath.item]))
                }
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

extension SearchCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
                self.photo[indexPath.item].image = imageFromCache
            } else {
                CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                    guard let strongSelf = self else {return}
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

extension SearchCollectionViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, with width: CGFloat) -> CGFloat? {
        let squareInd = photo[indexPath.item].aspectSize
        let height = width * CGFloat(squareInd)
        return height
    }
    
}
