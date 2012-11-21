//
//  SMTWord.h
//  Scrabble
//
//  Created by Michael on 11/19/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMTWord : NSObject

/**
 Creates a SMTWord object with a row, column and word string
 */
- (id) initWithWord:(NSString *)wordRef row:(int)rowRef column:(int)columnRef;

@end
