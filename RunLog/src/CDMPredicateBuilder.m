//
//  CDMPredicateBuilder.m
//  RunLog
//
//  Created by Uwe Hoffmann on 12/21/10.
//  Copyright (c) 2010 codemanic. All rights reserved.
//

#import "CDMPredicateBuilder.h"

@interface ParserTarget : NSObject <NSCopying> {
  NSPredicate *predicate;
  BOOL isComplement;
  NSUInteger limit;
}

@property (nonatomic, retain) NSPredicate *predicate;
@property (nonatomic, assign) BOOL isComplement;
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, retain) NSSortDescriptor *sortDescriptor;

+ (id)target;

@end

@implementation ParserTarget

@synthesize predicate, isComplement, limit;

+ (id)target {
  return [[[ParserTarget alloc] init] autorelease];
}

- (id)init {
  if((self = [super init])) {
  }
  return self;
}

- (void)dealloc {
  [predicate release];
  [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
  ParserTarget *copy = [[ParserTarget alloc] init];
  copy.predicate = [predicate copyWithZone:zone];
  return copy;
}

@end

@interface CDMPredicateBuilder(Parser)

/*
 
 Examples:
 
 fastest 2 in May 2010
 slowest 3
 first 2
 last 2
 last month
 last week
 last year
 longer than 5 km
 shorter than 20 min
 all but last 2
 all but slowest, fastest
 
 Grammar:
 
 date -> "in" <rest of input>
 
 top -> ("fastest" | "slowest" | "first" | "last") (INT | "month" | "week" | "year")?
 
 rangeleaf -> ("longer" | "shorter") "than" INT ("km" | "min")
 
 range -> rangeleaf ("and" rangeleaf)*
 
 leaf -> (top | range)
 
 composite -> ("all" "but")? leaf ("," leaf)* (date)?
 
 */ 

- (PKParser *)newParser;
- (PKParser *)dateParser;
- (PKParser *)topParser;
- (PKParser *)rangeLeafParser;
- (PKParser *)rangeParser;
- (PKParser *)leafParser;
- (PKParser *)compositeParser;

@end

@interface CDMPredicateBuilder(Assembler)

- (void)workOnAllButAssembly:(PKAssembly *)assembly;
- (void)workOnRangeLeafAssembly:(PKAssembly *)assembly;
- (void)workOnTopAssembly:(PKAssembly *)assembly;

@end

@implementation CDMPredicateBuilder

- (id)initWithEntity:(NSEntityDescription *)anEntity {
  if ((self = [super init])) {
    parser = [self newParser];
    entity = [anEntity retain];
  }
  
  return self;
}

- (void)dealloc {
  [parser release];
  [entity release];
  [super dealloc];
}

- (NSFetchRequest *)buildFromQuery:(NSString *)query {
  PKTokenAssembly *assembly = [PKTokenAssembly assemblyWithString:query];
  [assembly setTarget:[ParserTarget target]];
    
  PKAssembly *parsedAssembly = [parser completeMatchFor:assembly];
  NSLog(@"assembly: %@, parsed: %@", assembly, parsedAssembly);
  
  if (parsedAssembly == nil) {
    NSLog(@"parse failed");
    return nil;
  }
  
  NSLog(@"parsed successfully");
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  
  ParserTarget *target = [parsedAssembly target];
  [fetchRequest setEntity:entity];
  [fetchRequest setPredicate:[target predicate]];
  
  if (target.limit > 0) {
    [fetchRequest setFetchLimit:target.limit];
  }
  
  if (target.sortDescriptor != nil) {
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:target.sortDescriptor]];
  }
  return fetchRequest;
}

#pragma mark parser

- (PKParser *)newParser {
  return [[self compositeParser] retain];  
}

- (PKParser *)dateParser {
  PKSequence *dateParser = [PKSequence sequence];
  [dateParser add:[PKCaseInsensitiveLiteral literalWithString:@"in"]];
  [dateParser add:[PKRepetition repetitionWithSubparser:[PKAny any]]];
  return dateParser;
}

- (PKParser *)topParser {
  PKAlternation *attributeParser = [PKAlternation alternation];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"fastest"]];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"slowest"]];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"longest"]];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"shortest"]];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"first"]];
  [attributeParser add:[PKCaseInsensitiveLiteral literalWithString:@"last"]];
  
  PKAlternation *optionalQuantifierParser = [PKAlternation alternation];
  [optionalQuantifierParser add:[PKCaseInsensitiveLiteral literalWithString:@"month"]];
  [optionalQuantifierParser add:[PKCaseInsensitiveLiteral literalWithString:@"week"]];
  [optionalQuantifierParser add:[PKCaseInsensitiveLiteral literalWithString:@"year"]];
  [optionalQuantifierParser add:[PKNumber number]];
  [optionalQuantifierParser add:[PKEmpty empty]];
  
  PKSequence *topParser = [PKSequence sequence];
  [topParser add:attributeParser];
  [topParser add:optionalQuantifierParser];
  [topParser setAssembler:self selector:@selector(workOnTopAssembly:)];
  return topParser;
}

