//
//  CoverFlowLayout.m
//  ClickrFlickr
//
//  Created by Artur Olar on 12/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

#import "CoverFlowLayout.h"

@implementation CoverFlowLayout

-(void) prepareLayout {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [[UIColor alloc]initWithRed:0.1915385664 green:0.1915385664 blue:0.1915385664 alpha:1];
    CGSize size = self.collectionView.frame.size;
    CGFloat itemWidth = size.width/3.0f;
    self.itemSize = CGSizeMake(itemWidth, itemWidth*0.75f);
    self.sectionInset = UIEdgeInsetsMake(size.height*0.1f, self.itemSize.width, size.height*0.1f, self.itemSize.width);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    float collectionViewHalfFrame = self.collectionView.frame.size.width/2.0f;
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in attributes) {
        if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - layoutAttributes.center.x;
            CGFloat normalizedDistance= distance / collectionViewHalfFrame;
            
            if (ABS(distance) < collectionViewHalfFrame) {
                CGFloat zoom = 1 + 0.25f*(1- ABS(normalizedDistance));
                CATransform3D rotationTransform = CATransform3DIdentity;
                rotationTransform = CATransform3DMakeRotation(normalizedDistance * M_PI_2 *0.8f, 0.0f, 1.0f, 0.0f);
                CATransform3D zoomTransform = CATransform3DMakeScale(zoom, zoom, 1.0f);
                layoutAttributes.transform3D = CATransform3DConcat(zoomTransform, rotationTransform);
                layoutAttributes.zIndex = ABS(normalizedDistance) * 10.0f;
                CGFloat alpha = (1  - ABS(normalizedDistance)) + 0.1f;
                if (alpha > 1.0f) alpha = 1.0f;
                layoutAttributes.alpha = alpha;
            }
            else
            {
                layoutAttributes.alpha = 0.0f;
            }
        }
    }
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGSize collectionViewSize = self.collectionView.bounds.size;
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width * 0.5f;
    
    CGRect proposedRect = CGRectMake(proposedContentOffset.x, 0.0, collectionViewSize.width, collectionViewSize.height);
    
    UICollectionViewLayoutAttributes* candidateAttributes;
    for (UICollectionViewLayoutAttributes* attributes in [self layoutAttributesForElementsInRect:proposedRect])
    {
        if (attributes.representedElementCategory != UICollectionElementCategoryCell)
        {
            continue;
        }
        if(!candidateAttributes)
        {
            candidateAttributes = attributes;
            continue;
        }
        
        if (fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX))
        {
            candidateAttributes = attributes;
        }
    }
    return CGPointMake(candidateAttributes.center.x - self.collectionView.bounds.size.width * 0.5f, proposedContentOffset.y);
}

@end
