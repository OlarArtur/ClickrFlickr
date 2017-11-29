//
//  UserViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import SafariServices

class UserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SFSafariViewControllerDelegate {
    
    let itemsPerRow: CGFloat = 2
    let spacingItem: CGFloat = 2
    var menuIsVisible = false
    
    var sideBarContainerView: UIView!

    var collectionView: UICollectionView!
    
    var photo = [Photo]()
    
    override func loadView() {
        super.loadView()
        
        addCollectionView()
    
    }
    
    private func addCollectionView() {
        
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        collectionViewLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.init() , collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: "CellUser")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        let topConstraint = NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UserHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserPhotos()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuPressed))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
    }
    
    @objc func menuPressed() {
        
        if menuIsVisible {
            
            UIView.animate(withDuration: 0.4, animations: {
                self.sideBarContainerView.frame.origin.x = self.view.bounds.width + 140
            }, completion: { success in
                guard success else {return}
                self.sideBarContainerView.removeFromSuperview()
            })
            menuIsVisible = false
        } else {
            addSideBarMenu()
            
            sideBarContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
            
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
            menuIsVisible = true
        }
    }
    
    private func addSideBarMenu() {
        
        sideBarContainerView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: 140, height: view.bounds.height))
        sideBarContainerView.backgroundColor = #colorLiteral(red: 0.1234010687, green: 0.1234010687, blue: 0.1234010687, alpha: 1)
        
        sideBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideBarContainerView)
        
        let widthMenuConstrait = sideBarContainerView.widthAnchor.constraint(equalToConstant: 140)
        let topMenuConstrait = sideBarContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        let bottomMenuConstrait = sideBarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([widthMenuConstrait, topMenuConstrait, bottomMenuConstrait])
        
        let logOutButton = UIButton()
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
        logOutButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        sideBarContainerView.addSubview(logOutButton)
        logOutButton.addTarget(self, action: #selector(logOutPressed), for: .touchUpInside)
        let topLogOutConstrait = logOutButton.topAnchor.constraint(equalTo: sideBarContainerView.topAnchor, constant: 5)
        let centerXLogOutConstrait = logOutButton.centerXAnchor.constraint(equalTo: sideBarContainerView.centerXAnchor)
        NSLayoutConstraint.activate([topLogOutConstrait, centerXLogOutConstrait])
        
    }
    
    @objc func logOutPressed(sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "fullname")
        UserDefaults.standard.removeObject(forKey: "usernsid")
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
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        view.layoutIfNeeded()
//    }
    
    private func fetchUserPhotos() {
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: userId) {[weak self] photo in
                guard let strongSelf = self else {return}
                strongSelf.photo = photo.searchPhoto
                strongSelf.collectionView.reloadData()
            }
        }
        
    }
    
    private func fetchUserInfo(completion: @escaping (UserInfo) ->()) {
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            UserInfoNetworkservice.getUserInfo(for: userId) { user in
                let userInfo = UserInfo()
                userInfo.fullNameLabel.text = user.realName
                userInfo.userNameLabel.text = user.userName
                userInfo.photoCountLabel.text = "\(user.photoCount) photos"
                
                CustomImageView.loadImageUsingUrlString(urlString: user.urlAvatar) { image in
                    DispatchQueue.main.async {
                        userInfo.avatarImageView.image = image
                        completion(userInfo)
                    }
                }
            }
        }
        
    }
    
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
            if let cell = collectionView.cellForItem(at: indexPath) as? UserCollectionViewCell {
                cell.configure(with: (strongSelf.photo[indexPath.item]))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! UserHeaderCollectionReusableView
        
        fetchUserInfo { userInfo in
            headerView.configerUserInfo(userInfo: userInfo)
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        return headerView
    }
    
}


extension UserViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var width = (collectionView.bounds.size.width - (CGFloat(itemsPerRow + 1.0) * spacingItem)) / CGFloat(itemsPerRow)

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }

}

