//
//  UserViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices

class UserViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 5
    var photo = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nameObject = UserDefaults.standard.object(forKey: "fullname")
        if let name = nameObject as? String {
            userNameLabel.text = name.removingPercentEncoding
        }
        
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: userId) {[weak self] photo in
                guard let strongSelf = self else {return}
                strongSelf.photo = photo.searchPhoto
                strongSelf.collectionView?.reloadData()
            }
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func logOutPressed() {
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "tokensecret")
        
        guard let url = URL(string: Constants.logOutURL) else {
            let error = ErrorAlertController()
            error.showErrorAlertController(title: "Error! LogOut URL", message: "Try again?")
            return
        }
        let safariView = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        present(safariView, animated: true, completion: nil)
        safariView.delegate = self
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension UserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! UserCollectionViewCell
        
        CustomImageView.loadImageUsingUrlString(urlString: photo[indexPath.item].url) {[weak self] image in
            
            guard let strongSelf = self else {return}
            
            strongSelf.photo[indexPath.item].width = image.size.width
            strongSelf.photo[indexPath.item].height = image.size.height
            collectionView.collectionViewLayout.invalidateLayout()
            strongSelf.photo[indexPath.item].image = image
            cell.configure(with: (strongSelf.photo[indexPath.item]))
        }
        return cell
    }
}

extension UserViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = (UIScreen.main.bounds.width - (CGFloat(itemsPerRow + 1.0) * spacingItem)) / CGFloat(itemsPerRow) - 1
        
        guard let imageWidth = photo[indexPath.item].width, let imageHeight = photo[indexPath.item].height else {
            let height = width
            return CGSize(width: width, height: height)
        }
        
        if imageWidth < width {
            width = imageWidth
        }
        let squareInd = imageHeight/imageWidth
        
        if imageWidth > UIScreen.main.bounds.width {
            width = UIScreen.main.bounds.width
        }
        
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
