//
//  ViewController.m
//  PubNubSwiftConsole
//
//  Created by Jordan Zucker on 8/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#import <PubNubSwiftConsole/PubNubSwiftConsole-Swift.h> // important this come before PubNub
#import <PubNub/PubNub.h> // important this come after
#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *clientCreationButton;
@property (nonatomic, weak) IBOutlet UIButton *consoleButton;
@property (nonatomic, strong) PubNub *client;
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

#pragma mark - Actions

- (void)clientCreationButtonPressed:(UIButton *)sender {
    PNCNavigationController *navController = [PNCNavigationController clientCreationNavigationController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)consoleButtonPressed:(UIButton *)sender {
    self.client = [PubNub clientWithConfiguration:[PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"]];
    PNCNavigationController *navController = [PNCNavigationController consoleNavigationController:self.client];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
