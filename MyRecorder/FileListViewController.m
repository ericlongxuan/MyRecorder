//
//  FileListViewController.m
//  MyRecorder
//
//  Created by Weichen Wang on 12/11/15.
//  Copyright © 2015 Eric Wang. All rights reserved.
//

#import "FileListViewController.h"

@implementation FileListViewController

NSMutableArray *filePathsArray;
NSString *documentsDirectory;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.dataSource = self;
    [self setUpTheFileNamesToBeListed];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View appears");
    self.tableView.dataSource = nil;
    self.tableView.dataSource = self;
    [self setUpTheFileNamesToBeListed];
}


- (void)setUpTheFileNamesToBeListed
{
    filePathsArray = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSArray *fileNames = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    for (NSString *file in fileNames) {
        if ([file hasSuffix:@"caf"]) {
            [filePathsArray addObject:file];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [filePathsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    //Insert this line to add the file name to the list
    cell.textLabel.text = [filePathsArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [filePathsArray objectAtIndex:indexPath.row];
    NSString *soundFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else{
        [_audioPlayer play];
    }
    
}


@end
