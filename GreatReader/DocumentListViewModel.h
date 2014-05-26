//
//  DocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;
@class PDFRecentDocumentList;

@interface DocumentListViewModel : NSObject
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
- (instancetype)initWithDocumentList:(PDFRecentDocumentList *)documentList;
- (NSString *)title;
- (NSUInteger)count;
- (PDFDocument *)documentAtIndex:(NSUInteger)index;
@end