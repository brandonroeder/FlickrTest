//
//  ViewController.h
//  FlickrRocket
//
//  Created by Brandon Roeder on 3/4/14.
//  Copyright (c) 2014 Brandon Roeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, NSURLConnectionDelegate>
{
    IBOutlet UILabel *imageTitle; //label for the image title (betcha couldn't guess that, right?)
    IBOutlet UIImageView *myView;
    
    UIProgressView *progressBar;
    float progress; //data for progress bar

    NSMutableArray *images ;//array that contains the images downloaded
    NSMutableArray *imageTitles; //array that contains the image titles
    
    NSInteger imageCount; //position of the loaded image
    NSInteger wait;//just a variabale to find out when the 1st image gets downloaded
}

@end
