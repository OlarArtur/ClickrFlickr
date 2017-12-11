//
//  UserPhotoDetailViewController.m
//  ClickrFlickr
//
//  Created by Artur Olar on 11/23/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

#import "UserPhotoDetailViewController.h"
#import "UserPhotoDetailCell.h"
#import <ClickrFlickr-Swift.h>

@interface UserPhotoDetailViewController () {
    NSMutableArray *photo;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property NSMutableArray *photo;

@end

@implementation UserPhotoDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}


#pragma UICollectionViewDataSource

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (__kindof UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserPhotoDetailCell";
    
    UserPhotoDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.photo.image = [UIImage imageNamed:@"flickr"];
    
    return cell;
}

@end
