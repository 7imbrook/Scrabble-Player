//
//  Scrabble.m
//  Scrabble
//
//  Created by Michael on 11/14/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "Scrabble.h"
#import "SMTWord.h"

@implementation Scrabble{
    @private NSArray *wordList;
    @private NSDictionary *letterPoints;
}



- (id) initWithWordListAndLetterPoint:(NSArray *)WordList LetterPoints:(NSDictionary *)LetterPoints{
    /**
     Load object with Word list and Letter Point referances
     */
    if (self = [super init]) {
        wordList = [[NSArray alloc] initWithArray:WordList];
        letterPoints = [[NSDictionary alloc] initWithDictionary:LetterPoints];
    }
    return self;
}

- (bool)isFixedCharacter:(NSString *)check fixedChars:(NSArray *)fixedChars atIndex:(int)index {
    /**
     Takes a string to check and an NSArray of fixed charactors and checks to see if at index (int index) is a fixed charactor.
     */
    int fixCount = (int)fixedChars.count;
    if (index < fixCount) {
        if ([check isEqualTo:[fixedChars objectAtIndex:index]]) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

- (NSArray *)anagramArrayFromCharacterArray:(NSMutableArray *)characters fixedChars:(NSArray *)arrayRef {
    /**
     Finds and returns an array of words that are anagrams of the letters in the characters array with fixed charactors.
     */
    NSMutableArray *anagrams = [[NSMutableArray alloc] init];
    NSMutableArray *fixedChars = [arrayRef mutableCopy];
    for (NSString *word in wordList){
        int passed = 0;
        int fixedPassed = 0;
        NSMutableArray *inHand = [characters mutableCopy];
        NSMutableArray *dicLetters = [self stringToArray:word];
        int count = (int)dicLetters.count;
        for (int i = 0; i < count; i++) {
            if ([self isFixedCharacter:[dicLetters objectAtIndex:i] fixedChars:fixedChars atIndex:i]) {
                fixedPassed++;
            } else if ([self isVariableCharacter:[dicLetters objectAtIndex:i] characters:inHand]) {
                passed++;
            }
        }
        if (word.length == (passed + fixedPassed) && [self fixedElements:arrayRef] == fixedPassed) {
            [anagrams addObject:word];
        }
    }
    return anagrams;
}

- (bool)isVariableCharacter:(NSString *)check characters:(NSMutableArray *)chars {
    /**
     Checks to see if charactor is avaliable to be used in the word
     */
    int count = (int)chars.count;
    for (int i = 0; i < count; i++){
        if ([check isEqualTo:[chars objectAtIndex:i]]){
            [chars removeObjectAtIndex:i];
            return true;
        }
    }
    return false;
}

- (int)fixedElements:(NSArray *)array{
    /**
     Returns the number of fixed elements are in the fixed elements array
     */
    int total = 0;
    for (NSString *check in array){
        if (![check isEqualToString:@"none"]){
            total++;
        }
    }
    return total;
}

- (NSNumber *)pointValueFromString:(NSString *)str{
    /**
     Returns the point value of a word as a NSString
     */
    return [self pointValueFromArray:[self stringToArray:str]];
}

- (NSNumber *)pointValueFromArray:(NSMutableArray *)array{
    /**
     Returns the point value of a word as a charator array
     */
    NSNumber *count = 0;
    for (NSString *i in array){
        NSNumber *temp = letterPoints[i];
        count = @([count floatValue] + [temp floatValue]);
    }
    return count;
}

- (NSString *)arrayToString:(NSArray *)array{
    /**
     Takes a charactor array and converts it into a string
     */
    NSString *str = @"";
    for (NSString *i in array){
        str = [str stringByAppendingString:i];
    }
    return str;
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

- (NSMutableDictionary *)dictionaryFromArrayWithPointValues:(NSArray *)array{
    /**
     returns a dictionary containing all the values from a word array and their point value
     */
    NSMutableDictionary *NSDicValues = [[NSMutableDictionary alloc] init];
    for (NSString *add in array){
        [NSDicValues setObject:[self pointValueFromString:add] forKey:add];
    }
    return NSDicValues;
}

- (NSArray *)getBestFromDictionary:(NSMutableDictionary *)diction {
    /**
     returns the best point value from a dictonary where key -> word and value -> point value
     */
    NSArray *keyArray = [diction allKeys];
    NSString *bestKey = @"";
    for (int i = 0; i < keyArray.count; i++) {
        if ([[diction valueForKey:[keyArray objectAtIndex:i]] floatValue] > [[diction valueForKey:bestKey] floatValue]) {
            bestKey = [keyArray objectAtIndex:i];
        } else if ([[diction valueForKey:[keyArray objectAtIndex:i]] floatValue] == [[diction valueForKey:bestKey] floatValue]){
            if ([bestKey length] < [[keyArray objectAtIndex:i] length]) {
                bestKey = [keyArray objectAtIndex:i];
            }
        }
    }
    NSArray *bestPair = [[NSArray alloc] initWithObjects:bestKey, [diction valueForKey:bestKey], nil];
    return bestPair;
}

@end







