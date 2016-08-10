//
//  ViewController.m
//  PubNubSwiftConsole
//
//  Created by Jordan Zucker on 8/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import <PubNub/PubNub.h>
@import PubNubSwiftConsole;
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *clientCreationButton;
@property (nonatomic, weak) IBOutlet UIButton *consoleButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.clientCreationButton setTitle:@"PubNub Client Creation" forState:UIControlStateNormal];
    [self.clientCreationButton addTarget:self action:@selector(clientCreationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.consoleButton setTitle:@"PubNub Console" forState:UIControlStateNormal];
    [self.consoleButton addTarget:self action:@selector(consoleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)clientCreationButtonPressed:(UIButton *)sender {
    
}

- (void)consoleButtonPressed:(UIButton *)sender {
    
}

@end
