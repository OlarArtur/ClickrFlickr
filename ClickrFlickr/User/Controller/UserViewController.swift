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

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userInfo: UserInfo!
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 5
    var photo = [Photo]()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userNameObject = UserDefaults.standard.object(forKey: "username")
        let fullNameObject = UserDefaults.standard.object(forKey: "fullname")
        if let fullName = fullNameObject as? String, let userName = userNameObject as? String {
            userInfo.fullNameLabel.text = fullName.removingPercentEncoding
            userInfo.userNameLabel.text = userName
            userInfo.photoCountLabel.text = ""
        }
        
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: userId) {[weak self] photo in
                guard let strongSelf = self else {return}
                strongSelf.photo = photo.searchPhoto
                strongSelf.collectionView?.reloadData()
            }
            DispatchQueue.global().async {
                UserInfoNetworkservice.getUserInfo(for: userId) { [weak self] user in
                    guard let strongSelf = self else {return}
                    strongSelf.user = user
                    strongSelf.configUserInfo()
                }
            }
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOutPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func configUserInfo() {
        guard let user = user else {return}
        DispatchQueue.main.async {
            self.userInfo.fullNameLabel.text = user.realName
            self.userInfo.userNameLabel.text = user.userName
            self.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
        }
        
        CustomImageView.loadImageUsingUrlString(urlString: user.urlAvatar) { [weak self] image in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                strongSelf.userInfo.avatarImageView.image = image
            }
        }
    }
    
    @objc func logOutPressed() {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellUser", for: indexPath) as! UserCollectionViewCell
        
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
        
        var width = (UIScreen.main.bounds.width - (CGFloat(itemsPerRow + 1.0) * spacingItem)) / CGFloat(itemsPerRow)
        
        guard let imageWidth = photo[indexPath.item].width, let imageHeight = photo[indexPath.item].height else {
            let height = width
            return CGSize(width: width, height: height)
        }
        
        if imageWidth < width {
            width = imageWidth
        }
        let squareInd = imageHeight/imageWidth
        
        if imageWidth > UIScreen.main.bounds.width {
            width = (UIScreen.main.bounds.width - (2 * spacingItem))
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
