//
//  PdfPageSelector.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 02.11.12.
//
//

#import "PdfPageSelector.h"
#import <QuartzCore/QuartzCore.h>

@implementation PdfPageSelector

@synthesize pagesCount = m_pagesCount;
@synthesize scrollingHeight = m_scrollingHeight;
@synthesize selectedPageView = m_selectedPageView;
@synthesize currentPage = m_currentPage;
@synthesize thumbnailSize = m_thumbnailSize;
@synthesize thumbnailsCoordinates = m_thumbnailsCoordinates;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		m_thumbnailSize = CGSizeMake(MIN_THUMBNAIL_WIDTH, MIN_THUMBNAIL_HEIGHT);
		m_visibleThumbnailsCoordinates = [[NSMutableDictionary alloc] init];
		m_visibleThumbnailsIndexes = [[NSMutableArray alloc] init];
		m_thumbnailsCoordinates = [[NSMutableArray alloc] init];
		m_selectedPageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		m_selectedPageView.backgroundColor = [UIColor blackColor];
		m_selectedPageView.layer.borderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor;
		m_selectedPageView.layer.borderWidth = 1;
		[self addSubview:m_selectedPageView];
    }
    return self;
}

- (void)dealloc
{
	[m_visibleThumbnailsCoordinates release];
	[m_visibleThumbnailsIndexes release];
	[m_thumbnailsCoordinates release];
	[m_selectedPageView release];
	[super dealloc];
}

- (void)setThumbnailSize:(CGSize)thumbnailSize
{
	m_thumbnailSize = thumbnailSize;
	if (thumbnailSize.width > thumbnailSize.height) {
		m_selectedPageView.frame = CGRectMake(0, 16, 60, 45);
	} else {
		m_selectedPageView.frame = CGRectMake(5, 20 + thumbnailSize.height/2 - 33, 50, 66);
	}
	[self updateThumbnails];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self updateThumbnails];
}

- (void)updateThumbnails
{
	[m_thumbnailsCoordinates removeAllObjects];
	[m_visibleThumbnailsCoordinates removeAllObjects];
	[m_visibleThumbnailsIndexes removeAllObjects];
	
	m_visibleThumbnailsCount = (self.bounds.size.height - 32) / (self.thumbnailSize.height + 8);
	
	if (self.pagesCount < m_visibleThumbnailsCount) {
		m_visibleThumbnailsCount = self.pagesCount;
	}
	
	m_scrollingHeight = (self.thumbnailSize.height + 8) * (m_visibleThumbnailsCount-1);
	
	for (int i = 0; i < m_visibleThumbnailsCount-1; i++) {
		
		CGPoint imagePoint = CGPointMake((self.bounds.size.width - self.thumbnailSize.width)/2, 20 + (self.thumbnailSize.height+8)*i);
		
		[m_visibleThumbnailsIndexes addObject:[NSNumber numberWithInt:(int)(i*((double)m_pagesCount / m_visibleThumbnailsCount)+0.5)]];
		
		[m_visibleThumbnailsCoordinates setObject:[NSNumber numberWithFloat:imagePoint.y+self.thumbnailSize.height/2]
										   forKey:[NSNumber numberWithInt:(int)(i*((double)m_pagesCount / m_visibleThumbnailsCount)+0.5)]];
	}
	CGPoint imagePoint = CGPointMake((self.bounds.size.width - self.thumbnailSize.width)/2,
									 20 + (self.thumbnailSize.height+8)*(m_visibleThumbnailsCount-1));
	
	[m_visibleThumbnailsIndexes addObject:[NSNumber numberWithInt:(m_pagesCount-1)]];
	
	[m_visibleThumbnailsCoordinates setObject:[NSNumber numberWithFloat:imagePoint.y+self.thumbnailSize.height/2]
									   forKey:[NSNumber numberWithInt:(m_pagesCount-1)]];
	
	for (int i = 0; i < m_visibleThumbnailsCount - 1; i++) {
		int topIndex = [[m_visibleThumbnailsIndexes objectAtIndex:i] intValue];
		int bottomIndex = [[m_visibleThumbnailsIndexes objectAtIndex:i+1] intValue];
		float topCoord = [[m_visibleThumbnailsCoordinates objectForKey:[NSNumber numberWithInt:topIndex]] floatValue];
		float pxPerPage = (8 + (self.thumbnailSize.height/2 - 5)*2) / (bottomIndex - topIndex - 1);
		[m_thumbnailsCoordinates addObject:[m_visibleThumbnailsCoordinates objectForKey:[NSNumber numberWithInt:topIndex]]];
		for (int j = topIndex + 1; j < bottomIndex; j++) {
			float coordY = topCoord + 5 + pxPerPage*(j - topIndex - 1) + pxPerPage*0.5;
			[m_thumbnailsCoordinates addObject:[NSNumber numberWithFloat:coordY]];
		}
	}
	[m_thumbnailsCoordinates addObject:[NSNumber numberWithFloat:imagePoint.y+self.thumbnailSize.height/2]];
	
}

