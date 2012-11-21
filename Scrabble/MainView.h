//
//  MainView.h
//  Scrabble
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainView : NSWindow

- (IBAction)udateBoard:(id)sender;
- (IBAction)actionMove:(id)sender;
@property (weak) IBOutlet NSView *ViewBoard;
@property (unsafe_unretained) IBOutlet NSTextView *console;

@end
