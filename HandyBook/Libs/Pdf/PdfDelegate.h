//
//  ProceduralDelegate.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 22.10.12.
//
//

#import <UIKit/UIKit.h>

@class Bookmark;
@class Note;

@protocol PdfDelegate <NSObject>

- (int)pagesCount;
- (int)currentPage;
- (void)jumpToPage:(int)page;

- (int)bookmarksCount;
- (void)addBookmark;
- (void)removeBookmarkWithIndex:(int)index;
- (void)openBookmark:(int)bookmarkNumber;
- (Bookmark *)bookmarkAtIndex:(int)index;

- (int)notesCount;
- (Note *)noteByIndex:(int)index;
- (void)cancelNote;
- (void)addNote:(CGPoint)point withText:(NSString *)text timestamp:(NSTimeInterval)timestamp;
- (void)editNoteAtIndex:(int)index point:(CGPoint)point text:(NSString *)text timestamp:(NSTimeInterval)timestamp;
- (void)removeNoteWithIndex:(int)index;
- (void)openNoteAtIndex:(int)index;

@end