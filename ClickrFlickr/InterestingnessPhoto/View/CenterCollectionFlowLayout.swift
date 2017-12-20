//
//  CenterCollectionFlowLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        let layoutAttributes = self.layoutAttributesForElements(in: collectionView!.bounds)
        let center = collectionView!.bounds.size.width / 2
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + center
        let closest = layoutAttributes!.sorted { abs($0.center.x - proposedContentOffsetCenterOrigin) < abs($1.center.x - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        let targetContentOffset = CGPoint(x: floor(closest.center.x - center), y: proposedContentOffset.y)
        return targetContentOffset
    
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var newAttributes = [UICollectionViewLayoutAttributes]()
        guard let attributes = super.layoutAttributesForElements(in: rect) else {return newAttributes}
        for itemAttributes in attributes {
            let newItmAttributes = itemAttributes.copy() as! UICollectionViewLayoutAttributes
            newAttributes.append(newItmAttributes)
        }
        return newAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
