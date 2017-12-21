//
//  CenterCollectionFlowLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        
        guard let collectionView = collectionView else {return}

        self.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {return CGPoint()}
        
        guard let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) else {return CGPoint()}
        let center = collectionView.bounds.size.width / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + center
        let closest = layoutAttributes.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        let targetContentOffset = CGPoint(x: floor(closest.center.x - center), y: proposedContentOffset.y)
        return targetContentOffset
    
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        return true
    }
    
}
