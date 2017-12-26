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
    
//    let itemsPerRow: CGFloat = 2
//    let spacingItem: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = WaterfallLayout()
        collectionView?.collectionViewLayout = layout
        layout.delegate = self
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        createSearchBar()
        
        SearchNetworkservice.getJsonForSearchPhoto(searchText: textForSearch) {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo
            strongSelf.collectionView?.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.cleanAllCash()
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
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            cell.contentView.alpha = 1
        }, completion: nil)

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell
        
        cell.contentView.alpha = 0
        cell.titlePhoto.text = photo[indexPath.item].title
        
        cell.spinnerActivityIndicator.isHidden = false
        cell.spinnerActivityIndicator.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.spinnerActivityIndicator.startAnimating()
        
         cell.photo.tag = indexPath.item
        
        ImageLoader.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
            guard let image = image else {return}
            if cell.photo.tag == indexPath.item {
                cell.photo.image = image
                cell.titlePhoto.text = self?.photo[indexPath.item].title
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
            strongSelf.photo = photo
            strongSelf.collectionView?.collectionViewLayout.invalidateLayout()
            strongSelf.collectionView?.reloadData()
            searchBar.endEditing(true)
        }
        searchBar.text = ""
    }
    
}

extension SearchCollectionViewController: WaterfallLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, with width: CGFloat) -> CGFloat? {
        let aspectSize = photo[indexPath.item].aspectSize
        let height = width * CGFloat(aspectSize)
        return height
    }
    
}
