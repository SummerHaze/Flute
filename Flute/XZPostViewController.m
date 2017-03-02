//
//  XZPostViewController.m
//  Flute
//
//  Created by xia on 23/02/2017.
//  Copyright © 2017 xia. All rights reserved.
//

#import "XZPostViewController.h"
#import "XZStatusUploader.h"
#import "XZMapViewController.h"

@interface XZPostViewController ()

@property (nonatomic) UITextView *inputView;
@property (nonatomic) UIBarButtonItem *rightButtonItem;
@property (nonatomic) UIButton *addLocation;
@property (nonatomic) UIButton *addPicture;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic, assign) CGSize keyboardSize;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longtitude;

@end

@implementation XZPostViewController
{
    UIImagePickerController *pickerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [self configureNavigationBar];
    
    [self configureSubviews];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    self.keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect currentFrame = self.inputView.frame;
    currentFrame.size.height = [[UIScreen mainScreen] bounds].size.height - self.keyboardSize.height - 50;
    
    [UIView animateWithDuration:0.00000000001 animations:^{
        self.inputView.frame = currentFrame;
    }];
}

- (void)configureNavigationBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 44)];
    
    //创建UINavigationItem
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Editing"];
    [navigationBar pushNavigationItem: item animated:YES];
    [self.view addSubview: navigationBar];
    
    //创建UIBarButton 可根据需要选择适合自己的样式
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.rightButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.rightButtonItem.enabled = NO;
    
    [item setTitle:@"Editing"];
    [item setLeftBarButtonItem:leftButtonItem];
    [item setRightBarButtonItem:self.rightButtonItem];

    [navigationBar setItems:[NSArray arrayWithObject: item]];
}

- (void)configureSubviews {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.inputView = [[UITextView alloc]initWithFrame:CGRectMake(0, 64, screenRect.size.width, 180)];
    self.inputView.textColor = [UIColor blackColor];
//    self.inputView.backgroundColor = [UIColor yellowColor];
    self.inputView.keyboardType = UIKeyboardTypeDefault;
    self.inputView.font = [UIFont fontWithName:@"Helvetica" size:16];
    self.inputView.delegate = self;
    [self.view addSubview:self.inputView];
    [self.inputView becomeFirstResponder];
    
    self.addLocation = [[UIButton alloc]initWithFrame:CGRectMake(0, 244, 60, 20)];
    [self.addLocation setTitle:@"添加位置" forState:UIControlStateNormal];
    [self.addLocation.titleLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
    [self.addLocation setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.addLocation setBackgroundColor:[UIColor greenColor]];
    [self.addLocation addTarget:self action:@selector(addLocationToStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocation];
    
    self.addPicture = [[UIButton alloc]initWithFrame:CGRectMake(0, 274, 80, 30)];
    [self.addPicture setTitle:@"添加图片" forState:UIControlStateNormal];
    [self.addPicture.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16]];
    [self.addPicture setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.addPicture setBackgroundColor:[UIColor grayColor]];
    [self.addPicture addTarget:self action:@selector(addPictureToStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPicture];
    
}

- (void)cancel {
    [self dismissViewControllerAnimated:self completion:nil];
}

- (void)done {
    XZStatusUploader *uploader = [[XZStatusUploader alloc] init];
    [uploader updloadStatus:self.inputView.text
               withLatitude:self.latitude
              andLongtitude:self.longtitude
                 completion:^(BOOL success) {
                  
                 }];
}

- (void)addLocationToStatus {
    XZMapViewController *mapController = [[XZMapViewController alloc] init];
    [self presentViewController:mapController animated:YES completion:nil];
}

- (void)addPictureToStatus {
    pickerController = [[UIImagePickerController alloc] init];
    UIImagePickerControllerSourceType source = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickerController.sourceType = source;
    
    pickerController.delegate = self;
//    pickerController.allowsEditing = YES;
    
    [self presentViewController:pickerController animated:YES completion:^{
        NSLog(@"enter photo library");
    }];
}

#pragma mark - UIImagePicker controller delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectImage = [info objectForKey:UIImagePickerControllerEditedImage];

    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 150, 80, 80)];
    self.imageView.image = selectImage;
    [self.view addSubview:self.imageView];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"选择图片成功") ;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消图片选择") ;
    }];
}

#pragma mark - UITextView delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidChange:(UITextView *)textView {
    if (![textView.text isEqualToString:@""]) {
        self.rightButtonItem.enabled = YES;
    } else {
        self.rightButtonItem.enabled = NO;
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
