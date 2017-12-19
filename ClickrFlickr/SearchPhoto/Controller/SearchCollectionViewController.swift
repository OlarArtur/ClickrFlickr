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
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
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
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            cell.contentView.layer.opacity = 1
        }, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.contentView.layer.opacity = 0
        cell.titlePhoto.text = photo[indexPath.item].title
        
        if let image = ImageLoader.imageFromCashe(for: photo[indexPath.item].url) {
            cell.photo.image = image
            
            cell.spinnerActivityIndicator.stopAnimating()
            cell.spinnerActivityIndicator.isHidden = true
            
            return cell
        }
        cell.spinnerActivityIndicator.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.spinnerActivityIndicator.startAnimating()
        cell.spinnerActivityIndicator.isHidden = false
        
        ImageLoader.loadImageUsingUrlString(urlString: photo[indexPath.item].url) { image in
            guard let image = image else {return}
            if collectionView.indexPath(for: cell) == indexPath {
                
                if collectionView.indexPath(for: cell) == indexPath {
                    cell.photo.image = image
                }
                cell.spinnerActivityIndicator.stopAnimating()
                cell.spinnerActivityIndicator.isHidden = true
            }
        }
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailPhotoViewController()
        detailVC.photo = self.photo[indexPath.item]
        show(detailVC, sender: self)
    }
    
}

extension SearchCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            guard ImageLoader.imageFromCashe(for: photo[indexPath.item].url) != nil else { return }
            
            ImageLoader.loadImageUsingUrlString(urlString: photo[indexPath.item].url) { image in
                guard image != nil else { return }
                return
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
