//
//  InterestingnessPhotoViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class InterestingnessPhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photo = [Photo]()
    let imageCache = NSCache<NSString, UIImage>()
    
    let spacingItem: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        InterestingnessPhotoNetworkservice.getJsonForSearchPhoto() {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let collectionView = collectionView else {return}
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        guard let collectionView = collectionView else {return}
//        collectionView.collectionViewLayout.invalidateLayout()
//    }

}

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellInterestingnessPhoto", for: indexPath) as! InterstingnessPhotoCollectionViewCell
        
        if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
            
            self.photo[indexPath.item].image = imageFromCache
            cell.configure(with: self.photo[indexPath.item])
            
        } else {
            
            CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                
                guard let strongSelf = self else {return}
                
                strongSelf.photo[indexPath.item].width = image.size.width
                strongSelf.photo[indexPath.item].height = image.size.height
                strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)

                strongSelf.photo[indexPath.item].image = image
                if let cell = collectionView.cellForItem(at: indexPath) as? InterstingnessPhotoCollectionViewCell {
                    cell.configure(with: (strongSelf.photo[indexPath.item]))
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            collectionView.setCollectionViewLayout(layout, animated: true)
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.toolbar.isHidden = false
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        let layout = CenterCellCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.toolbar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return CGSize(width: collectionView.bounds.width - 2 * spacingItem, height: collectionView.bounds.height - 2 * spacingItem)
        }
        
        var width = collectionView.bounds.size.width - 2 * spacingItem

        let squareInd = photo[indexPath.item].aspectSize
        var height = width * CGFloat(squareInd)
        
        if height > collectionView.bounds.size.height {
            height = collectionView.bounds.size.height  - 2 * spacingItem
            width = height / CGFloat(squareInd)
        }
        
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

extension InterestingnessPhotoViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
                self.photo[indexPath.item].image = imageFromCache
            } else {
                CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                    guard let strongSelf = self else {return}
                    strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)
                    strongSelf.photo[indexPath.item].image = image
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
}

