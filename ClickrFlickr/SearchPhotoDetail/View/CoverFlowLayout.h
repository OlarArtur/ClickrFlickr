//
//  CoverFlowLayout.h
//  ClickrFlickr
//
//  Created by Artur Olar on 12/13/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;

@end
