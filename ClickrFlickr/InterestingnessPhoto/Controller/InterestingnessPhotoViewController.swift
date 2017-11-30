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
        
        collectionView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        InterestingnessPhotoNetworkservice.getJsonForSearchPhoto() {[weak self] photo in
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        guard let collectionView = collectionView else {return}
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
    
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

        var reusIdentifier = "CellInterestingnessPhoto"
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            reusIdentifier = "CellOnlyInterestingnessPhoto"
            
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusIdentifier, for: indexPath) as! OnlyPhotoViewCell
            
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
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
            
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
        
     
//        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadData()
            collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        } else {
            let layout = CenterCellCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadData()
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }

    }

}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        }
        
        let width = collectionView.bounds.size.width

        let squareInd = photo[indexPath.item].aspectSize
        var height = width * CGFloat(squareInd)
//        print("start height: \(height)")

        let description = photo[indexPath.item].description
        
//        print(description)
//        if let htmlData = description.data(using: String.Encoding.utf16, allowLossyConversion: false) {
//        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//            DispatchQueue.main.async {
//                let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
//                 print(attributedString)
//            }
//        }
        
        let font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let descriptionTemp = description.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        let descriptionHeight = descriptionTemp.height
    
//        print("description height: \(descriptionHeight)")
        height = height + descriptionHeight
//        print("finish height: \(height)")
//        print("__________")
    
//        if height > collectionView.bounds.size.height {
//            height = collectionView.bounds.size.height  - 2 * spacingItem
//            width = height / CGFloat(squareInd)
//        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacingItem, left: 0, bottom: spacingItem, right: 0)
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
                }
            }
        }
    }
    
}

