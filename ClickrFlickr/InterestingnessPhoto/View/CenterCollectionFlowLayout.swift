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

        var mostRecentOffset : CGPoint = CGPoint()

        if velocity.x == 0 {
            return mostRecentOffset
        }

        guard let cv = collectionView else {return mostRecentOffset}

        let cvBounds = cv.bounds
        let halfWidth = cvBounds.size.width * 0.5

        if let attributesForVisibleCells = layoutAttributesForElements(in: cvBounds) {

            var candidateAttributes : UICollectionViewLayoutAttributes?
            for attributes in attributesForVisibleCells {

                // == Skip comparison with non-cell items (headers and footers) == //
                if attributes.representedElementCategory != UICollectionElementCategory.cell {
                    continue
                }

                if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                    continue
                }
                candidateAttributes = attributes
            }

            mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: candidateAttributes!.center.y)
            return mostRecentOffset
        }
        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
