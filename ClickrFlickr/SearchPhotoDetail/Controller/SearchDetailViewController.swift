//
//  SearchDetailViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 10/30/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class SearchDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var userInfo: UserInfo!
    
    var photo: Photo?
    var photos = [Photo]()
    var user: User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CoverFlowLayout()
        collectionView.collectionViewLayout = layout
        
        customViews()

    }
    
    private func customViews() {
        userInfo.fullNameLabel.text = ""
        userInfo.userNameLabel.text = ""
        userInfo.photoCountLabel.text = ""
        userInfo.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        userInfo.fullNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        userInfo.userNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        userInfo.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        
        self.view.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        guard let photo = photo else {return}
        detailImageView.image = photo.image
        detailImageView.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    func configUserInfo() {
        guard let user = user else {return}
        DispatchQueue.main.async {
            self.userInfo.fullNameLabel.text = user.realName
            self.userInfo.userNameLabel.text = user.userName
            self.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
            
        }
        
        GetPhotoNetworkservice.getJsonForSearchPhoto(userId: user.id) {[weak self] photo in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                strongSelf.photos = photo.searchPhoto
                strongSelf.collectionView.reloadData()
            }
        }
        
        CustomImageView.loadImageUsingUrlString(urlString: user.urlAvatar) { [weak self] image in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                strongSelf.userInfo.avatarImageView.image = image
            }
        }
    }

}

extension SearchDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchDetailCell", for: indexPath) as! SearchDetailViewCell
        
        CustomImageView.loadImageUsingUrlString(urlString: photos[indexPath.item].url) {[weak self] image in
            
            guard let strongSelf = self, let image = image else {return}
            
            collectionView.collectionViewLayout.invalidateLayout()
            strongSelf.photos[indexPath.item].image = image
            if collectionView.indexPath(for: cell) == indexPath {
                cell.configure(with: (strongSelf.photos[indexPath.item]))
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let image = photos[indexPath.item].image else {return}
        detailImageView.image = image
    }
    
}