- (int)findPageNumberForYCoord:(CGFloat)y
{
	int pageNumber = 0;
	
	if (y <= [[m_thumbnailsCoordinates objectAtIndex:0] floatValue]) {
		return pageNumber;
	}
	
	if (y >= [[m_thumbnailsCoordinates lastObject] floatValue]) {
		pageNumber = m_pagesCount - 1;
		return pageNumber;
	}
	
	for (int i = 0; i < m_pagesCount - 1; i++) {
		if ((y >= [[m_thumbnailsCoordinates objectAtIndex:i] floatValue]) && (y < [[m_thumbnailsCoordinates objectAtIndex:i+1] floatValue])) {
			float delta = y - [[m_thumbnailsCoordinates objectAtIndex:i] floatValue];
			delta = delta - [[m_thumbnailsCoordinates objectAtIndex:i+1] floatValue];
			if (delta > 0) {
				pageNumber = i+1;
			} else {
				pageNumber = i;
			}
			break;
		}
	}
	
	return pageNumber;
}

- (void)reloadData
{
	[m_thumbnailsCoordinates removeAllObjects];
	[m_visibleThumbnailsCoordinates removeAllObjects];
	[m_visibleThumbnailsIndexes removeAllObjects];
	[self updateThumbnails];
	m_currentPage = 0;
	m_selectedPageView.center = CGPointMake(m_selectedPageView.center.x, [[m_thumbnailsCoordinates objectAtIndex:m_currentPage] floatValue]);
}

