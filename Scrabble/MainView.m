//
//  MainView.m
//  Scrabble
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "MainView.h"
#import <Foundation/Foundation.h>

@implementation MainView {

@private Boolean *HasLoaded;
@private NSArray *wordList;
@private NSMutableArray *Board;
@private NSDictionary *letterPoints;
    
}

@synthesize ViewBoard = _ViewBoard;

- (void)becomeMainWindow{
    if (!HasLoaded) {
        NSLog(@"Main Window Now Active");
        HasLoaded = true;
        [self didLoad];
    } 
}

- (void)didLoad{
    NSArray *type = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/arrayLayout.plist"];
    NSArray *items = _ViewBoard.subviews;
    for(int i = 0; i <= items.count-9; i++){
        NSTextField *tmp = [items objectAtIndex:i];
        [tmp.cell setPlaceholderString:[type objectAtIndex:i]];
    }
    wordList = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/dictionary.plist"];
    letterPoints = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/letterPoints.plist"];
    NSLog(@"Loaded");
}

- (void)loadBoardValues {
    // Load Dictionary
    NSArray *values = _ViewBoard.subviews;
    for(int i = 0; i <= 224; i++){
        [Board addObject:[values objectAtIndex:i]];
    }
}

- (NSArray *)anagramArrayFromCharacterArray:(NSMutableArray *)characters fixedChars:(NSArray *)arrayRef {
    NSMutableArray *anagrams = [[NSMutableArray alloc] init];
    NSMutableArray *fixedChars = [arrayRef mutableCopy];
    Boolean *canMakeWord = true;
    for(NSString *list in wordList){
        NSMutableArray *checkWord = [self stringToArray:list];
        int count = (int)checkWord.count;
        for (int i = 0; i<=count-1; i++) {
            if (i < fixedChars.count) {
                if ([[fixedChars objectAtIndex:i] isEqualTo:[checkWord objectAtIndex:i]]) {
                    
                } else {
                    canMakeWord = false;
                }
            } else {
                int leftCount = (int)fixedChars.count;
                if (leftCount > 0) {
                    for (int x = 0; x < leftCount-1; x++){
                        if ([[checkWord objectAtIndex:i] isEqualTo:[fixedChars objectAtIndex:x]]){
                            [fixedChars removeObjectAtIndex:x];
                        }
                    }
                } else {
                    canMakeWord = false;
                }
            }
        }
        if (canMakeWord) {
            [anagrams addObject:list];
        }
    }
    return anagrams;
}

- (IBAction)actionMove:(id)sender {
    NSLog(@"Calculating your best move...");
    [self loadBoardValues];
    NSString *test = @"jdcosen";
    [test capitalizedString];
    NSArray *values = [self anagramArrayFromCharacterArray:[self stringToArray:test] fixedChars:@[@"none", @"A"]];
    NSLog(@"%@", values);
}

- (NSNumber *)pointValueFromString:(NSString *)str{
    return [self pointValueFromArray:[self stringToArray:str]];
}

- (NSNumber *)pointValueFromArray:(NSMutableArray *)array{
    NSNumber *count = 0;
    for (NSString *i in array){
        NSNumber *temp = letterPoints[i];
        count = @([count floatValue] + [temp floatValue]);
    }
    return count;
}

- (NSMutableArray *)stringToArray:(NSString *)str {
    NSMutableArray *chars = [[NSMutableArray alloc] init];
    for(int index = 0; index<=[str length]-1; index++){
        NSString *testStr = [NSString stringWithFormat:@"%c", [str characterAtIndex:index]];
        [chars addObject:testStr];
    }
    return chars;
}
@end




