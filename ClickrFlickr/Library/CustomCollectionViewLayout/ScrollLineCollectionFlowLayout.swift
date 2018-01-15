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
        collectionView.isPagingEnabled = false
        let size = collectionView.frame.size
        let amountOfCells = ceilf(Float(size.width / size.height))
        let itemWidth = size.width / CGFloat(amountOfCells)
        self.itemSize = CGSize(width: itemWidth, height: itemWidth * 0.8)
        self.sectionInset = UIEdgeInsets(top: 0, left: self.itemSize.width, bottom: 0, right: self.itemSize.width)
        self.minimumLineSpacing = 30
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let collectionView = collectionView else {return nil}
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else {return nil}
        var newAttributes = [UICollectionViewLayoutAttributes]()
        
        for itemAttributes in attributes {
            let newItemAttributes = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            var visibleRect = CGRect()
            visibleRect.origin = collectionView.contentOffset
            visibleRect.size = collectionView.bounds.size
            if newItemAttributes.frame.intersects(rect) {
                let distance = visibleRect.midX - newItemAttributes.center.x
                let normalizedDistanse = distance / 200
                if abs(distance) < 200 {
                    let scale =  1 + 0.3 * (1 - abs(normalizedDistanse))
                    newItemAttributes.transform3D = CATransform3DMakeScale(scale, scale, 1)
                }
            }
            newAttributes.append(newItemAttributes)
        }
        return newAttributes

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
