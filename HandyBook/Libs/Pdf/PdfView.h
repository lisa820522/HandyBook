//
//  PdfView.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 12.11.12.
//
//

#import <UIKit/UIKit.h>
#import "PdfPageView.h"

@interface PdfView : UIScrollView <UIScrollViewDelegate> {
	UIView *m_contentView;
	NSMutableSet *m_visiblePages;
	NSMutableSet *m_recycledPages;
	CGSize m_pageSize;
	int m_numberOfPages;
	CGPDFDocumentRef m_document;
	UILabel *m_pageNumberLabel;
	NSMutableArray *m_pages;
	NSString *m_keyword;
	BOOL m_searchLock;
	NSMutableArray *m_searchQueue;
	CGFloat m_totalHeight;
	CGFloat m_maxWidth;
	BOOL m_stop;
}

@property (nonatomic, retain) UIView *contentView;

- (void)setDocument:(CGPDFDocumentRef)document;
- (void)showPageLabel:(BOOL)show;

@end
