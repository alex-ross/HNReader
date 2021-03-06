//
//  HNEntriesViewController.m
//  HNReader
//
//  Created by Andrew Shepard on 9/28/11.
//  Copyright 2011 Andrew Shepard. All rights reserved.
//

#import "HNEntriesViewController.h"
#import "HNCommentsViewController.h"

#import "HNEntriesTableViewCell.h"
#import "HNLoadMoreTableViewCell.h"

#import "HNEntry.h"
#import "HNEntriesDataSource.h"

static void *myContext = &myContext;

@interface HNEntriesViewController ()

@property (nonatomic, strong) HNEntriesDataSource *dataSource;
@property (nonatomic, strong) UISegmentedControl *entriesControl;

- (void)loadEntries;
- (void)handleContentSizeChangeNotification:(NSNotification *)notification;

@end

@implementation HNEntriesViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.dataSource removeObserver:self forKeyPath:@"entries"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentSizeChangeNotification:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.dataSource = [[HNEntriesDataSource alloc] initWithTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0f;
    
    UINib *nib = [UINib nibWithNibName:HNEntriesTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:HNEntriesTableViewCellIdentifier];
    
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor hn_brightOrangeColor]};
    self.navigationController.navigationBar.largeTitleTextAttributes = titleAttributes;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    
    NSArray<NSString *> *items = @[@"Top", @"New", @"Best"];
    self.entriesControl = [[UISegmentedControl alloc] initWithItems:items];
    self.entriesControl.selectedSegmentIndex = 0;

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.entriesControl];
    [self setToolbarItems:@[item]];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
    
    [self.dataSource addObserver:self forKeyPath:@"entries" options:options context:myContext];
    [self.dataSource addObserver:self forKeyPath:@"error" options:options context:myContext];
    
    [self.entriesControl addObserver:self forKeyPath:@"selectedSegmentIndex" options:options context:myContext];
    
    // TODO: wire up setup refresh button to selector
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == myContext) {
        if ([keyPath isEqualToString:@"entries"]) {
            [self entriesDidLoad];
        } else if ([keyPath isEqualToString:@"selectedSegmentIndex"]) {
            [self loadEntries];
            [self setTitleForEntries];
        } else if ([keyPath isEqualToString:@"error"]) {
            // TODO: present error
            NSLog(@"unhandled error: %@", self.dataSource.error);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] >= self.dataSource.entries.count) {
        // TODO: call via to data source
//        [self.model loadMoreEntriesForIndex:[_entriesControl selectedSegmentIndex]];
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }
    else {
        [self performSegueWithIdentifier:HNEntriesToCommentsSegueIdentifier sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[HNCommentsViewController class]]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        HNEntry *selectedEntry = (HNEntry *)self.dataSource.entries[indexPath.row];
        HNCommentsViewController *nextController = (HNCommentsViewController *)segue.destinationViewController;
        
        [nextController setEntry:selectedEntry];
    }
}

- (void)loadEntries {
    [self prepareForRequest];
    [self.dataSource loadEntriesForIndex:[_entriesControl selectedSegmentIndex]];
}

- (void)setTitleForEntries {
    NSUInteger index = [self.entriesControl selectedSegmentIndex];
    NSString *title = [self.entriesControl titleForSegmentAtIndex:index];
    
    [self setTitle:title];
}

- (void)entriesDidLoad {
    // TODO: animate
    [self.tableView reloadData];
    [self.tableView setScrollEnabled:YES];
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)operationDidFail {
    NSString *title = self.dataSource.error.description;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:title preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleContentSizeChangeNotification:(NSNotification *)notification {
    // respond to preferred text size notifications changes and support dynamic type
    [self.tableView reloadData];
}

- (void)prepareForRequest {
    [self.tableView setUserInteractionEnabled:NO];
    [self.tableView setScrollEnabled:NO];
}

@end
