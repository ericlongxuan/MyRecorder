//
//  FileListViewController.h
//  MyRecorder
//
//  Created by Weichen Wang on 12/11/15.
//  Copyright © 2015 Eric Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FileListViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end
