//
//  PdfPageView.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 12.11.12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PdfPage : NSObject {
	CGFloat m_offset;
	CGSize m_size;
	float m_scale;
}

- (id)initWithPage:(CGPDFPageRef)pg;

- (float)width;
- (float)height;
- (void)setPage:(CGPDFPageRef)pg;

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) float scale;

@end

@interface PdfPageView : UIView {
	CGPDFPageRef m_pdfPageRef;
}

@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) PdfPage *pdfPage;

- (void)setPdfPageRef:(CGPDFPageRef)page;
- (CGSize)pageSize;
- (CGPDFPageRef)pdfPageRef;

@end
