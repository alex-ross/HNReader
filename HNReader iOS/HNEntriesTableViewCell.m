//
//  HNEntriesTableViewCell.m
//  HNReader
//
//  Created by Andrew Shepard on 9/30/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesTableViewCell.h"

@interface HNEntriesTableViewCell ()

- (void)applyHighlightAndSelectionStyle:(BOOL)apply;

@end

@implementation HNEntriesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    [selectedView setBackgroundColor:[UIColor hn_brightOrangeColor]];
    [self setSelectedBackgroundView:selectedView];
    
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self applyHighlightAndSelectionStyle:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self applyHighlightAndSelectionStyle:highlighted];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self setup];
}

#pragma mark - Private
- (void)setup {
    [self.siteDomainLabel setTextColor:[UIColor grayColor]];
    
    [self.totalPointsLabel setTextAlignment:NSTextAlignmentRight];
    [self.totalPointsLabel setTextColor:[UIColor grayColor]];
    
    [self.siteDomainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [self.siteDomainLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    [self.totalPointsLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
}

- (void)applyHighlightAndSelectionStyle:(BOOL)apply {
    if (apply) {
        self.siteTitleLabel.textColor = [UIColor whiteColor];
        self.siteDomainLabel.textColor = [UIColor whiteColor];
        self.totalPointsLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.siteTitleLabel.textColor = [UIColor blackColor];
        self.siteDomainLabel.textColor = [UIColor grayColor];
        self.totalPointsLabel.textColor = [UIColor grayColor];
    }
}

@end
