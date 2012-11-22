//
//  SMTWord.m
//  Scrabble
//
//  Created by Michael on 11/19/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "SMTWord.h"

@implementation SMTWord {
    
@private NSDictionary *letterPoints;
@private NSMutableArray *boardWithModifiers;
    
}

@synthesize row;
@synthesize column;
@synthesize word;
@synthesize pointValue;
@synthesize hor;

- (id) initWithWord:(NSString *)wordRef row:(int)rowRef column:(int)columnRef isHorizonal:(bool)horRef{
    /**
     Creates a SMTWord object with a row, column and word string
     */
    if (self = [super init]) {
        row = [[NSNumber alloc] initWithInt:rowRef];
        column = [[NSNumber alloc] initWithInt:columnRef];
        word = wordRef;
        letterPoints = [[NSDictionary alloc]initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/letterPoints.plist"];
        hor = horRef;
        NSArray *modifierLayout = [[NSArray alloc] initWithContentsOfFile:@"/Users/timbrook480/Projects/Scrabble/arrayLayout.plist"];
        boardWithModifiers = [[NSMutableArray alloc] initWithObjects:
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
        for (int i = 0; i < 225; i++) {
            [[boardWithModifiers objectAtIndex:i/15] addObject:[modifierLayout objectAtIndex:i]];
        }
        pointValue = [self pointValueFromString:word];
    }
    return self;
}

- (NSNumber *)pointValueFromString:(NSString *)str{
    /**
     Returns the point value of a word as a NSString
     */
    return [self pointValueFromArray:[self stringToArray:str]];
}

- (NSNumber *)pointValueFromArray:(NSMutableArray *)array{
    /**
     Returns the point value of a word with board spaces factored in
     */
    int count = 0;
    int location = 0;
    int multiplyer = 1;
    if (hor) {
        for (NSString *l in array){
            NSLog(@"%@:%d", row, (location + [column intValue]));
            NSString *cellIdentifier = [[boardWithModifiers objectAtIndex:row.intValue] objectAtIndex:column.intValue+location];
            /**
             D = Double Word
             T = Triple Word
             d = double letter
             t = triple letter
             */
            if ([cellIdentifier isEqualToString:@""]) {
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"D"]) {
                multiplyer += 1;
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"T"]) {
                multiplyer += 2;
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"d"]) {
                count = count + ([letterPoints[l] floatValue] * 2);
            } else if ([cellIdentifier isEqualToString:@"t"]) {
                count = count + ([letterPoints[l] floatValue] * 3);
            }
            location++;
        }
    } else {
        for (NSString *l in array){
            NSString *cellIdentifier = [[boardWithModifiers objectAtIndex:row.intValue] objectAtIndex:column.intValue+location];
            /**
             D = Double Word
             T = Triple Word
             d = double letter
             t = triple letter
             */
            if ([cellIdentifier isEqualToString:@""]) {
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"D"]) {
                multiplyer += 1;
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"T"]) {
                multiplyer += 2;
                count = count + [letterPoints[l] floatValue];
            } else if ([cellIdentifier isEqualToString:@"d"]) {
                count = count + ([letterPoints[l] floatValue] * 2);
            } else if ([cellIdentifier isEqualToString:@"t"]) {
                count = count + ([letterPoints[l] floatValue] * 3);
            }
            location++;
        }
    }
    return [[NSNumber alloc] initWithInt:(count * multiplyer)];
}

- (NSMutableArray *)stringToArray:(NSString *)str {
    /**
     Takes a string and turns it into a charactor array
     */
    NSMutableArray *chars = [[NSMutableArray alloc] init];
    for(int index = 0; index<=[str length]-1; index++){
        NSString *testStr = [NSString stringWithFormat:@"%c", [str characterAtIndex:index]];
        [chars addObject:testStr];
    }
    return chars;
}

@end
