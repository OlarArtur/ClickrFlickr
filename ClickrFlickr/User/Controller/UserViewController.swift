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
    
    let userInfo = UserInfo()
    let sideBarContainerView:UIView = UIView()
    
    var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.init() , collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.setCollectionViewLayout(collectionViewLayout, animated: true)
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: "CellUser")
        return collectionView
    }()
    
    var photo = [Photo]()
    var user: User?
    
    override func loadView() {
        super.loadView()
        
        sideBarContainerView.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        sideBarContainerView.backgroundColor = #colorLiteral(red: 0.1234010687, green: 0.1234010687, blue: 0.1234010687, alpha: 1)
        let logOutButton = UIButton()
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        sideBarContainerView.addSubview(logOutButton)
        logOutButton.addTarget(self, action: #selector(logOutPressed), for: .touchUpInside)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        logOutButton.topAnchor.constraint(equalTo: sideBarContainerView.topAnchor, constant: 5).isActive = true
        logOutButton.leftAnchor.constraint(equalTo: sideBarContainerView.leftAnchor, constant: 10).isActive = true
    
        view.addSubview(userInfo)
        userInfo.translatesAutoresizingMaskIntoConstraints = false
        userInfo.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        userInfo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        userInfo.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        userInfo.heightAnchor.constraint(equalToConstant: 70).isActive = true
        userInfo.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: userInfo.bottomAnchor, constant: 0).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInfo.fullNameLabel.text = ""
        userInfo.userNameLabel.text = ""
        userInfo.photoCountLabel.text = ""
        
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: userId) {[weak self] photo in
                guard let strongSelf = self else {return}
                strongSelf.photo = photo.searchPhoto
                strongSelf.collectionView.reloadData()
            }
            DispatchQueue.global().async {
                UserInfoNetworkservice.getUserInfo(for: userId) { [weak self] user in
                    guard let strongSelf = self else {return}
                    strongSelf.user = user
                    strongSelf.configUserInfo()
                }
            }
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuPressed))
        navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
    }
    
    @objc func menuPressed() {

        view.addSubview(sideBarContainerView)
        
        if menuIsVisible {
            UIView.animate(withDuration: 0.4, animations: {
                self.sideBarContainerView.frame.origin.x = UIScreen.main.bounds.width
            })
            menuIsVisible = false
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.sideBarContainerView.frame.origin.x = UIScreen.main.bounds.width / 2
            })
            menuIsVisible = true
        }
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
        cell.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
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

