//
//  InterestingnessPhotoViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import CoreData

class InterestingnessPhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photo = [Photo]()
    let imageCache = NSCache<NSString, UIImage>()
    var photoEntities: [PhotoEntitie]?
    
    let spacingItem: CGFloat = 2
    
//    override var shouldAutorotate: Bool {
//        return false
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
//
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .portrait
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
    
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        collectionView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        InterestingnessPhotoNetworkservice.getJsonForSearchPhoto() {[weak self] photo in
            
            guard let photo = photo else {
                guard let strongSelf = self else {return}
                let sort = NSSortDescriptor(key: #keyPath(PhotoEntitie.index) , ascending: true)
                let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
                 fetchRequest.sortDescriptors = [sort]
                do {
                    let photoEntities = try PersistentService.context.fetch(fetchRequest)
                    strongSelf.photoEntities = photoEntities
                    strongSelf.collectionView?.reloadData()
                } catch {
                    fatalError("Failure to fetch context: \(error)")
                }
                return
            }
            
            guard let strongSelf = self else {return}
            strongSelf.photo = photo.searchPhoto
            strongSelf.collectionView?.reloadData()
        }
    }


}

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoEntities = photoEntities else {
            return photo.count
        }
        return photoEntities.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var reusIdentifier = "CellInterestingnessPhoto"
    
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            reusIdentifier = "CellOnlyInterestingnessPhoto"
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusIdentifier, for: indexPath) as! OnlyPhotoViewCell
            
            if let photoEntities = photoEntities {
                guard let imageData = photoEntities[indexPath.item].image else {return cell}
                guard let image = UIImage(data: imageData as Data) else {return cell}
                cell.photo.image = image
                return cell
            }
            
            configerCell (indexPath: indexPath, completion: { [weak self] (success) in
                if success {
                    guard let strongSelf = self else {return}
                    cell.configure(with: (strongSelf.photo[indexPath.item]))
                }
            })
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
            
            if let photoEntities = photoEntities {
                guard let title = photoEntities[indexPath.item].title, let description = photoEntities[indexPath.item].photoDescription, let imageData = photoEntities[indexPath.item].image else {return cell}
                cell.descriptionLabel.text = description
                cell.titleLabel.text = title
                guard let image = UIImage(data: imageData as Data) else {return cell}
                cell.photo.image = image
                return cell
            }
            
            configerCell (indexPath: indexPath, completion: { [weak self] (success) in
                if success {
                    guard let strongSelf = self else {return}
                    cell.configure(with: (strongSelf.photo[indexPath.item]))
                }
            })
            return cell
        }
        
    }
    
    private func configerCell (indexPath: IndexPath, completion: @escaping (Bool) -> ()) {
        
        if let imageFromCache = self.imageCache.object(forKey: self.photo[indexPath.item].url as NSString) {
            self.photo[indexPath.item].image = imageFromCache
            completion(true)
        } else {
            CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
                guard let strongSelf = self else {return}
                
                strongSelf.photo[indexPath.item].width = image.size.width
                strongSelf.photo[indexPath.item].height = image.size.height
                strongSelf.imageCache.setObject(image, forKey: strongSelf.photo[indexPath.item].url as NSString)
                strongSelf.photo[indexPath.item].image = image
                
                strongSelf.fetchPhotoEntitie(for: indexPath)
                
                completion(true)
            }
        }
        
    }
    
    private func fetchPhotoEntitie(for indexPath: IndexPath) {
        let photoEntitie = PhotoEntitie(context: PersistentService.context)
        photoEntitie.index = Int16(indexPath.item)
        photoEntitie.photoDescription = photo[indexPath.item].description
        photoEntitie.title = photo[indexPath.item].title
        
        guard let image = photo[indexPath.item].image else {
            PersistentService.saveContext()
            return
        }
        
        let imageData = UIImagePNGRepresentation(image)! as NSData
        photoEntitie.image = imageData
        
        PersistentService.saveContext()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadItems(at: [indexPath])
            collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        } else {
            
            let layout = CenterCellCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadItems(at: [indexPath])
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
        var description = String()
        var title = String()
        var height = CGFloat()
        
        if let photoEntities = photoEntities {
            guard let entitieTitle = photoEntities[indexPath.item].title, let entitieDescription = photoEntities[indexPath.item].photoDescription, let imageData = photoEntities[indexPath.item].image else {return CGSize()}
            guard let image = UIImage(data: imageData as Data) else {return CGSize()}
            height = image.size.height
            description = entitieDescription
            title = entitieTitle
        } else {
            let aspectSize = photo[indexPath.item].aspectSize
            height = width * CGFloat(aspectSize)
            description = photo[indexPath.item].description
            title = photo[indexPath.item].title
        }

//        print(description)
//        if let htmlData = description.data(using: String.Encoding.utf16, allowLossyConversion: false) {
//        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//            DispatchQueue.main.async {
//                let attributedString = try? NSAttributedString(data: htmlData, options: options, documentAttributes: nil)
//                 print(attributedString)
//            }
//        }

        let fontDescription: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        let fontTitle: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let descriptionTemp = description.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: fontDescription], context: nil)
        let titleTemp = title.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: fontTitle], context: nil)
        
        let descriptionHeight = descriptionTemp.height
        let titleHeight = titleTemp.height

        height = height + descriptionHeight + titleHeight

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacingItem, left: 0, bottom: spacingItem, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 * spacingItem
    }

}

extension InterestingnessPhotoViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard photoEntities != nil else {return}
        for indexPath in indexPaths {
            configerCell(indexPath: indexPath, completion: { (success) in })
        }
    }

}



