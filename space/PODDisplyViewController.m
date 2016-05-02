//
//  PODDisplyViewController.m
//  space
//
//  Created by susan lovaglio on 4/29/16.
//  Copyright © 2016 Susan Lovaglio. All rights reserved.
//

#import "PODDisplyViewController.h"
#import "MBProgressHUD.h"
#import "NasaApiClient.h"
#import "AstronomyPOD.h"

@interface PODDisplyViewController ()
@property(strong, nonatomic) UIButton *backButton;//
@property(strong, nonatomic) UIButton *saveImageButton;
@property(strong, nonatomic) UILabel *imageTitle;
@property(strong, nonatomic) UIActivityIndicatorView *spinner;
@property(strong, nonatomic) UIImage *backgroundImage;
@property(strong, nonatomic) NSString *moreInfo;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIImageView *imageViewContainer;



@end

@implementation PODDisplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    UIFont *normalDin = [UIFont fontWithName:@"DIN" size:20];
    UIFont *smallDin = [UIFont fontWithName:@"DIN" size:15];
    
    //add spinner for load screen
    self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    self.spinner.hidden = NO;

    //make a scroll view
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.minimumZoomScale = .38;
    self.scrollView.maximumZoomScale = 6;
    self.scrollView.delegate = self;

    
    // make the back button
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.titleLabel.font = normalDin;
    self.backButton.hidden = YES;
    [self.view addSubview:self.backButton];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.backButton.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.backButton.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.backButton.widthAnchor constraintEqualToConstant:100].active = YES;
    
    //make the image title label
    self.imageTitle = [[UILabel alloc]init];
    self.imageTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:self.imageTitle];
    self.imageTitle.font = normalDin;
    self.imageTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageTitle.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-40].active = YES;
    [self.imageTitle.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    self.imageTitle.hidden = YES;
    
    //make save image button
    self.saveImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveImageButton setTitle:@"- Save Image -" forState:UIControlStateNormal];
    [self.saveImageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveImageButton addTarget:self action:@selector(saveImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.saveImageButton.titleLabel.font = smallDin;
    self.saveImageButton.hidden = YES;
    [self.view addSubview:self.saveImageButton];
    self.saveImageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveImageButton.topAnchor constraintEqualToAnchor:self.imageTitle.bottomAnchor].active = YES;
    [self.saveImageButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    
    
    NasaApiClient *apiClient = [[NasaApiClient alloc]init];
    
    [apiClient imagesFromApiWithCompletionBlock:^(NSDictionary *imageDictionaries) {
        
        AstronomyPOD *currentImage = [AstronomyPOD imagesFromDictionary:imageDictionaries];
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: currentImage.imageURL];
        
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.spinner.hidden = YES;
            self.backButton.hidden = NO;
            self.imageTitle.hidden = NO;
            self.saveImageButton.hidden = NO;
            self.backgroundImage = imageFromData;
            self.scrollView.contentSize = CGSizeMake(imageFromData.size.width, imageFromData.size.height);
            self.imageViewContainer = [[UIImageView alloc]initWithImage:imageFromData];
            [self.scrollView addSubview:self.imageViewContainer];
            self.imageTitle.text = currentImage.imageTitle;
            self.moreInfo = currentImage.imageExplanation;
            [self.view addSubview:self.scrollView];
            [self.view sendSubviewToBack:self.scrollView];
        }];
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(screenTapped:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.imageViewContainer;
}


- (void)screenTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"tapped");
    [UIView transitionWithView:self.backButton duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    [UIView transitionWithView:self.imageTitle duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    [UIView transitionWithView:self.saveImageButton duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    
    if (self.backButton.hidden == NO) {
        self.backButton.hidden = YES;
        self.imageTitle.hidden = YES;
        self.saveImageButton.hidden = YES;
    }else{
        self.backButton.hidden = NO;
        self.imageTitle.hidden = NO;
        self.saveImageButton.hidden = NO;
    }
}

- (IBAction)saveImageButtonTapped:(id)sender {
    NSLog(@"save image been tapped");
    UIImageWriteToSavedPhotosAlbum(self.backgroundImage, nil, nil, nil);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Saved!";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    });
    
    [UIView transitionWithView:hud duration:.8 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        hud.hidden = YES;
    }];
    
}

-(void)backButtonTapped{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}




@end