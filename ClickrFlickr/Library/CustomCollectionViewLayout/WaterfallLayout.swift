//
//  WaterfallLayout.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/17/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


protocol WaterfallLayoutDelegate: class {
    func collectionView(collectionView: UICollectionView, heightForPhotoAt indexPath: IndexPath, with width: CGFloat) -> CGFloat?
    
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?

    private var numberOfColumns: CGFloat = 2
    private var cellPadding: CGFloat = 2.5
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {return 0.0}
        return collectionView.bounds.width
    }

    private var attributesCache = [UICollectionViewLayoutAttributes]()

    override func prepare() {
        super.prepare()
        
        attributesCache = [UICollectionViewLayoutAttributes]()
        guard let collectionView = collectionView else {return}
        
        let columWidth = contentWidth / numberOfColumns
        var xOffsets = [CGFloat]()
        for column in 0 ..< Int(numberOfColumns) {
            xOffsets.append(CGFloat(column) * columWidth)
        }
        var column = 0
        var yOffsets = [CGFloat](repeatElement(0, count: Int(numberOfColumns)))
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let width = columWidth
            
            guard let photoHeight: CGFloat = delegate?.collectionView(collectionView: collectionView, heightForPhotoAt: indexPath, with: width) else {return}
            let height = photoHeight
            
            let frame = CGRect(x: xOffsets[column], y: yOffsets[column], width: columWidth, height: height)
            
            let insetFrame = frame.insetBy(dx: cellPadding / 2 , dy: cellPadding / 2)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            attributesCache.append(attribute)
            
            contentHeight = max(contentHeight, frame.maxY)
            
            yOffsets[column] = yOffsets[column] + height
            
            if column >= (Int(numberOfColumns) - 1) {
                column = 0
            } else {
                column += 1
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in attributesCache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}

