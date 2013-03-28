//
//  PdfPageSelector.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 02.11.12.
//
//

#import <UIKit/UIKit.h>

#define MIN_THUMBNAIL_WIDTH 42
#define MIN_THUMBNAIL_HEIGHT 48
#define MAX_NUMBER_OF_THREADS 5

@protocol PageSelectorDelegate <NSObject>

- (void)changePage:(int)pageNumber;
- (UIImage *)thumbnailByIndex:(int)index;

@end

@interface PdfPageSelector : UIView {
	UIImageView *m_selectedPageView;
	NSTimer *m_touchTimer;
	CGSize m_thumbnailSize;
	int m_pagesCount;
	int m_visibleThumbnailsCount;
	float m_scrollingHeight;
	NSMutableDictionary *m_visibleThumbnailsCoordinates;
	NSMutableArray *m_visibleThumbnailsIndexes;
	NSMutableArray *m_thumbnailsCoordinates;
	CGPoint m_lastTouch;
}

@property (nonatomic, assign) id<PageSelectorDelegate> delegate;

@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, assign) int pagesCount;
@property (nonatomic, assign) float scrollingHeight;
@property (nonatomic, assign) int currentPage;

@property (nonatomic, retain) UIImageView *selectedPageView;
@property (nonatomic, retain) NSMutableArray *thumbnailsCoordinates;

- (int)findPageNumberForYCoord:(CGFloat)y;
- (void)reloadData;

@end
