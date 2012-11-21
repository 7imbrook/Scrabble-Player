//
//  SMTWord.m
//  Scrabble
//
//  Created by Michael on 11/19/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "SMTWord.h"

@implementation SMTWord {

@public NSNumber *row;
@public NSNumber *column;
@public NSString *word;
    
}

- (id) initWithWord:(NSString *)wordRef row:(int)rowRef column:(int)columnRef {
    /**
     Creates a SMTWord object with a row, column and word string
     */
    if (self = [super init]) {
        row = [[NSNumber alloc] initWithInt:rowRef];
        column = [[NSNumber alloc] initWithInt:columnRef];
        word = wordRef;
    }
    return self;
}


@end
