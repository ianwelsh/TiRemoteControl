/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "NetHoyohoyoTiremotecontrolModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation NetHoyohoyoTiremotecontrolModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"9326b7d7-f454-4b2d-bd81-1aebcd8ee868";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"net.hoyohoyo.tiremotecontrol";
}

#pragma mark Lifecycle

double backwardInterval = 30;
double forwardInterval = 30;

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [commandCenter skipBackwardCommand];
    skipBackwardIntervalCommand.preferredIntervals = @[@(backwardInterval)];
    MPSkipIntervalCommand *skipForwardIntervalCommand = [commandCenter skipForwardCommand];
    skipForwardIntervalCommand.preferredIntervals = @[@(forwardInterval)];
    
    [commandCenter.pauseCommand addTarget:self action:@selector(onPause:)];
    [commandCenter.playCommand addTarget:self action:@selector(onPlay:)];
    [commandCenter.stopCommand addTarget:self action:@selector(onStop:)];
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(onTogglePlayPause:)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(onNextTrack:)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(onPreviousTrack:)];
    [commandCenter.seekForwardCommand addTarget:self action:@selector(onSeekForward:)];
    [commandCenter.seekBackwardCommand addTarget:self action:@selector(onSeekBackward:)];
    [commandCenter.skipForwardCommand addTarget:self action:@selector(onSkipForward:)];
    [commandCenter.skipBackwardCommand addTarget:self action:@selector(onSkipBackward:)];
}

-(void)onPause:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"pause"]; }
-(void)onPlay:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"play"]; }
-(void)onStop:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"stop"]; }
-(void)onTogglePlayPause:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"togglePlayPause"]; }
-(void)onNextTrack:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"nextTrack"]; }
-(void)onPreviousTrack:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"previousTrack"]; }
-(void)onSeekForward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"seekForward"]; }
-(void)onSeekBackward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"seekBackward"]; }
-(void)onSkipForward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"skipForward"]; }
-(void)onSkipBackward:(MPRemoteCommandHandlerStatus*)event { [self sendEvent:@"skipBackward"]; }

-(void)sendEvent:(NSString*)event
{
    NSLog(@"sending event: %@", event);

    if ([event isEqualToString:@"skipForward"]) {
        NSDictionary *e = @{
            @"control" : event,
            @"interval" : @(forwardInterval)
        };
        [self fireEvent:@"remotecontrol" withObject:e];
    }
    else if ([event isEqualToString:@"skipBackward"]) {
        NSDictionary *e = @{
            @"control" : event,
            @"interval" : @(backwardInterval)
        };
        [self fireEvent:@"remotecontrol" withObject:e];
    }
    else {
        NSDictionary *e = [NSDictionary dictionaryWithObject:event forKey:@"control"];
        [self fireEvent:@"remotecontrol" withObject:e];
    }
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}


#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
    if (count == 1 && [type isEqualToString:@"my_event"])
    {
        // the first (of potentially many) listener is being added
        // for event named 'my_event'
    }
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
    if (count == 0 && [type isEqualToString:@"my_event"])
    {
        // the last listener called for event named 'my_event' has
        // been removed, we can optionally clean up any resources
        // since no body is listening at this point for that event
    }
}

#pragma mark -
#pragma mark Public APIs

-(void)setNowPlayingInfo:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    NSString *artist = [TiUtils stringValue:@"artist" properties:args def:@""];
    NSString *title = [TiUtils stringValue:@"title" properties:args def:@""];
    NSString *albumTitle = [TiUtils stringValue:@"albumTitle" properties:args def:@""];
    BOOL *albumArtworkLocal = [TiUtils boolValue:@"albumArtworkLocal" properties:args def:@""];
    NSString *albumArtwork = [TiUtils stringValue:@"albumArtwork" properties:args def:nil];
    NSString *duration = [TiUtils stringValue:@"duration" properties:args def:@"0"];
    NSString *rate = [TiUtils stringValue:@"rate" properties:args def:@"1.0"];

    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter) {

        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];

        if(albumArtwork != nil){
            
            UIImage *artworkImage = nil;
            
            if(albumArtworkLocal){
                
                NSString *albumArtworkPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:albumArtwork];
                
                artworkImage = [UIImage imageWithContentsOfFile:albumArtworkPath];
           
            }else{
                
                artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:albumArtwork]]];
            }
	       	MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:artworkImage];
	       	[songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
	    }

        [songInfo setObject:artist forKey:MPMediaItemPropertyArtist];
        [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:albumTitle forKey:MPMediaItemPropertyAlbumTitle];
        [songInfo setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject:rate forKey:MPNowPlayingInfoPropertyDefaultPlaybackRate];

        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

