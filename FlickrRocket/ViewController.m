//
//  ViewController.m
//  FlickrRocket
//
//  Created by Brandon Roeder on 3/4/14.
//  Copyright (c) 2014 Brandon Roeder. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

NSString *const flickr_api = @"640f161ddceaceaee4dbb2c0d555a420";


@implementation ViewController


//this takes care of the left swipe
-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    if([images count]>2)
    {
        if(imageCount==[images count]-1)
        {
            imageCount=0;
        }
        else
        {
            imageCount++; //increment image count
        }
        
        [UIView transitionWithView:self.view duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve animations:^
            {
                myView.image = [images objectAtIndex:imageCount]; //displays images
                imageTitle.text=[imageTitles objectAtIndex:imageCount]; //displays image title
            }
                completion:nil];
    }
}
//this takes care of the right swipe
-(void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if(imageCount<=0)
    {
        imageCount=[images count]-1;
    }
    else
    {
        imageCount--;
    }
    [UIView transitionWithView:self.view duration:0.4f options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^
    {
        myView.image = [images objectAtIndex:imageCount]; //displays images
        imageTitle.text=[imageTitles objectAtIndex:imageCount]; //displays image title
    }
        completion:nil];
}

-(void)UpdateUI:(double)value
{
    [progressBar setProgress:value];
    if(value == 1.0)
    {
        imageTitle.text=[imageTitles objectAtIndex:0];
        [progressBar removeFromSuperview];
    }
    else
    {
           imageTitle.text=@"Loading images...";
    }
}

-(void)myThreadMainMethod:(NSThread *)myThread
{
    //random variables
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSError * jsonError = nil;

    
	NSString *URLString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=puppies&per_page=15&format=json&nojsoncallback=1", flickr_api];
    
    NSURL *myURL = [NSURL URLWithString:URLString];
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:myURL];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:myRequest returningResponse:&response error:&error];
    
    id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
        
        if(jsonError == nil)
        {
            NSDictionary * result = (NSDictionary *) json; //initial raw unparsed data
            
            NSMutableDictionary *result2 = [[NSMutableDictionary alloc] init];
            result2 = [result valueForKey:@"photos"]; //this makes the dict for the values in "photos"tag
            
            NSMutableDictionary *result3 = [[NSMutableDictionary alloc] init];
            result3 = [result2 valueForKey:@"photo"]; //this makes the dict for the values in "photo"tag
            
            //all of this is to get the data from the dictionary
            NSArray *farm=[result3 valueForKey:@"farm"];
            NSArray *server=[result3 valueForKey:@"server"];
            NSArray *pid=[result3 valueForKey:@"id"];
            NSArray *secret=[result3 valueForKey:@"secret"];
            NSArray *title=[result3 valueForKey:@"title"]; //stores image titles
            
    
            for (int i = 0; i < [farm count]; i++) //loop compiles complete URL adds the images & their titles to arrays
            {
                NSString *final=@"http://farm";
                NSString* temp=[farm objectAtIndex:i] ;
                final = [final stringByAppendingString:[NSString stringWithFormat:@"%@", temp]];
                final = [final stringByAppendingString:@".static.flickr.com/"];
                final = [final stringByAppendingString:[NSString stringWithFormat:@"%@", [server objectAtIndex:i]]];
                final=[final stringByAppendingString:@"/"];
                final = [final stringByAppendingString:[NSString stringWithFormat:@"%@", [pid objectAtIndex:i]]];
                final=[final stringByAppendingString:@"_"];
                final = [final stringByAppendingString:[NSString stringWithFormat:@"%@", [secret objectAtIndex:i]]];
                final=[final stringByAppendingString:@"_m.jpg"]; //this contains the fully compiled URL
             

                NSURL *url = [NSURL URLWithString:final];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img = [[UIImage alloc] initWithData:data]; //contains the downloaded images
                
                
                [images addObject:img]; //adding images to array
                [imageTitles addObjectsFromArray:(title)]; //adding image titles to array
                
                
                wait=1; //just a flag to tell the thread that at least one image has been loaded
                
                
                progress=(float)(i+1)/[farm count]; //calculates the data for the progress bar
                
                //calls main thread to update progress bar
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self UpdateUI:progress];
                });
            }
        }
    }


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageCount=0; //random variables
    progress=0.0;
    wait=0;
    
    //initializing the array that stores the downloaded images & titles
    images = [[NSMutableArray alloc] init];
    imageTitles= [[NSMutableArray alloc] init];
    
    //this sets the status bar to white (it kept defaulting to black and I couldn't read anything)
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //this creates the imageView
    myView = [[UIImageView alloc] initWithFrame:CGRectMake(29, 28, 260, 390)]; //hardcoding position is not the best way to do it :(
    imageTitle=[[UILabel alloc] initWithFrame:CGRectMake(29, 420, myView.frame.size.width, 46)]; //position of the image title
    imageTitle.textAlignment = NSTextAlignmentCenter; //centers the image titles
    imageTitle.textColor=[UIColor whiteColor]; //sets the image title text to white
    
    
    //this is the main thread
    NSThread* myThread = [[NSThread alloc] initWithTarget:self selector:@selector(myThreadMainMethod:)object:nil];
    [myThread start];
    
    //this initializes progress bar adds it to the subview
    progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0,395,260,390)];
    [myView addSubview:progressBar];
    [progressBar setProgress:progress];
    
    while(!wait) //this just tells the thread to wait for the the first image to be downloaded
    {
        //do not do anything
        //how boring
    }
    
    //when the while loop exits, the secondary thread has downloaded atleast one image
    myView.image=[images objectAtIndex:0];
    
    UISwipeGestureRecognizer *recognizer;  //adds the swipe gesture

    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    [recognizer release];
    
    //adds image and image title to the view! yayyy
    [self.view addSubview:myView];
    [self.view addSubview:imageTitle];
    [self setNeedsStatusBarAppearanceUpdate]; //sets status bar to white..I'm sure this isn't the easiest way to accomplish this
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [myView release];
}


- (void)dealloc
{
    [imageTitle release];
    [myView release];
    [super dealloc];
}
@end //dats it

