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

        var mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)

        guard let collectionView = collectionView else {return mostRecentOffset}

        let halfWidth = collectionView.bounds.size.width * 0.5

        if let attributesForVisibleCells = layoutAttributesForElements(in: collectionView.bounds) {

            var candidateAttributes: UICollectionViewLayoutAttributes?
            for attributes in attributesForVisibleCells {

                if attributes.representedElementCategory != .cell {
                    continue
                }

                if (attributes.center.x == 0) || (attributes.center.x > (collectionView.contentOffset.x + halfWidth) && velocity.x < 0) {
                    continue
                }
                candidateAttributes = attributes
            }
            
            if(proposedContentOffset.x == -(collectionView.contentInset.left)) {
                return proposedContentOffset
            }
            
            guard let candidateAttr = candidateAttributes else {
                return mostRecentOffset
            }

            mostRecentOffset = CGPoint(x: candidateAttr.center.x - halfWidth, y: candidateAttr.center.y)
            return mostRecentOffset
        }
        return mostRecentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
