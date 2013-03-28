//
//  PdfPageView.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 12.11.12.
//
//

#import "PdfPageView.h"

@implementation PdfPage

@synthesize offset = m_offset;
@synthesize scale = m_scale;

- (id)initWithPage:(CGPDFPageRef)pg
{
	self = [super init];
	if (self) {
		CGRect rect = CGPDFPageGetBoxRect(pg, kCGPDFMediaBox);
		m_size = rect.size;
		m_offset = 0;
		m_scale = 1;
	}
	return self;
}

- (void)setPage:(CGPDFPageRef)pg
{
	CGRect rect = CGPDFPageGetBoxRect(pg, kCGPDFMediaBox);
	m_size = rect.size;
}

- (float)width
{
	return m_size.width;
}

- (float)height
{
	return m_size.height;
}

@end

@implementation PdfPageView

@synthesize pageIndex;
@synthesize pdfPage;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor whiteColor];
		
		CATiledLayer *tiledLayer = (CATiledLayer *) [self layer];
		tiledLayer.frame = CGRectMake(0, 0, 100, 100);
		[tiledLayer setTileSize:CGSizeMake(512, 512)];
		[tiledLayer setLevelsOfDetail:4];
		[tiledLayer setLevelsOfDetailBias:4];
    }
    return self;
}

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, layer.bounds);
	
	CGContextSaveGState(ctx);
	
	CGRect rect = CGPDFPageGetBoxRect(m_pdfPageRef, kCGPDFMediaBox);
	
	CGContextTranslateCTM(ctx, 0, rect.size.height*layer.bounds.size.height/rect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextScaleCTM(ctx, layer.bounds.size.width/rect.size.width, layer.bounds.size.height/rect.size.height);
	CGContextTranslateCTM(ctx, 0, -rect.origin.y);
	
	CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(m_pdfPageRef, kCGPDFMediaBox, rect, 0, true));
	
	CGContextDrawPDFPage(ctx, m_pdfPageRef);
	
	CGContextRestoreGState(ctx);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, rect);
}

- (void)dealloc
{
	CGPDFPageRelease(m_pdfPageRef);
	[super dealloc];
}

- (void)setPdfPageRef:(CGPDFPageRef)page
{
	CGPDFPageRelease(m_pdfPageRef);
	m_pdfPageRef = CGPDFPageRetain(page);
}

- (CGPDFPageRef)pdfPageRef
{
	return m_pdfPageRef;
}

- (CGSize)pageSize
{
	CGRect rect = CGPDFPageGetBoxRect(m_pdfPageRef, kCGPDFCropBox);
	return rect.size;
}

@end
