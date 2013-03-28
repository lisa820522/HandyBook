//
//  NotesViewController.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 06.11.12.
//
//

#import <UIKit/UIKit.h>
#import "PdfDelegate.h"

@interface Note : NSObject <NSCoding>

@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) int page;

- (id)initWithText:(NSString *)text offset:(CGPoint)offset;

@end

@interface NotesViewController : UITableViewController {
	id<PdfDelegate> m_delegate;
}

@property (nonatomic, assign) id<PdfDelegate> delegate;

@end
