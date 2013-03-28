//
//  BookmarksViewController.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 24.10.12.
//
//

#import <UIKit/UIKit.h>
#import "PdfDelegate.h"

@interface Bookmark : NSObject <NSCoding>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) int page;

- (id)initWithName:(NSString *)name offset:(CGPoint)offset;

@end

@interface BookmarksViewController : UITableViewController {
	id<PdfDelegate> m_delegate;
}

@property (nonatomic, assign) id<PdfDelegate> delegate;

@end
