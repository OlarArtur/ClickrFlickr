//
//  DetailPhotoViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController {

    @IBOutlet weak var userInfo: UserInfo!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photo: Photo?
    var photos = [Photo]()
    var user: User?
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func loadView() {
        Bundle.main.loadNibNamed("DetailPhotoViewController", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CoverFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "DetailPhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailCell")
        
        customViews()
        configUserInfo()
        
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
        
        guard let photoUrl = photo?.url else {return}
        photoImage.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        if let image = ImageLoader.imageFromCashe(for: photoUrl) {
            photoImage.image = image
        }
        
        ImageLoader.loadImageUsingUrlString(urlString: photoUrl) { [weak self] image in
            guard let strongSelf = self, let image = image else {return}
            strongSelf.photoImage.image = image
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    func configUserInfo() {
        
        guard let photo = photo else { return }
        
        UserInfoNetworkservice.getUserInfo(for: photo.owner) { [weak self] user in
            guard let strongSelf = self else {return}
            guard let user = user else {return}
            
            strongSelf.userInfo.fullNameLabel.text = user.realName
            strongSelf.userInfo.userNameLabel.text = user.userName
            strongSelf.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
            
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: user.id) {photo in
                strongSelf.photos = photo.searchPhoto
                strongSelf.collectionView.reloadData()
            }
            
            if let image = ImageLoader.imageFromCashe(for: user.urlAvatar) {
                strongSelf.userInfo.avatarImageView.image = image
            }
            
            ImageLoader.loadImageUsingUrlString(urlString: user.urlAvatar) { [weak self] image in
                guard let strongSelf = self, let image = image else {return}
                strongSelf.userInfo.avatarImageView.image = image
            }
        }
        
    }
    
}

extension DetailPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailPhotoViewCell
        
        cell.photoImage.tag = indexPath.item
        
        ImageLoader.loadImageUsingUrlString(urlString: photos[indexPath.item].url) { image in
            guard let image = image else {return}
            if cell.photoImage.tag == indexPath.item {
                cell.photoImage.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ImageLoader.loadImageUsingUrlString(urlString: photos[indexPath.item].url, completion: { [weak self] (image) in
            self?.photoImage.image = image
        })
    }
    
}
