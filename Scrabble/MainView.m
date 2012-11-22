//
//  MainView.m
//  Scrabble
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "MainView.h"
#import "Scrabble.h"
#import "SMTWord.h"
#import "GADDAG.h"
#import <Foundation/Foundation.h>

@implementation MainView {

@private Boolean *HasLoaded;
@private NSArray *wordList;
@private NSMutableArray *Board;
@private NSDictionary *letterPoints;
@private NSOperationQueue *queue1;
@private NSOperationQueue *queueScanDown;
@private NSOperationQueue *queueScanUp;
@private NSString *inhand;
    
}

@synthesize console = _console;

- (void)becomeMainWindow{
    /**
     Checks if has been called before and only runs didLoad method once.
     */
    if (!HasLoaded) {
        [self write:@"Main Window Now Active"];
        HasLoaded = true;
        [self didLoad];
    }
}

- (void)didLoad{
    /**
     First thing to run after program loads, inits gloabal varables and loads plist files into memory.
     */
    NSArray *type = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/arrayLayout.plist"];
    NSArray *items = _ViewBoard.subviews;
    for(int i = 0; i <= 224; i++){
        NSTextField *tmp = [items objectAtIndex:i];
        [tmp.cell setPlaceholderString:[type objectAtIndex:i]];
    }
    wordList = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/dictionary.plist"];
    letterPoints = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/letterPoints.plist"];
    [self loadBoard];
    // ++ init queues ++
    queue1 = [[NSOperationQueue alloc] init];
    queueScanDown = [[NSOperationQueue alloc] init];
    queueScanUp = [[NSOperationQueue alloc] init];
    [self write:@"Loaded"];
}

- (void)writeToBoard:(NSString *)wordRef atRow:(int)r inColumn:(int)c isHorizonial:(bool)hor{
    /**
     Writes a word to the board based on the direction and location, takes
        NSString wordRef -> the word to be displayed
        int r -> the row at which the word starts
        int c -> the column at which the word starts
        bool hor -> ? is horizonial : is vertical
     */
    Scrabble *scrb = [[Scrabble alloc] initWithWordListAndLetterPoint:wordList LetterPoints:letterPoints];
    NSArray *word = [scrb stringToArray:wordRef];
    NSColor *bg = [NSColor colorWithSRGBRed:0 green:0 blue:255 alpha:.5];
    if(hor){
        for (int i = 0; i < word.count; i++) {
            NSTextField *tmp = [[Board objectAtIndex:r] objectAtIndex:(i + c)];
            [tmp.cell setStringValue:[word objectAtIndex:i]];
            [tmp.cell setEditable:false];
            [tmp.cell setBackgroundColor:bg];
        }
    } else {
        for (int i = 0; i < word.count; i++) {
            NSTextField *tmp = [[Board objectAtIndex:(i + r)] objectAtIndex:c];
            [tmp.cell setStringValue:[word objectAtIndex:i]];
            [tmp.cell setEditable:false];
            [tmp.cell setBackgroundColor:bg];
        }
    }
}

- (void)readFromBoard {
    /**
     sets states after calling loadBoard
     */
    [self loadBoard];
    NSString *word = @"";
    NSColor *bg = [NSColor colorWithSRGBRed:0 green:255 blue:0 alpha:.5];
    for (int i = 0; i < 225; i++) {
        int col = i - (i/15 * 15);
        NSTextField *tmp = [[Board objectAtIndex:i/15] objectAtIndex:col];
        if (![[tmp.cell stringValue] isEqualToString:@""] && [tmp.cell isEnabled]) {
            [tmp.cell setEnabled:false];
            [tmp.cell setBackgroundColor:bg];
            word = [word stringByAppendingString:[tmp.cell stringValue]];
        }
    }
}

- (void)loadBoard {
    /**
     Loads/Updates the Board array with the current textfield data
     */
    Board = [[NSMutableArray alloc] initWithObjects:
                [NSMutableArray array], //Row 1
                [NSMutableArray array], //Row 2
                [NSMutableArray array], //Row 3
                [NSMutableArray array], //Row 4
                [NSMutableArray array], //Row 5
                [NSMutableArray array], //Row 6
                [NSMutableArray array], //Row 7
                [NSMutableArray array], //Row 8
                [NSMutableArray array], //Row 9
                [NSMutableArray array], //Row 10
                [NSMutableArray array], //Row 11
                [NSMutableArray array], //Row 12
                [NSMutableArray array], //Row 13
                [NSMutableArray array], //Row 14
                [NSMutableArray array], nil]; //Row 15
    NSArray *items = _ViewBoard.subviews;
    for (int i = 0; i < 225; i++) {
        [[Board objectAtIndex:i/15] addObject:[items objectAtIndex:i]];
    }    
}

- (IBAction)udateBoard:(id)sender {
    /**
     Called when the "Update Board" button is pressed, updates the Board array by calling readFromBoard
     */
    [self readFromBoard];
    [self write:@"Board Updated"];
}

- (IBAction)actionMove:(id)sender {
    /**
     Called when the "Move" button is pressed, collects avaliable letters and kicks off the scanBoard method
     */
    [self readFromBoard];
    [self write:@"Calculating your best move..."];
    [queue1 addOperationWithBlock:^{
        //Get Avaliable Letters
        NSArray *item = _ViewBoard.subviews;
        NSString *test = @"";
        for (int i = 225; i <=231; i++) {
            NSTextField *tmp = [item objectAtIndex:i];
            NSString *addstr = [tmp stringValue];
            test = [test stringByAppendingString:addstr];
        }
        if (![test isEqualToString:@""]) {
            inhand = test;
            Scrabble *comp = [[Scrabble alloc] init];
            GADDAG *test = [[GADDAG alloc] initWithBoard:Board hand:[comp stringToArray:inhand]];
            [test bestMove];
            
        } else {
            NSLog(@"No values");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self write:@"No Values"];
            }];
        }
    }];
}

- (void) write:(NSString *)msg {
    
    NSLog(@"%@", msg);
    NSDate *date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm:ss.SSS"];
    NSString *timeStamp = [formatter stringFromDate:date];
    NSColor *textColor = [NSColor colorWithSRGBRed:0 green:255 blue:0 alpha:.6];
    [_console setTextColor: textColor];
    [_console setString:[[_console string] stringByAppendingFormat:@"[%@] %@\n", timeStamp, msg]];
    [_console scrollPoint:NSMakePoint(0, FLT_MAX)];
}

@end



