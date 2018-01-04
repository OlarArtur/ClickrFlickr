//
//  ScrollLineCollectionFlowLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 1/4/18.
//  Copyright © 2018 Artur Olar. All rights reserved.
//

import Foundation


class ScrollLineCollectionFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let collectionView = collectionView else {return}
        
        self.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.backgroundColor = #colorLiteral(red: 0.1879811585, green: 0.1879865527, blue: 0.1879836619, alpha: 1)
        let size = collectionView.frame.size
        let amountOfCells = ceilf(Float(size.width / size.height))
        let itemWidth = size.width / CGFloat(amountOfCells)
        self.itemSize = CGSize(width: itemWidth, height: itemWidth * 0.8)
        self.sectionInset = UIEdgeInsets(top: 0, left: self.itemSize.width, bottom: 0, right: self.itemSize.width)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var newAttributes = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in attributes! {
            let newItemAttributes = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            changeLayoutAttributes(newItemAttributes)
            
            newAttributes.append(newItemAttributes)
        }
        return newAttributes
    }
    
    private func changeLayoutAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        let collectionCenter = collectionView!.frame.size.width / 2
        let offset = collectionView!.contentOffset.x
        let normalizedCenter = attributes.center.x - offset
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
        let ratio = (maxDistance - distance)/maxDistance
        let scale = ratio * (1 - 0.8) + 0.8
        attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {return CGPoint()}
        
        guard let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) else {return CGPoint()}
        let center = collectionView.frame.size.width / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + center
        let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        let targetContentOffset = CGPoint(x: closest.center.x - center, y: proposedContentOffset.y)
        return targetContentOffset
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
