//
//  Scrabble.h
//  Scrabble
//
//  Created by Michael on 11/14/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scrabble : NSObject

/**
 Load object with Word list and Letter Point referances
 */
- (id) initWithWordListAndLetterPoint:(NSArray *)WordList LetterPoints:(NSDictionary *)LetterPoints;

/**
 Finds and returns an array of words that are anagrams of the letters in the characters array with fixed charactors.
 */
- (NSArray *)anagramArrayFromCharacterArray:(NSMutableArray *)characters fixedChars:(NSArray *)arrayRef;

/**
 Takes a string and turns it into a charactor array
 */
- (NSMutableArray *)stringToArray:(NSString *)str;

/**
 Returns the point value of a word as a NSString
 */
- (NSNumber *)pointValueFromString:(NSString *)str;

/**
 Returns the point value of a word as a charator array
 */
- (NSNumber *)pointValueFromArray:(NSMutableArray *)array;

/**
 Takes a charactor array and converts it into a string
 */
- (NSString *)arrayToString:(NSArray *)array;

/**
 returns a dictionary containing all the values from a word array and their point value
 */
- (NSMutableDictionary *)dictionaryFromArrayWithPointValues:(NSArray *)array;

/**
 returns the best point value from a dictonary where key -> word and value -> point value
 */
- (NSArray *)getBestFromDictionary:(NSMutableDictionary *)diction;


@end
