//
//  PinchCollectionFlowLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 1/9/18.
//  Copyright © 2018 Artur Olar. All rights reserved.
//

import Foundation

class PinchCollectionFlowLayout: UICollectionViewFlowLayout {
    
    var pinchedCellScale = CGFloat()
    var pinchedCellCenter = CGPoint()
    var pinchedCellPath: IndexPath?
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let allAttributesInRect = super.layoutAttributesForElements(in: rect) else {return nil}
        for cellAttribute in allAttributesInRect {
            applyPinchToLayoutAttributes(layoutAttributes: cellAttribute)
        }
        return allAttributesInRect
    }
    
    private func applyPinchToLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        
        if layoutAttributes.indexPath == self.pinchedCellPath {
            layoutAttributes.transform3D = CATransform3DMakeScale(self.pinchedCellScale, self.pinchedCellScale, 1)
            layoutAttributes.center = self.pinchedCellCenter
            layoutAttributes.zIndex = 1
        }
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {return nil}
        self.applyPinchToLayoutAttributes(layoutAttributes: attributes)
        return attributes
    }
    
    func setPinchedCellScale(scale: CGFloat) {
        self.pinchedCellScale = scale
        self.invalidateLayout()
    }
    
    func setPinchedCellCenter(origin: CGPoint) {
        self.pinchedCellCenter = origin
        self.invalidateLayout()
    }
    
    
    
}
