//
//  UserPhotoDetailViewController.h
//  ClickrFlickr
//
//  Created by Artur Olar on 11/23/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPhotoDetailViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    
}
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSIndexPath * indexPath;

@end
