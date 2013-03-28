//
//  PdfView.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 12.11.12.
//
//

#import "PdfView.h"

@implementation PdfView

@synthesize contentView = m_contentView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		m_recycledPages = [[NSMutableSet alloc] init];
		m_visiblePages = [[NSMutableSet alloc] init];
		m_pages = [[NSMutableArray alloc] init];
		m_pageSize = CGSizeZero;
		
		UIView *view = [self contentView];
		view.frame = frame;
		view.backgroundColor = [UIColor clearColor];
		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.contentView = view;
		[self addSubview:view];
		
		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [doubleTap release];
		
		self.delegate = self;
		self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
		self.maximumZoomScale = 5.0;
		self.multipleTouchEnabled = YES;
		self.userInteractionEnabled = YES;
		
		m_pageNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		m_pageNumberLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
		[m_pageNumberLabel.layer setCornerRadius:10];
		m_pageNumberLabel.text = @"";
		m_pageNumberLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
		[self addSubview:m_pageNumberLabel];
		m_pageNumberLabel.hidden = YES;
		m_maxWidth = 1;
    }
    return self;
}

- (void)dealloc
{
	[m_contentView release];
	[m_pageNumberLabel release];
	[super dealloc];
}

- (UIView *)contentView
{
	if (!m_contentView)
	{
		m_contentView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	return m_contentView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return m_contentView;
}

- (void)layoutSubviews
{
	float zoom = self.zoomScale;
	float contentHeight = 0;
	PdfPage *pdfPage;
	PdfPage *prevPdfPage;
	
	for (int i = 0; i < m_numberOfPages; i++) {
		pdfPage = [m_pages objectAtIndex:i];
		contentHeight += [pdfPage height]*pdfPage.scale*zoom + 5;
	}
	
	self.contentSize = CGSizeMake(zoom*self.bounds.size.width, contentHeight);
	
	for (int i = 0; i < m_numberOfPages; i++) {
		pdfPage = [m_pages objectAtIndex:i];
		if (i != 0) {
			prevPdfPage = [m_pages objectAtIndex:i-1];
			pdfPage.offset = 5 + prevPdfPage.offset + prevPdfPage.height*prevPdfPage.scale;
		} else {
			pdfPage.offset = 0;
		}
	}
	
	int currentPageIndex = [self currentPageIndex];
	
	NSMutableArray *visibleIndexes = [[NSMutableArray alloc] init];
	[visibleIndexes addObject:[NSNumber numberWithInt:currentPageIndex]];
	
	if (currentPageIndex > 0) {
		int i = currentPageIndex-1;
		pdfPage = [m_pages objectAtIndex:i];
		while (((pdfPage.offset+pdfPage.height*pdfPage.scale)*zoom >= self.contentOffset.y) && (i > 0)) {
			[visibleIndexes addObject:[NSNumber numberWithInt:i]];
			i--;
			pdfPage = [m_pages objectAtIndex:i];
		}
		pdfPage = [m_pages objectAtIndex:i];
		if ((pdfPage.offset+pdfPage.height*pdfPage.scale)*zoom >= self.contentOffset.y) {
			[visibleIndexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	
	if (currentPageIndex < m_numberOfPages-1) {
		int i = currentPageIndex+1;
		pdfPage = [m_pages objectAtIndex:i];
		while ((pdfPage.offset*zoom <= (self.contentOffset.y + self.bounds.size.height)) && (i < m_numberOfPages-1)) {
			[visibleIndexes addObject:[NSNumber numberWithInt:i]];
			i++;
			pdfPage = [m_pages objectAtIndex:i];
		}
		pdfPage = [m_pages objectAtIndex:i];
		if (pdfPage.offset*zoom <= (self.contentOffset.y + self.bounds.size.height)) {
			[visibleIndexes addObject:[NSNumber numberWithInt:i]];
		}
		if (i < m_numberOfPages-1) {
			[visibleIndexes addObject:[NSNumber numberWithInt:i+1]];
		}
	}
	
	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
	[visibleIndexes sortUsingDescriptors:[NSArray arrayWithObject:sort]];
	
	BOOL visible;
	for (PdfPageView *p in m_visiblePages) {
		visible = NO;
		for (NSNumber *index in visibleIndexes) {
			if ([index integerValue] == p.pageIndex) {
				visible = YES;
				break;
			}
		}
		if (!visible) {
			[m_recycledPages addObject:p];
			[p removeFromSuperview];
		}
	}
	[m_visiblePages minusSet:m_recycledPages];
	for (PdfPageView *p in m_visiblePages) {
		p.frame = CGRectMake(0,
							 p.pdfPage.offset,
							 self.bounds.size.width,
							 [p.pdfPage height]*p.pdfPage.scale);
		[p setNeedsDisplay];
	}
	
	for (NSNumber *idx in visibleIndexes) {
		int i = [idx intValue];
		if ([self isShowingPageForIndex:i]) {
			continue;
		}
		PdfPageView *pageView = [self dequeueRecycledPage];
		if (!pageView)
		{
			pageView = [[[PdfPageView alloc] initWithFrame:CGRectZero] autorelease];
		}
		pageView.pageIndex = i;
		CGPDFPageRef pdfPageRef = CGPDFDocumentGetPage(m_document, i + 1);
		[pageView setPdfPageRef:pdfPageRef];
		pageView.pdfPage = [m_pages objectAtIndex:i];
		
		pageView.frame = CGRectMake(0,
									pageView.pdfPage.offset,
									self.bounds.size.width,
									[pageView.pdfPage height]*pageView.pdfPage.scale);
		
        [m_visiblePages addObject:pageView];
		[pageView setNeedsDisplay];
        
		[m_contentView addSubview:pageView];
	}
	
	[visibleIndexes release];
	
	m_contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
	
	CGSize size = [m_pageNumberLabel.text sizeWithFont:m_pageNumberLabel.font constrainedToSize:CGSizeMake(200, 40)];
	m_pageNumberLabel.frame = CGRectMake(10, 20+self.contentOffset.y, size.width, size.height);
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	PdfPage *pdfPage;
	for (int i = 0; i < m_numberOfPages; i++) {
		pdfPage = [m_pages objectAtIndex:i];
		pdfPage.scale = self.bounds.size.width / [pdfPage width];
	}
	[self layoutSubviews];
}

- (void)showPageLabel:(BOOL)show
{
	if (show) {
		m_pageNumberLabel.text = [NSString stringWithFormat:@" %d/%d ",[self currentPageIndex]+1,m_numberOfPages];
		m_pageNumberLabel.hidden = NO;
	} else {
		m_pageNumberLabel.hidden = YES;
	}
}

- (int)currentPageIndex
{
	int i = 0;
	float offset = 0;
	PdfPage *pdfPage;
	float zoom = self.zoomScale;
	float pageScale;
	while (i < m_numberOfPages && self.contentOffset.y > offset) {
		pdfPage = [m_pages objectAtIndex:i];
		pageScale = self.bounds.size.width / [pdfPage width];
		offset += (5 + zoom*pageScale*pdfPage.height);
		i++;
	}
	if ((offset - self.contentOffset.y) < self.bounds.size.height/2) {
		i++;
	}
	if (i != 0) i--;
	return i;
}

- (void)didDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (self.zoomScale == 1) {
		float zoomScale = 1.5;
		[self setZoomScale:zoomScale animated:YES];
	} else {
		[self setZoomScale:1 animated:YES];
	}
}

- (void)setDocument:(CGPDFDocumentRef)document
{
	CGPDFDocumentRelease(m_document);
	m_document = CGPDFDocumentRetain(document);
	m_numberOfPages = CGPDFDocumentGetNumberOfPages(m_document);
	CGPDFPageRef pdfPageRef;
	PdfPage *pdfPage;
	PdfPage *lastPage;
	m_maxWidth = 0;
	m_totalHeight = 0;
	for (int i = 1; i <= m_numberOfPages; i++) {
		pdfPageRef = CGPDFDocumentGetPage(m_document, i);
		pdfPage = [[PdfPage alloc] initWithPage:pdfPageRef];
		lastPage = [m_pages lastObject];
		if (i != 1) {
			pdfPage.offset = 5 + lastPage.offset + lastPage.height;
		} else {
			pdfPage.offset = 0;
		}
		[m_pages addObject:pdfPage];
		if ([pdfPage width] > m_maxWidth) {
			m_maxWidth = [pdfPage width];
		}
		m_totalHeight += [pdfPage height];
	}
	[self reloadData];
}

- (CGPDFPageRef)pdfPageAtIndex:(int)index
{
	return CGPDFDocumentGetPage(m_document, index+1);
}

- (PdfPageView *)dequeueRecycledPage
{
	@synchronized (self)
	{
		PdfPageView *p = [m_recycledPages anyObject];
		if (p)
		{
			[[p retain] autorelease];
			[m_recycledPages removeObject:p];
		}
		return p;
	}
}

- (void)reloadData
{
	for (PdfPageView *p in m_visiblePages)
	{
		[p removeFromSuperview];
	}
	[m_recycledPages unionSet:m_visiblePages];
	[m_visiblePages removeAllObjects];
	[self setNeedsLayout];
}

- (BOOL)isShowingPageForIndex:(NSInteger)index
{
    for (PdfPageView *p in m_visiblePages)
    {
        if (p.pageIndex == index)
        {
            return YES;
        }
    }
    return NO;
}

@end
