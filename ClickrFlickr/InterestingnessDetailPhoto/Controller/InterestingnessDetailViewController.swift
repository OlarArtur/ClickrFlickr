//
//  InterestingnessDetailViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/24/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit

class InterestingnessDetailViewController: UIViewController {
    
    var photo = [Photo]()
    let spacingItem: CGFloat = 2
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CenterCellCollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        guard let collectionView = collectionView else {return}
//        collectionView.collectionViewLayout.invalidateLayout()
//    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        var insets = self.collectionView.contentInset
//        let value = (self.view.frame.size.height - (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.height) * 0.5
//        insets.top = value
//        insets.bottom = value
//        self.collectionView.contentInset = insets
//        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
//
//    }


}


extension InterestingnessDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestingnessDetailCell", for: indexPath) as! InterestingnessDetailCell
        cell.configure(with: photo[indexPath.item])
        return cell
    }
    
    

}

extension InterestingnessDetailViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
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

