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
    
    var photoEntities = [PhotoEntitie]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    let imageCache = NSCache<NSString, UIImage>()
    
    let spacingItem: CGFloat = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView?.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
    
        InterestingnessPhotoNetworkservice.getJsonForSearchPhoto() { [weak self] (success) in
            
            guard let strongSelf = self else { return }
    
            guard success else {
                strongSelf.fetchtPhotoEntities()
                return
            }
            strongSelf.fetchtPhotoEntities()
        }
        
    }
    
    private func fetchtPhotoEntities() {
        
        let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
        do {
            let photoEntities = try CoreDatastack.default.mainManagedObjectContext.fetch(fetchRequest)
            self.photoEntities = photoEntities
        } catch {
            print("Error fetch request \(error)")
        }
        
    }
    
}

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoEntities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
            cell.contentView.layer.opacity = 1
        }, completion: nil)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = "CellInterestingnessPhoto"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
        cell.contentView.layer.opacity = 0
        
        guard let imageURL = photoEntities[indexPath.item].imageURL else {return cell}
        guard let imageID = photoEntities[indexPath.item].imageID else {return cell}
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            cell.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.configure(with: photoEntities[indexPath.item], image: nil)
        }
        
        if let imageFromCashe = ImageLoader.imageFromCashe(for: imageURL) {
            if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
                cell.configerOnlyPhoto(image: imageFromCashe)
            } else {
                cell.configure(with: photoEntities[indexPath.item], image: imageFromCashe)
            }
            return cell
        }
        
        if let imageFromDocument = getImageFromDocumentDirectory(key: imageID) {
            
            ImageLoader.saveImageToCashe(image: imageFromDocument, for: imageURL)
            
            if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
                cell.configerOnlyPhoto(image: imageFromDocument)
            } else {
                cell.configure(with: photoEntities[indexPath.item], image: imageFromDocument)
            }
            return cell
        }
        
        cell.photo.tag = indexPath.item
        
        ImageLoader.loadImageUsingUrlString(urlString: imageURL) { [weak self] image in
            guard let strongSelf = self, let image = image else { return }
            strongSelf.saveImageToDocumentDirectory(image: image, key: imageID)
            
            if cell.photo.tag == indexPath.item {
                if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
                    cell.configerOnlyPhoto(image: image)
                } else {
                    cell.configure(with: strongSelf.photoEntities[indexPath.item], image: image)
                }
            }
        }
        return cell
        
    }
    
    private func saveImageToDocumentDirectory(image: UIImage, key: String) {
        
        DispatchQueue.global().async {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            guard let data = UIImagePNGRepresentation(image) else {return}
            
            let fileName = paths.appendingPathComponent("\(key).png")
            do {
                try data.write(to: fileName)
            } catch {
                print("Error write image to document directory: \(error)")
            }
        }
        
    }
    
    private func getImageFromDocumentDirectory(key: String) -> UIImage? {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileManager = FileManager.default
        let fileName = paths.appendingPathComponent("\(key).png")
        
        if fileManager.fileExists(atPath: fileName.path) {
            return UIImage(contentsOfFile: fileName.path)
        }
        return nil
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            
            guard let navigationController = navigationController, let tabBarController = tabBarController else {return}
            
            if navigationController.isNavigationBarHidden {
                navigationController.isNavigationBarHidden = false
                tabBarController.tabBar.isHidden = false
            } else {
                navigationController.isNavigationBarHidden = true
                tabBarController.tabBar.isHidden = true
            }
            
        } else {
            let layout = CenterCellCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            collectionView.setCollectionViewLayout(layout, animated: false) { [weak self] (success) in
                guard let strongSelf = self else {return}
                if success {
                    strongSelf.collectionView.reloadItems(at: [indexPath])
                }
            }
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            let closeItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain , target: self , action: #selector(closeButtonPressed))
            closeItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            navigationItem.rightBarButtonItem = closeItem
        }
    }
    
    @objc func closeButtonPressed() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] (success) in
            guard let strongSelf = self else {return}
            if success {
                let visibleCells = strongSelf.collectionView.indexPathsForVisibleItems
                strongSelf.collectionView.reloadItems(at: visibleCells)
            }
        }
        collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        navigationItem.rightBarButtonItem = nil
    }
    
}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return collectionView.frame.size
        }

        let width = collectionView.bounds.size.width

        guard let description = photoEntities[indexPath.item].photoDescription, let aspectSize = photoEntities[indexPath.item].aspectRatio, let aspectSizeFloat = Float(aspectSize) else {
            return CGSize(width: 0, height: 0)
        }
        
        let photoHeight = (width - 16) * CGFloat(aspectSizeFloat)

        let fontDescription: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let descriptionTemp = description.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: fontDescription], context: nil)

        var descriptionHeight = descriptionTemp.height + 5
        
        if descriptionHeight > 50 {
            descriptionHeight = 55
        }
        
        let height = photoHeight + descriptionHeight

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return 0
        }
        return 20
    }

}

extension InterestingnessPhotoViewController: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

        for indexPath in indexPaths {

            guard let imageURL = photoEntities[indexPath.item].imageURL else { return }
            guard let imageID = photoEntities[indexPath.item].imageID else { return }

            if ImageLoader.imageFromCashe(for: imageURL) != nil {
                continue
            }
            if getImageFromDocumentDirectory(key: imageID) != nil {
                continue
            }
            ImageLoader.loadImageUsingUrlString(urlString: imageURL, completion: {[weak self] (image) in
                guard let strongSelf = self, let image = image else {return}
                strongSelf.saveImageToDocumentDirectory(image: image, key: imageID)
            })
        }
    }

}

