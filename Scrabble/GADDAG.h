//
//  GADDAG.h
//  Scrabble
//
//  Created by Michael on 11/21/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTWord.h"

@interface GADDAG : NSObject

- (id)initWithBoard:(NSMutableArray *)boardRef hand:(NSMutableArray *)handRef;
- (SMTWord *)bestMove;

@end
