//
//  AddNoteDialog.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 06.11.12.
//
//

#import <UIKit/UIKit.h>
#import "PdfDelegate.h"

typedef enum {
	kNoteDialogNewNote = 0,
	kNoteDialogEditNote
} NoteDialogMode;

@interface AddNoteDialog : UIViewController {
	UITextView *m_textView;
	NSTimeInterval m_timestamp;
	id<PdfDelegate> m_delegate;
}

@property (nonatomic, assign) id<PdfDelegate> delegate;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) NoteDialogMode mode;
@property (nonatomic, assign) int noteIndex;

- (void)reset;
- (void)refresh;

@end