#pragma mark - Touch Staff

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
	[m_touchTimer invalidate];
	m_touchTimer = nil;
	
	m_currentPage = [self findPageNumberForYCoord:touchLocation.y];
	
	if (m_currentPage < 0) {
		m_currentPage = 0;
	}
	
	if (m_currentPage >= m_pagesCount) {
		m_currentPage = m_pagesCount - 1;
	}
	
	m_selectedPageView.image = [self.delegate thumbnailByIndex:m_currentPage];
	
	m_selectedPageView.center = CGPointMake(m_selectedPageView.center.x, [[m_thumbnailsCoordinates objectAtIndex:m_currentPage] floatValue]);
	m_lastTouch = touchLocation;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
	float pxPerPage = (m_scrollingHeight) / m_pagesCount;
	
	if (fabs(m_lastTouch.y - touchLocation.y) < pxPerPage) {
		[m_touchTimer invalidate];
		m_touchTimer = nil;
		m_touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changePage) userInfo:nil repeats:NO];
	} else {
		[m_touchTimer invalidate];
		m_touchTimer = nil;
	}
	
	m_currentPage = [self findPageNumberForYCoord:touchLocation.y];;
	
	if (m_currentPage < 0) {
		m_currentPage = 0;
	}
	
	if (m_currentPage >= m_pagesCount) {
		m_currentPage = m_pagesCount - 1;
	}
	
	m_selectedPageView.image = [self.delegate thumbnailByIndex:m_currentPage];
	
	m_selectedPageView.center = CGPointMake(m_selectedPageView.center.x, [[m_thumbnailsCoordinates objectAtIndex:m_currentPage] floatValue]);
	m_lastTouch = touchLocation;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
	[m_touchTimer invalidate];
	m_touchTimer = nil;
	
	m_currentPage = [self findPageNumberForYCoord:touchLocation.y];
	
	if (m_currentPage < 0) {
		m_currentPage = 0;
	}
	
	if (m_currentPage >= m_pagesCount) {
		m_currentPage = m_pagesCount - 1;
	}
	
	m_selectedPageView.image = [self.delegate thumbnailByIndex:m_currentPage];
	
	m_selectedPageView.center = CGPointMake(m_selectedPageView.center.x, [[m_thumbnailsCoordinates objectAtIndex:m_currentPage] floatValue]);
	
	[self changePage];
	m_lastTouch = touchLocation;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	
	[m_touchTimer invalidate];
	m_touchTimer = nil;
	
	m_currentPage = [self findPageNumberForYCoord:touchLocation.y];
	
	if (m_currentPage < 0) {
		m_currentPage = 0;
	}
	
	if (m_currentPage >= m_pagesCount) {
		m_currentPage = m_pagesCount - 1;
	}
	
	m_selectedPageView.image = [self.delegate thumbnailByIndex:m_currentPage];
	
	m_selectedPageView.center = CGPointMake(m_selectedPageView.center.x, [[m_thumbnailsCoordinates objectAtIndex:m_currentPage] floatValue]);
	
	[self changePage];
	m_lastTouch = touchLocation;
}

- (void)changePage
{
	[m_touchTimer invalidate];
	m_touchTimer = nil;
	[self.delegate changePage:m_currentPage];
}

#pragma mark - Drawing Staff

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
	CGContextFillRect(context, rect);
	
	[m_visibleThumbnailsIndexes removeAllObjects];
	
	for (int i = 0; i < m_visibleThumbnailsCount-1; i++) {
		
		CGPoint imagePoint = CGPointMake((self.bounds.size.width - self.thumbnailSize.width)/2, 20 + (self.thumbnailSize.height+8)*i);

		[(UIImage *)[self.delegate thumbnailByIndex:(int)(i*((double)m_pagesCount / m_visibleThumbnailsCount)+0.5)]
											drawInRect:CGRectMake(imagePoint.x,
																  imagePoint.y,
																  self.thumbnailSize.width,
																  self.thumbnailSize.height)];
		
		CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor);
		CGContextStrokeRect(context, CGRectMake((rect.size.width - self.thumbnailSize.width)/2 - 1,
												imagePoint.y - 1,
												self.thumbnailSize.width+2,
												self.thumbnailSize.height+2));
	}
	
	
	// Draw the last page
	CGPoint imagePoint = CGPointMake((rect.size.width - self.thumbnailSize.width)/2,
									 20 + (self.thumbnailSize.height+8)*(m_visibleThumbnailsCount-1));
	[(UIImage *)[self.delegate thumbnailByIndex:(m_pagesCount-1)] drawInRect:CGRectMake(imagePoint.x,
																						imagePoint.y,
																						self.thumbnailSize.width,
																						self.thumbnailSize.height)];
	
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor);
	CGContextStrokeRect(context, CGRectMake((rect.size.width - self.thumbnailSize.width)/2 - 1,
											imagePoint.y - 1,
											self.thumbnailSize.width+2,
											self.thumbnailSize.height+2));

	m_selectedPageView.image = [self.delegate thumbnailByIndex:m_currentPage];
}

@end
