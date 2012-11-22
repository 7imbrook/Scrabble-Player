//
//  GADDAG.m
//  Scrabble
//
//  Created by Michael on 11/21/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//
//  A GADDAG solver, looking more like a DAWG however
//  Based of of http://www.ericsink.com/downloads/faster-scrabble-gordon.pdf
//

#import "GADDAG.h"
#import "SMTWord.h"
#import "Scrabble.h"

@implementation GADDAG {
    
@private NSMutableArray *Board;
@private NSMutableArray *Hand;
@private NSArray *wordList;
@private NSDictionary *letterPoints;
@private NSArray *layout;

}

- (id)initWithBoard:(NSMutableArray *)boardRef hand:(NSMutableArray *)handRef{
    /**
     Initialize the class and sets values
     returns self
     */
    if(self = [super init]){
        wordList = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/dictionary.plist"];
        letterPoints = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/letterPoints.plist"];
        layout = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/arrayLayout.plist"];
        Board = boardRef;
        Hand = handRef;
    }
    return self;
}

- (SMTWord *)bestMove{
    [self findInColumn:7 atRow:7];
    return nil;
}

- (SMTWord *)findInColumn:(int)col atRow:(int)row{
    /**
     Looks is given column (col) and used a variation of the GADDAG algorithm
     */
    NSString *letterAtCord = [[[Board objectAtIndex:row] objectAtIndex:col] stringValue];
    NSMutableArray *newHand = [[NSMutableArray alloc] initWithArray:Hand];
    for (int i = 0; i <= 14; i++){
        if (![[[[Board objectAtIndex:i] objectAtIndex:col] stringValue] isEqualTo:@""]) {
            [newHand addObject:[[[Board objectAtIndex:i] objectAtIndex:col] stringValue]];
        }
    }
    Scrabble *comp = [[Scrabble alloc] initWithWordListAndLetterPoint:wordList LetterPoints:letterPoints];
    NSArray *allWords = [comp anagramArrayFromCharacterArray:newHand fixedChars:@[]];
    NSMutableArray *allSMTWords = [[NSMutableArray alloc] init];
    for (NSString *word in allWords){
        if ([self letter:letterAtCord isInWord:word]) {
            NSMutableArray *wordArray = [comp stringToArray:word];
            NSArray *hooks = [self getHooksFor:wordArray on:letterAtCord];
            for (NSNumber *hookIndex in hooks) {
                if (![hookIndex isEqualTo:[[NSNumber alloc] initWithInt:-1]]) {
                    int passed = 0;
                    bool hasBlank = false;
                    int total = (int)word.length;
                    for (int i = 0; i < wordArray.count; i++) {
                        int rowRef = i + row - [hookIndex intValue];
                        if ([[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:[wordArray objectAtIndex:i]] || [[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                            if ([[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                                passed++;
                                hasBlank = true;
                            } else {
                                passed++;
                            }
                        }
                        if (i == wordArray.count - 1) {
                            if (passed == total && hasBlank) {
                                if ([[[[Board objectAtIndex:rowRef+1] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                                    NSLog(@"Passed: %@", word);
                                    SMTWord *tmp = [[SMTWord alloc] initWithWord:word row:(row - [hookIndex intValue]) column:col isHorizonal:false];
                                    [allSMTWords addObject:tmp];
                                }
                            } 
                        }
                    }
                }
            }
        }
    }
    //                          TO-DO                           //
    // First check if/where they fit                         [] //
    // Second make SMTWord with value and ajusted cordinates [] //
    // Third return the SMTWord with the highest .pointValue [] //
    
    
    
    return nil;
}

- (SMTWord *)findInRow:(int)row atColumn:(int)col{
    /**
     Looks is given row (row) and used a variation of the GADDAG algorithm
     */
    
    return  nil;
}
- (NSArray *)getHooksFor:(NSMutableArray *)word on:(NSString *)hook{
    NSMutableArray *accum = [[NSMutableArray alloc] init];
    int len = (int)word.count;
    for (int i = 0; i < len; i++){
        if ([[word objectAtIndex:i] isEqualToString:hook]) {
            NSNumber *tmp = [[NSNumber alloc] initWithInt:i];
            [accum addObject:tmp];
        }
    }
    return [accum arrayByAddingObject:[[NSNumber alloc] initWithInt:-1]];
}

- (bool)letter:(NSString *)letter isInWord:(NSString *)word {
    bool returnValue = false;
    Scrabble *comp = [[Scrabble alloc] initWithWordListAndLetterPoint:wordList LetterPoints:letterPoints];
    NSArray *test = [comp stringToArray:word];
    for (NSString *i in test){
        if ([i isEqualToString:letter]) {
            returnValue = true;
        }
    }
    return returnValue;
}

@end
