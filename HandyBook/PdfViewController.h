//
//  PdfViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfView.h"
#import "PdfPageSelector.h"
#import "PdfOptionsViewController.h"
#import "PdfDelegate.h"

typedef enum {
	kActionPopoverNone = -1,
	kActionPopoverOptions,
	kActionPopoverActions,
	kActionPopoverBookmarks,
	kActionPopoverNotes,
	kActionPopoverSearch
} ActionPopoverType;

typedef enum {
	kReadMode = 0,
	kNoteMode
} Mode;

@class Document;


@interface PdfViewController : UIViewController
<UIPopoverControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, PdfDelegate> {
	UISlider *m_slider;
	PdfView *m_pdfView;
	int m_currentPage;
	CGPDFDocumentRef m_currentDocumentRef;
	
	int m_numberOfPages;
	double m_pageHeight;
	PdfOptionsViewController *m_actionsViewController;
	
	BOOL m_lock;
	
	UIBarButtonItem *m_bookmarkButtonItem;
	
	ActionPopoverType m_lastShownPopoveryType;
	Mode m_mode;
	NSMutableArray *m_notesViews;
	NSTimer *m_helpPopupTimer;
	UIView *m_helpPopupView;
	NSTimer *m_pageNumberLabelTimer;
	UIPopoverController *m_popoverController;
	
	Document *m_document;
	
	UIToolbar *m_rightBarButtonItem;
	
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fileName;

+ (PdfViewController *)sharedInstance;
- (void)reloadDocument;

@end
