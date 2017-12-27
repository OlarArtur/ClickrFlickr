//
//  ScaleItemCollectionFlowLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 12/27/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import Foundation


class ScaleItemCollectionFlowLayout: UICollectionViewFlowLayout {
    
    func scaleInPinch(layoutAttributes: UICollectionViewLayoutAttributes) {
       
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let allAtributesInRect = super.layoutAttributesForElements(in: rect) else {return nil}
        for cellAttributes in allAtributesInRect {
            scaleInPinch(layoutAttributes: cellAttributes)
            
        }
        return allAtributesInRect
    }
    
}