- (PKParser *)rangeLeafParser {
  PKAlternation *compareParser = [PKAlternation alternation];
  [compareParser add:[PKCaseInsensitiveLiteral literalWithString:@"longer"]];
  [compareParser add:[PKCaseInsensitiveLiteral literalWithString:@"shorter"]];

  PKAlternation *unitParser = [PKAlternation alternation];
  [unitParser add:[PKCaseInsensitiveLiteral literalWithString:@"km"]];
  [unitParser add:[PKCaseInsensitiveLiteral literalWithString:@"min"]];

  PKSequence *rangeLeafParser = [PKSequence sequence];
  [rangeLeafParser add:compareParser];
  [rangeLeafParser add:[[PKCaseInsensitiveLiteral literalWithString:@"than"] discard]];
  [rangeLeafParser add:[PKNumber number]];
  [rangeLeafParser add:unitParser];
  [rangeLeafParser setAssembler:self selector:@selector(workOnRangeLeafAssembly:)];
  return rangeLeafParser;
}

- (PKParser *)rangeParser {
  PKSequence *andParser = [PKSequence sequence];
  [andParser add:[PKCaseInsensitiveLiteral literalWithString:@"and"]];
  [andParser add:[self rangeLeafParser]];
    
  PKSequence *rangeParser = [PKSequence sequence];
  [rangeParser add:[self rangeLeafParser]];
  [rangeParser add:[PKRepetition repetitionWithSubparser:andParser]];

  return rangeParser;
}

- (PKParser *)leafParser {
  PKAlternation *leafParser = [PKAlternation alternation];
  [leafParser add:[self topParser]];
  [leafParser add:[self rangeParser]];
  return leafParser;
}

- (PKParser *)compositeParser {
  PKSequence *allButParser = [PKSequence sequence];
  [allButParser add:[[PKCaseInsensitiveLiteral literalWithString:@"all"] discard]];
  [allButParser add:[[PKCaseInsensitiveLiteral literalWithString:@"but"] discard]];
  [allButParser setAssembler:self selector:@selector(workOnAllButAssembly:)];
  
  PKAlternation *optionalComplementParser = [PKAlternation alternation];
  [optionalComplementParser add:allButParser];
  [optionalComplementParser add:[PKEmpty empty]];
  
  PKSequence *commaLeaf = [PKSequence sequence];
  [commaLeaf add:[PKCaseInsensitiveLiteral literalWithString:@","]];
  [commaLeaf add:[self leafParser]];
  
  PKAlternation *optionalDate = [PKAlternation alternation];
  [optionalDate add:[self dateParser]];
  [optionalDate add:[PKEmpty empty]];
  
  PKSequence *compositeParser = [PKSequence sequence];
  [compositeParser add:optionalComplementParser];
  [compositeParser add:[self leafParser]];
  [compositeParser add:[PKRepetition repetitionWithSubparser:commaLeaf]];
  [compositeParser add:optionalDate];
  
  return compositeParser;
}

#pragma mark assembly

- (void)workOnAllButAssembly:(PKAssembly *)assembly {
  ParserTarget *target = (ParserTarget *)[assembly target];
  target.isComplement = YES;
}

- (void)workOnRangeLeafAssembly:(PKAssembly *)assembly {
  PKToken *unitToken = [assembly pop];
  PKToken *valueToken = [assembly pop];
  PKToken *opToken = [assembly pop];
  
  NSExpression *lhs;
  
  if ([[unitToken stringValue] caseInsensitiveCompare:@"km"] == NSOrderedSame) {
    lhs = [NSExpression expressionForKeyPath:@"distance"];
  } else {
    lhs = [NSExpression expressionForKeyPath:@"duration"];
  }
  
  NSExpression *rhs = [NSExpression expressionForConstantValue:[valueToken value]];
  NSPredicate *predicate;
  
  if ([[opToken stringValue] caseInsensitiveCompare:@"longer"] == NSOrderedSame) {
    predicate = [NSComparisonPredicate
                 predicateWithLeftExpression:lhs
                 rightExpression:rhs
                 modifier:NSDirectPredicateModifier
                 type:NSGreaterThanPredicateOperatorType
                 options:0];
  } else {
    predicate = [NSComparisonPredicate
                 predicateWithLeftExpression:lhs
                 rightExpression:rhs
                 modifier:NSDirectPredicateModifier
                 type:NSLessThanPredicateOperatorType
                 options:0];
  }
  
  ParserTarget *target = (ParserTarget *)[assembly target];
  target.predicate = predicate;
}

- (void)workOnTopAssembly:(PKAssembly *)assembly {
  PKToken *limitToken = nil;
  PKToken *sortToken = nil;
  
  limitToken = [assembly pop];
  
  if ([limitToken isNumber]) {
    sortToken = [assembly pop];
  } else {
    sortToken = limitToken;
    limitToken = nil;
  }
  ParserTarget *target = (ParserTarget *)[assembly target];
  
  if (limitToken != nil) {
    target.limit = [[limitToken value] unsignedIntegerValue]; 
  }
  
  if ([[sortToken stringValue] caseInsensitiveCompare:@"fastest"] == NSOrderedSame) {
    target.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pace" ascending:YES];
  } else if ([[sortToken stringValue] caseInsensitiveCompare:@"slowest"] == NSOrderedSame) {
    target.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pace" ascending:NO];
  } else if ([[sortToken stringValue] caseInsensitiveCompare:@"longest"] == NSOrderedSame) {
    target.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:NO];
  } else if ([[sortToken stringValue] caseInsensitiveCompare:@"shortest"] == NSOrderedSame) {
    target.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
  }
}

@end
