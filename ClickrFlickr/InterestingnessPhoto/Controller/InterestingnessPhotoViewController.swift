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
    var photoEntities: [PhotoEntitie]?
    
    let imageCache = NSCache<NSString, UIImage>()

    
    var stack = CoreDatastack()
    
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
    
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
        collectionView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
        InterestingnessPhotoNetworkservice.getJsonForSearchPhoto() { [weak self] (success) in
    
            guard success else { return }
            
            guard let strongSelf = self else { return }

            let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
            do {
                let photoEntitiesd = try strongSelf.stack.mainManagedObjectContext.fetch(fetchRequest)

                strongSelf.photoEntities = photoEntitiesd
                strongSelf.collectionView?.reloadData()
            } catch {
                print("Error fetch request \(error)")
            }
        }
    }
    
}

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoEntities = photoEntities else {
            return 0
        }
        return photoEntities.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let reusIdentifier = "CellInterestingnessPhoto"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reusIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
        
        guard let photoEntities = photoEntities else {return cell}
        
        guard let imageURL = photoEntities[indexPath.item].imageURL else {return cell}
        
        guard let imageID = photoEntities[indexPath.item].imageID else {return cell}
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            CustomImageView.loadImageUsingUrlString(urlString: imageURL) {/*[weak self]*/ image in
                // guard let strongSelf = self else {return}
                cell.configerOnlePhoto(image: image)
            }
            return cell
        }
        
        if let image = getImageFromDocumentDirectory(key: imageID) {
            cell.configure (with: (photoEntities[indexPath.item]), image: image)
//            print(" get image \(image), index path \(indexPath)")
        } else {
            CustomImageView.loadImageUsingUrlString(urlString: imageURL) { [weak self] image in
                guard let strongSelf = self else {return}
                cell.configure (with: (photoEntities[indexPath.item]), image: image)
                strongSelf.saveImageToDocumentDirectory(image: image, key: imageID)
//                print(" save image \(image), index path \(indexPath)")
            }
        }
        return cell
        
    }
    
    private func saveImageToDocumentDirectory(image: UIImage, key: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        guard let data = UIImagePNGRepresentation(image) else {return}
        
        let fileName = paths.appendingPathComponent("\(key).png")
        do {
            try data.write(to: fileName)
        } catch {
            print("Error write image to document directory: \(error)")
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
            collectionView.setCollectionViewLayout(layout, animated: true)
            collectionView.reloadItems(at: [indexPath])
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            
            let closeItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain , target: self , action: #selector(closeButtonPressed))
            closeItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            navigationItem.rightBarButtonItem = closeItem
        }
    }
    
    @objc func closeButtonPressed() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        navigationItem.rightBarButtonItem = nil
    }
    
}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        }

        let width = collectionView.bounds.size.width

        var height = CGFloat()

        guard let photoEntities = photoEntities, let description = photoEntities[indexPath.item].photoDescription, let title = photoEntities[indexPath.item].title, let aspectSize = photoEntities[indexPath.item].aspectRatio, let aspectSizeFloat = Float(aspectSize) else {
            return CGSize(width: 0, height: 0)
        }
        
        height = width * CGFloat(aspectSizeFloat)


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
        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return 0
        }
        return 20
    }

}

//extension InterestingnessPhotoViewController: UICollectionViewDataSourcePrefetching {
//
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        guard photoEntitie != nil else {return}
//        for indexPath in indexPaths {
//            configerCell(indexPath: indexPath, completion: { (success) in })
//        }
//    }
//
//}
