//
//  DetailPhotoViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/19/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class DetailPhotoViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var userInfo: UserInfoView!
    @IBOutlet weak var photoImage: UIImageView! {
        didSet {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapGestureRecognizer.delegate = self
            photoImage.addGestureRecognizer(tapGestureRecognizer)
            photoImage.isUserInteractionEnabled = true
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
            pinchGestureRecognizer.delegate = self
            photoImage.addGestureRecognizer(pinchGestureRecognizer)
        }
        
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var photo: Photo?
    var photos = [Photo]()
    var user: UserInfo?
    
    override func loadView() {
        Bundle.main.loadNibNamed("DetailPhotoViewController", owner: self, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = ScrollLineCollectionFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "DetailPhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailCell")
        
        customViews()
        configUserInfo()
        
    }
    
    @objc private func handlePinch(recognizer: UIPinchGestureRecognizer) {
        
        if let view = recognizer.view {
            switch recognizer.state {
            case .changed:
                view.transform = CGAffineTransform(scaleX: recognizer.scale, y: recognizer.scale)
                recognizer.scale = 1
            default:
                break
            }
        }
    }
    
    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        if collectionView.isHidden {
            collectionView.isHidden = false
            if UIDevice.current.orientation.isPortrait {
                userInfo.isHidden = false
            }
        } else {
            if UIDevice.current.orientation.isPortrait {
                userInfo.isHidden = true
            }
            collectionView.isHidden = true
        }
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
        
        ImageLoader.loadImageUsingUrlString(urlString: photoUrl) { [weak self] image in
            guard let strongSelf = self, let image = image else {return}
            strongSelf.photoImage.image = image
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIDevice.current.orientation.isPortrait {
            userInfo.isHidden = false
        } else {
            userInfo.isHidden = true
        }
        
        navigationController?.hidesBarsOnSwipe = false
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let visibleCells = collectionView.indexPathsForVisibleItems
        let invalidateItems = UICollectionViewFlowLayoutInvalidationContext()
        invalidateItems.invalidateItems(at: visibleCells)
        collectionView.collectionViewLayout.invalidateLayout(with: invalidateItems)
        
//        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.cleanAllCash()
    }
    
    private func configUserInfo() {
        
        guard let photo = photo else { return }
        
        UserInfoNetworkservice.getUserInfo(for: photo.owner) { [weak self] user in
            guard let strongSelf = self else {return}
            guard let user = user else {return}
            
            strongSelf.userInfo.fullNameLabel.text = user.realName
            strongSelf.userInfo.userNameLabel.text = user.userName
            strongSelf.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
            
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: user.id) { photo in
                guard let photo = photo else {return}
                strongSelf.photos = photo
                strongSelf.collectionView.reloadData()
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
        
        cell.tag = indexPath.item
        
        ImageLoader.loadImageUsingUrlString(urlString: photos[indexPath.item].url) { image in
            guard let image = image else {return}
            if cell.tag == indexPath.item {
                cell.photoImage.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        ImageLoader.loadImageUsingUrlString(urlString: photos[indexPath.item].url, completion: { [weak self] (image) in
            self?.photoImage.image = image
        })
    }
    
}
