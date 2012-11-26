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
@private NSOperationQueue *queue;
@private NSOperationQueue *writeData;
    
@private NSMutableArray *all;
    
}

- (id)initWithBoard:(NSMutableArray *)boardRef hand:(NSMutableArray *)handRef{
    /**
     Initialize the class and sets values
     returns self
     */
    if(self = [super init]){
        queue = [[NSOperationQueue alloc] init];
        writeData = [[NSOperationQueue alloc] init];
        wordList = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/dictionary.plist"];
        letterPoints = [[NSDictionary alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/letterPoints.plist"];
        layout = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/arrayLayout.plist"];
        Board = boardRef;
        Hand = handRef;
    }
    return self;
}

- (SMTWord *)bestMove{
    /**
     Scans Board and distributes blocks where cell has a value.
     */
    // Testing Code
    all = [[NSMutableArray alloc] init];
    for (int r = 0; r < 15; r++) {
        for (int c = 0; c < 15; c++) {
            if (![[[[Board objectAtIndex:r] objectAtIndex:c] stringValue] isEqualToString:@""]) {
                [queue addOperationWithBlock:^{
                    NSMutableArray *col = [self findInColumn:c atRow:r];
                    NSMutableArray *row = [self findInRow:r atColumn:c];
                    [writeData addOperationWithBlock:^{
                        [all addObjectsFromArray:col];
                        [all addObjectsFromArray:row];
                    }];
                }];
            }
        }
    }
    [queue waitUntilAllOperationsAreFinished];
    [writeData waitUntilAllOperationsAreFinished];
    SMTWord *best = all[0];
    for (SMTWord *s in all){
        //NSLog(@"%@ %@ %@", s.word, s.pointValue, s.hor ? @"Horizonal" : @"Vertical");
        if (best.pointValue < s.pointValue) {
            best = s;
        } else if (best.pointValue == s.pointValue){
            if (s.word.length > best.word.length) {
                best = s;
            }
        }
    }
    return best;
}



- (NSMutableArray *)findInColumn:(int)col atRow:(int)row{
    /**
     Looks is given column (col) and uses a variation of the GADDAG algorithm
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
        if ([self letter:letterAtCord isInWord:word] && [self fitsOnBoard:word row:row column:row isHorizonal:false]) {
            NSMutableArray *wordArray = [comp stringToArray:word];
            NSArray *hooks = [self getHooksFor:wordArray on:letterAtCord];
            for (NSNumber *hookIndex in hooks) {
                if (![hookIndex isEqualTo:[[NSNumber alloc] initWithInt:-1]]) {
                    int passed = 0;
                    bool hasBlank = false;
                    int total = (int)word.length;
                    for (int i = 0; i < wordArray.count; i++) {
                        int rowRef = i + row - [hookIndex intValue];
                        if (rowRef < 14){
                            if ([[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:[wordArray objectAtIndex:i]] || ([[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:@""] && [self checkRowWithValue:[wordArray objectAtIndex:i] atRow:rowRef atCol:col])) {
                                if ([[[[Board objectAtIndex:rowRef] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                                    passed++;
                                    hasBlank = true;
                                } else {
                                    passed++;
                                }
                            }
                            if (i == wordArray.count - 1) {
                                if (passed == total && hasBlank) {
                                    if (rowRef < 14) {
                                        if ([[[[Board objectAtIndex:rowRef+1] objectAtIndex:col] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row] objectAtIndex:row - 1] stringValue] isEqualToString:@""]) {
                                            SMTWord *tmp = [[SMTWord alloc] initWithWord:word row:(row - [hookIndex intValue]) column:col isHorizonal:false];
                                            [allSMTWords addObject:tmp];
                                        }
                                    } else {
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
    }
    // Print out words
    return allSMTWords;
}

- (NSMutableArray *)findInRow:(int)row atColumn:(int)col{
    /**
     Looks is given row (row) and used a variation of the GADDAG algorithm
     */
    NSString *letterAtCord = [[[Board objectAtIndex:row] objectAtIndex:col] stringValue];
    NSMutableArray *newHand = [[NSMutableArray alloc] initWithArray:Hand];
    for (int i = 0; i <= 14; i++){
        if (![[[[Board objectAtIndex:row] objectAtIndex:i] stringValue] isEqualTo:@""]) {
            [newHand addObject:[[[Board objectAtIndex:row] objectAtIndex:i] stringValue]];
        }
    }
    Scrabble *comp = [[Scrabble alloc] initWithWordListAndLetterPoint:wordList LetterPoints:letterPoints];
    NSArray *allWords = [comp anagramArrayFromCharacterArray:newHand fixedChars:@[]];
    NSMutableArray *allSMTWords = [[NSMutableArray alloc] init];
    for (NSString *word in allWords){
        if ([self letter:letterAtCord isInWord:word] && [self fitsOnBoard:word row:row column:row isHorizonal:true]) {
            NSMutableArray *wordArray = [comp stringToArray:word];
            NSArray *hooks = [self getHooksFor:wordArray on:letterAtCord];
            for (NSNumber *hookIndex in hooks) {
                if (![hookIndex isEqualTo:[[NSNumber alloc] initWithInt:-1]]) {
                    int passed = 0;
                    bool hasBlank = false;
                    int total = (int)word.length;
                    for (int i = 0; i < wordArray.count; i++) {
                        int colRef = i + row - [hookIndex intValue];
                        if (colRef < 14){
                            if ([[[[Board objectAtIndex:row] objectAtIndex:colRef] stringValue] isEqualToString:[wordArray objectAtIndex:i]] || ([[[[Board objectAtIndex:row] objectAtIndex:colRef] stringValue] isEqualToString:@""] && [self checkColumnWithValue:[wordArray objectAtIndex:i] atRow:row atCol:colRef])) {
                                if ([[[[Board objectAtIndex:row] objectAtIndex:colRef] stringValue] isEqualToString:@""]) {
                                    passed++;
                                    hasBlank = true;
                                } else {
                                    passed++;
                                }
                            }
                            if (i == wordArray.count - 1) {
                                if (passed == total && hasBlank) {
                                    if (colRef < 14) {
                                        if ([[[[Board objectAtIndex:row] objectAtIndex:colRef + 1] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row] objectAtIndex:col - 1] stringValue] isEqualToString:@""]) {
                                            SMTWord *tmp = [[SMTWord alloc] initWithWord:word row:row column:(col - [hookIndex intValue]) isHorizonal:true];
                                            [allSMTWords addObject:tmp];
                                        } else {
                                            SMTWord *tmp = [[SMTWord alloc] initWithWord:word row:row column:(col - [hookIndex intValue]) isHorizonal:true];
                                            [allSMTWords addObject:tmp];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // Print out words
    return  allSMTWords;
}

- (bool)fitsOnBoard:(NSString *)word row:(int)r column:(int)c isHorizonal:(bool)hor{
    if (hor) {
        int len = (int)word.length;
        if (r + len > 14) {
            return false;
        } else {
            return  true;
        }
    } else {
        int len = (int)word.length;
        if (c + len > 14) {
            return false;
        } else {
            return  true;
        }
    }
    return nil;
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

- (bool)checkRowWithValue:(NSString *)letter atRow:(int)row atCol:(int)col{
    @try {
        if ([[[[Board objectAtIndex:row] objectAtIndex:col - 1] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row] objectAtIndex:col + 1] stringValue] isEqualToString:@""]) {
            // If both are blank
            return true;
        } else if ([[[[Board objectAtIndex:row] objectAtIndex:col - 1] stringValue] isEqualToString:@""] && ![[[[Board objectAtIndex:row] objectAtIndex:col + 1] stringValue] isEqualToString:@""]){
            // Only left is blank
            NSString *word = letter;
            int i = 1;
            while ([[[[Board objectAtIndex:row] objectAtIndex:col + i] stringValue] isEqualToString:@""]){
                word = [word stringByAppendingString:[[[Board objectAtIndex:row] objectAtIndex:col + i] stringValue]];
                i++;
            }
            return [self isWordInDictionary:word];
        } else if (![[[[Board objectAtIndex:row] objectAtIndex:col - 1] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row] objectAtIndex:col + 1] stringValue] isEqualToString:@""]){
            // Only right is blank
            NSString *word = letter;
            int i = 1;
            while ([[[[Board objectAtIndex:row] objectAtIndex:col - i] stringValue] isEqualToString:@""]) {
                word = [[NSString alloc] initWithFormat:@"%@%@", [[[Board objectAtIndex:row] objectAtIndex:col - i] stringValue], word];
                i++;
            }
            return [self isWordInDictionary:word];
        } else if (![[[[Board objectAtIndex:row] objectAtIndex:col - 1] stringValue] isEqualToString:@""] && ![[[[Board objectAtIndex:row] objectAtIndex:col + 1] stringValue] isEqualToString:@""]){
            // Both are not blank
            NSString *letter = @"";
            int i = 1;
            // Left Side
            NSString *left = @"";
            while ([[[[Board objectAtIndex:row] objectAtIndex:col + i] stringValue] isEqualToString:@""]){
                left = [left stringByAppendingString:[[[Board objectAtIndex:row] objectAtIndex:col + i] stringValue]];
                i++;
            }
            // Right Side
            NSString *right = @"";
            i = 0;
            while ([[[[Board objectAtIndex:row] objectAtIndex:col - i] stringValue] isEqualToString:@""]) {
                right = [[NSString alloc] initWithFormat:@"%@%@", [[[Board objectAtIndex:row] objectAtIndex:col - i] stringValue], right];
                i++;
            }
            NSString *word = [[NSString alloc] initWithFormat:@"%@%@%@", left, letter, right];
            return [self isWordInDictionary:word];
        }
        return false;
    }
    @catch (NSException *e) {
        return false;
    }
}

- (bool)checkColumnWithValue:(NSString *)letter atRow:(int)row atCol:(int)col{
    @try {
        if ([[[[Board objectAtIndex:row - 1] objectAtIndex:col] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row + 1] objectAtIndex:col] stringValue] isEqualToString:@""]) {
            // If both are blank
            return true;
        } else if ([[[[Board objectAtIndex:row - 1] objectAtIndex:col] stringValue] isEqualToString:@""] && ![[[[Board objectAtIndex:row + 1] objectAtIndex:col] stringValue] isEqualToString:@""]){
            // Only left is blank
            NSString *word = letter;
            int i = 1;
            while ([[[[Board objectAtIndex:row + i] objectAtIndex:col] stringValue] isEqualToString:@""]){
                word = [word stringByAppendingString:[[[Board objectAtIndex:row + i] objectAtIndex:col] stringValue]];
                i++;
            }
            return [self isWordInDictionary:word];
        } else if (![[[[Board objectAtIndex:row - 1] objectAtIndex:col] stringValue] isEqualToString:@""] && [[[[Board objectAtIndex:row + 1] objectAtIndex:col] stringValue] isEqualToString:@""]){
            // Only right is blank
            NSString *word = letter;
            int i = 1;
            while ([[[[Board objectAtIndex:row - i] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                word = [[NSString alloc] initWithFormat:@"%@%@", [[[Board objectAtIndex:row - 1] objectAtIndex:col] stringValue], word];
                i++;
            }
            return [self isWordInDictionary:word];
        } else if (![[[[Board objectAtIndex:row - 1] objectAtIndex:col] stringValue] isEqualToString:@""] && ![[[[Board objectAtIndex:row + 1] objectAtIndex:col] stringValue] isEqualToString:@""]){
            // Both are not blank
            NSString *letter = @"";
            int i = 1;
            // Left Side
            NSString *left = @"";
            while ([[[[Board objectAtIndex:row + i] objectAtIndex:col] stringValue] isEqualToString:@""]){
                left = [left stringByAppendingString:[[[Board objectAtIndex:row + i] objectAtIndex:col] stringValue]];
                i++;
            }
            // Right Side
            NSString *right = @"";
            i = 0;
            while ([[[[Board objectAtIndex:row - i] objectAtIndex:col] stringValue] isEqualToString:@""]) {
                right = [[NSString alloc] initWithFormat:@"%@%@", [[[Board objectAtIndex:row - i] objectAtIndex:col] stringValue], right];
                i++;
            }
            NSString *word = [[NSString alloc] initWithFormat:@"%@%@%@", left, letter, right];
            return [self isWordInDictionary:word];
        }
        return false;
    }
    @catch (NSException *e) {
        return false;
    }
}

- (bool)isWordInDictionary:(NSString *)word{
    bool isWord = false;
    for (NSString *dic in wordList){
        if([word isEqualToString:dic]){
            isWord = true;
            break;
        }
    }
    return isWord;
}


@end
