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
    
    var headerViewHeight: CGFloat = 0
    var isHeaderVisible: Bool = true
    
    var menuIsVisible = false
    
    var sideBarContainerView: UIView!
    var collectionView: UICollectionView!
    var userInfo: UserInfo!
    
    var photo = [Photo]()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func loadView() {
        super.loadView()
        
        addCollectionView()
    
    }
    
    private func addCollectionView() {
        
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        collectionViewLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: CGRect.init() , collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.cleanAllCash()
    }
    
    @objc func menuPressed() {
        
        if menuIsVisible {
            
            UIView.animate(withDuration: 0.4, animations: {
                self.sideBarContainerView.frame.origin.x = self.view.bounds.width + 140
            }, completion: { success in
                guard success else { return }
                self.sideBarContainerView.removeFromSuperview()
                self.menuIsVisible = false
            })
        } else {
            addSideBarMenu()
            UIView.animate(withDuration: 0.4, animations: {
                self.sideBarContainerView.frame.origin.x = self.view.bounds.width - 140
                self.sideBarContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            })
            menuIsVisible = true
        }
        
    }
    
    private func addSideBarMenu() {
        
        sideBarContainerView = UIView(frame: CGRect(x: view.bounds.width, y: 0, width: 140, height: view.bounds.height))
        let gradient = CAGradientLayer()
        gradient.frame =  sideBarContainerView.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.white.cgColor, UIColor.black.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        sideBarContainerView.layer.insertSublayer(gradient, at: 0)
        
        sideBarContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideBarContainerView)
        
        sideBarContainerView.layer.shadowOpacity = 1
        sideBarContainerView.layer.shadowRadius = 6
        
        let widthMenuConstrait = sideBarContainerView.widthAnchor.constraint(equalToConstant: 140)
        let topMenuConstrait = sideBarContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        let bottomMenuConstrait = sideBarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([widthMenuConstrait, topMenuConstrait, bottomMenuConstrait])
        
        let logOutButton = UIButton()
        logOutButton.setTitle("Log Out", for: .normal)
        logOutButton.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
        logOutButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logOutButton.translatesAutoresizingMaskIntoConstraints = false
        sideBarContainerView.addSubview(logOutButton)

        guard let navigationController = navigationController else {return}
        let topLogOutConstrait = logOutButton.topAnchor.constraint(equalTo: navigationController.navigationBar.bottomAnchor, constant: 10)
        let centerXLogOutConstrait = logOutButton.centerXAnchor.constraint(equalTo: sideBarContainerView.centerXAnchor)
        NSLayoutConstraint.activate([topLogOutConstrait, centerXLogOutConstrait])
        logOutButton.addTarget(self, action: #selector(logOutPressed), for: .touchUpInside)
        
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
    
    private func fetchUserPhotos() {
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            GetPhotoNetworkservice.getJsonForSearchPhoto(userId: userId) {[weak self] photo in
                guard let strongSelf = self else {return}
                strongSelf.photo = photo
                strongSelf.collectionView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellUser", for: indexPath) as! UserCollectionViewCell
    
        ImageLoader.loadImageUsingUrlString(urlString: photo[indexPath.item].url) { image in
            guard let image = image else {return}
                cell.photo.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! UserHeaderCollectionReusableView
        headerViewHeight = headerView.bounds.height
        
        fetchUserInfo { userInfo in
            guard let userInfo = userInfo else { return }
            headerView.configerUserInfo(userInfo: userInfo)
        }
        return headerView
    }
    
    private func fetchUserInfo(completion: @escaping (UserInfo?) ->()) {
        let userId = UserDefaults.standard.object(forKey: "usernsid")
        if let userId = userId as? String {
            UserInfoNetworkservice.getUserInfo(for: userId) { [weak self] user in
                guard let strongSelf = self, let user = user else {
                    completion(nil)
                    return
                }
                strongSelf.userInfo = UserInfo()
                strongSelf.userInfo.fullNameLabel.text = user.realName
                strongSelf.userInfo.userNameLabel.text = user.userName
                strongSelf.userInfo.photoCountLabel.text = "\(user.photoCount) photos"
                
                ImageLoader.loadImageUsingUrlString(urlString: user.urlAvatar, completion: { image in
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    strongSelf.userInfo.avatarImageView.image = image
                    completion(strongSelf.userInfo)
                })
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "UserPhotoDetail", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserPhotoDetail" {
            let detailVC = segue.destination as! UserPhotoDetailViewController
            detailVC.photos = photo
        }
    }
    
}


extension UserViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let navigationController = navigationController else {return}

        let navBarY = navigationController.navigationBar.frame.origin.y
        let navBarHeight = navigationController.navigationBar.frame.height
        
        let offsetY = scrollView.contentOffset.y + (navBarY + navBarHeight)
        
        if offsetY > headerViewHeight {
            if isHeaderVisible {
                self.navigationItem.titleView = self.userInfo
                self.userInfo.topStackView.axis = .horizontal
                self.userInfo.fullNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.userInfo.userNameLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                isHeaderVisible = false
            }
        } else {
            if !isHeaderVisible {
                self.navigationItem.titleView = nil
                isHeaderVisible = true
            }
        }
        
    }
    
}

extension UserViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.size.width - spacingItem

        let aspectSize = photo[indexPath.item].aspectSize
        let height = width * CGFloat(aspectSize)

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 180)
    }
    
}