-(void)setElapsedTime:(id)elapsed
{
    ENSURE_SINGLE_ARG(elapsed, NSNumber);
    MPNowPlayingInfoCenter *nowPlayingCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionaryWithDictionary:nowPlayingCenter.nowPlayingInfo];
    
    [playingInfo setObject:elapsed forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    nowPlayingCenter.nowPlayingInfo = playingInfo;
}

-(void)setPlaybackRate:(id)rate
{
    ENSURE_SINGLE_ARG(rate, NSNumber);
    MPNowPlayingInfoCenter *nowPlayingCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionaryWithDictionary:nowPlayingCenter.nowPlayingInfo];
    
    [playingInfo setObject:rate forKey:MPNowPlayingInfoPropertyDefaultPlaybackRate];
    nowPlayingCenter.nowPlayingInfo = playingInfo;
}

-(void)setEnabledControls:(id)args
{
    MPRemoteCommandCenter *remoteCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    ENSURE_SINGLE_ARG(args,NSDictionary);
    BOOL *pause = [TiUtils boolValue:@"pause" properties:args def:false];
    BOOL *play = [TiUtils boolValue:@"play" properties:args def:false];
    BOOL *stop = [TiUtils boolValue:@"stop" properties:args def:false];
    BOOL *togglePlayPause = [TiUtils boolValue:@"togglePlayPause" properties:args def:false];
    BOOL *nextTrack = [TiUtils boolValue:@"nextTrack" properties:args def:false];
    BOOL *previousTrack = [TiUtils boolValue:@"previousTrack" properties:args def:false];
    BOOL *changePlaybackRate = [TiUtils boolValue:@"changePlaybackRate" properties:args def:false];
    BOOL *seekBackward = [TiUtils boolValue:@"seekBackward" properties:args def:false];
    BOOL *seekForward = [TiUtils boolValue:@"seekForward" properties:args def:false];
    BOOL *skipBackward = [TiUtils boolValue:@"skipBackward" properties:args def:false];
    BOOL *skipForward = [TiUtils boolValue:@"skipForward" properties:args def:false];
    
    remoteCenter.pauseCommand.enabled = pause;
    remoteCenter.playCommand.enabled = play;
    remoteCenter.stopCommand.enabled = stop;
    remoteCenter.togglePlayPauseCommand.enabled = togglePlayPause;
    remoteCenter.nextTrackCommand.enabled = nextTrack;
    remoteCenter.previousTrackCommand.enabled = previousTrack;
    remoteCenter.changePlaybackRateCommand.enabled = changePlaybackRate;
    remoteCenter.seekBackwardCommand.enabled = seekBackward;
    remoteCenter.seekForwardCommand.enabled = seekForward;
    remoteCenter.skipBackwardCommand.enabled = skipBackward;
    remoteCenter.skipForwardCommand.enabled = skipForward;
}

-(void)setSkipIntervals:(id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);
    backwardInterval = [TiUtils doubleValue:@"backwardInterval" properties:args def:30];
    forwardInterval = [TiUtils doubleValue:@"forwardInterval" properties:args def:30];
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [commandCenter skipBackwardCommand];
    skipBackwardIntervalCommand.preferredIntervals = @[@(backwardInterval)];
    MPSkipIntervalCommand *skipForwardIntervalCommand = [commandCenter skipForwardCommand];
    skipForwardIntervalCommand.preferredIntervals = @[@(forwardInterval)];
    
    [commandCenter.skipForwardCommand addTarget:self action:@selector(onSkipForward:)];
    [commandCenter.skipBackwardCommand addTarget:self action:@selector(onSkipBackward:)];
}


-(void)clearNowPlayingInfo:(id)args
{
    // NowPlaying画面の情報をクリア
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    }
}

@end
