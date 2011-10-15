//
//  HNLoadMoreTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HNLoadMoreTableViewCell.h"

@implementation HNLoadMoreTableViewCell

@synthesize loadMoreLabel;

- (id)init {
    if ((self = [super init])) {
        CGRect frame = CGRectMake(0.0f, 0.0f, 320.0f, 72.0f);
        UIView *containerView = [[[UIView alloc] initWithFrame:frame] autorelease];
        
        loadMoreLabel = [[UILabel alloc] initWithFrame:frame];
        loadMoreLabel.textAlignment = UITextAlignmentCenter;
        loadMoreLabel.text = NSLocalizedString(@"Load More Entries...", @"Load More Entries table cell text");
        loadMoreLabel.textColor = [UIColor darkGrayColor];
        
        [containerView addSubview:loadMoreLabel];
        
        HNTableCellBackgroundView *backgroundView = [[HNTableCellBackgroundView alloc] initWithFrame:frame];
        [self setBackgroundView:backgroundView];
        [backgroundView release];
        
        HNTableCellSelectedView *selectedView = [[HNTableCellSelectedView alloc] initWithFrame:frame];
        [self setSelectedBackgroundView:selectedView];
        [selectedView release];
        
        [self addSubview:containerView];
    }
    
    return self;
}

- (void)dealloc {
    [loadMoreLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end