//
//  ViewController.m
//  MyRecorder
//
//  Created by Weichen Wang on 12/1/15.
//  Copyright © 2015 Eric Wang. All rights reserved.
//

#import "ViewController.h"

#define RECORD_TIME 60
#define GAP_TIME_OVER_RECORD_TIME 2

@interface ViewController ()

// for timer setting and operations
@property (nonatomic) NSInteger statusValueForTimer;
@property (nonatomic) BOOL microIsPaused;
@property (nonatomic) float *myMemory;
@property (nonatomic) NSUInteger memoryUsed;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSString *timeString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _playButton.enabled = NO;
    _stopButton.enabled = NO;
    
    _formatter = [[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"HH-mm-ss"];

    _microIsPaused = YES;
    _statusValueForTimer = GAP_TIME_OVER_RECORD_TIME;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                  withOptions:(AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker)
                        error: nil];
    
    [self addTimer];
    _recordButton.enabled = NO;
    _stopButton.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchRecord:(UIButton *)sender {
    if (!_audioRecorder.recording) {
        _playButton.enabled = NO;
        _stopButton.enabled = YES;
        
    }
}

- (IBAction)touchPlay:(UIButton *)sender {
    if (!_audioRecorder.recording) {
        _stopButton.enabled = YES;
        _recordButton.enabled = NO;
        
        NSError *error;
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioRecorder.url error:&error];
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else{
            [_audioPlayer play];
        }
    }
}

- (IBAction)touchStop:(UIButton *)sender {
    _stopButton.enabled = NO;
    _playButton.enabled = YES;
    _recordButton.enabled = YES;
    
    if (_audioRecorder.recording || self.microIsPaused) {
        [_timer invalidate];
        [_audioRecorder stop];
    }
    else {
        [_audioPlayer stop];
    }
}


#pragma mark - timer method
/**
 *  add Timer to controller
 */
-(void)addTimer
{
    UIBackgroundTaskIdentifier bgTask;
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];

    _timer =  [NSTimer timerWithTimeInterval:RECORD_TIME
                                      target:self
                                    selector:@selector(autoSwitchMicrophone)
                                    userInfo:nil
                                     repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

-(void)autoSwitchMicrophone
{
    NSLog(@"timer!!");
    UIApplication*  app = [UIApplication sharedApplication];
    NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
    if (!_microIsPaused) {
        [_audioRecorder stop];
        NSLog(@"pause!!");
        _microIsPaused = YES;
        _statusValueForTimer = 1;
    }
    else if (_microIsPaused){
        NSLog(@"statusValueForTimer!!%lu", (unsigned long)_statusValueForTimer);
        if (_statusValueForTimer >= GAP_TIME_OVER_RECORD_TIME) {
            NSLog(@"start!!");
            [self startNewRecordUsingUrl:[self getNewFileURLByNow]];
            _microIsPaused = NO;
        }
        else{
            _statusValueForTimer ++;
        }
    }
}

-(NSURL *)getNewFileURLByNow
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *nowTimeString = [_formatter stringFromDate:[NSDate date]];
    NSString *fileName = [nowTimeString stringByAppendingString:@".caf"];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:fileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    return soundFileURL;
}


-(void) startNewRecordUsingUrl: (NSURL *)fileURL
{
//    NSDictionary *recordSettings = @{AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin],
//                                     AVEncoderBitRateKey: [NSNumber numberWithInt: 16],
//                                     AVNumberOfChannelsKey: [NSNumber numberWithInt: 1],
//                                     AVSampleRateKey: [NSNumber numberWithFloat:16000.0]};
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:8000.0], AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self getNewFileURLByNow] settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    else {
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
    }

}
@end
