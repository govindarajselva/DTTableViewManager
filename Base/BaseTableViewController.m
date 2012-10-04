//
//  BaseTableViewController.m
//  ainifinity
//
//  Created by Alexey Belkevich on 6/19/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "BaseTableViewController.h"
#import "CellFactory.h"
#import "BaseTableViewCell.h"

@interface BaseTableViewController ()
- (NSMutableArray *)getValidTableSection:(NSInteger)index;
- (void)insertTableSectionsWithRowAnimation:(UITableViewRowAnimation)animation;
@property (nonatomic,retain) NSMutableArray * sections;
@property (nonatomic,retain) NSArray * headers;
@property (nonatomic,retain) NSArray * footers;

@end

@implementation BaseTableViewController

@synthesize table=_table, headers=_headers, sections=_sections,footers = _footers;

#pragma mark - Getters, initializers and cleaning

-(NSMutableArray *)sections
{
    if (!_sections)
    {
        _sections = [NSMutableArray new];
    }
    return _sections;
}

-(NSArray *)headers {
    if (!_headers)
    {
        _headers = [NSArray new];
    }
    return _headers;
}

-(NSArray *)footers {
    if (!_footers)
    {
        _footers = [NSArray new];
    }
    return _footers;
}

- (void)dealloc
{
    self.sections = nil;
    self.table = nil;
    self.headers = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    self.table = nil;
    [super viewDidUnload];
}

#pragma mark - search

- (id)tableItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section=nil;
    if (indexPath.section < [self.sections count])
    {
        section = [self tableItemsInSection:indexPath.section];
    }
    else {
        NSLog(@"Table item not found");
        return nil;
    }
    if (indexPath.row < [section count])
    {
        return [section objectAtIndex:indexPath.row];
    }
    else return nil;
}

- (NSIndexPath *)indexPathOfTableItem:(NSObject *)tableItem
{
    for (NSInteger i=0; i<self.sections.count; i++)
    {
        NSArray *section = [self tableItemsInSection:i];
        NSInteger index = [section indexOfObject:tableItem];
        if (index != NSNotFound)
        {
            return [NSIndexPath indexPathForRow:index inSection:i];
        }
    }
    return nil;
}

//This implementation is not optimized, and may behave poorly over tables with lot of sections
-(NSArray *)indexPathArrayForTableItems:(NSArray *)tableItems
{
    NSMutableArray * indexPaths = [[NSMutableArray alloc] initWithCapacity:[tableItems count]];
    
    for (NSInteger i=0; i<[tableItems count]; i++)
    {
        NSIndexPath * foundIndexPath = [self indexPathOfTableItem:[tableItems objectAtIndex:i]];
        if (!foundIndexPath)
        {
            NSLog(@"object %@ not found, returning nil", [tableItems objectAtIndex:i]);
            [indexPaths release];
            return nil;
        }
        
        [indexPaths addObject:foundIndexPath];
    }
    return [indexPaths autorelease];
}

-(NSArray *)tableItemsArrayForIndexPaths:(NSArray *)indexPaths
{
    NSMutableArray * items = [[NSMutableArray alloc] initWithCapacity:[indexPaths count]];
    
    for (NSIndexPath * path in indexPaths)
    {
        NSIndexPath * foundIndexPath = [self tableItemAtIndexPath:path];
        if (foundIndexPath)
        {
            [items addObject:foundIndexPath];
        }
        else {
            NSLog(@"item not found. Returning nil for NSArrayForIndexPaths");
            [items release];
            return nil;
        }
    }
    return [items autorelease];
}

- (NSArray *)tableItemsInSection:(int)section
{
    if (section<[self.sections count])
    {
        return [self.sections objectAtIndex:section];
    }
    else return nil;
}

- (void)addTableItem:(NSObject *)tableItem
{
    [self addTableItem:tableItem toSection:0];
}

-(void)addTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation
{
    [self addTableItem:tableItem toSection:0 withRowAnimation:animation];
}

- (void)addTableItems:(NSArray *)tableItems
{
    [self addTableItems:tableItems toSection:0];
}

-(void)addTableItems:(NSArray *)tableItems withRowAnimation:(UITableViewRowAnimation)animation
{
    [self addTableItems:tableItems toSection:0 withRowAnimation:animation];
}

- (void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section
{
    NSMutableArray *array = [self getValidTableSection:section];
    [array addObject:tableItem];
}

-(void)reloadTableSections
{
    for (int i = self.table.numberOfSections; i<self.sections.count ; i++)
    {
        [self.table reloadSections:[NSIndexSet indexSetWithIndex:i]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)addTableItem:(NSObject *)tableItem toSection:(NSInteger)section
   withRowAnimation:(UITableViewRowAnimation)animation
{
    NSIndexPath * lastItemPath = [NSIndexPath indexPathForRow:[self numberOfTableItemsInSection:section]
                                                    inSection:section];
    [self addTableItem:tableItem toSection:section];
    
    if (section >= self.table.numberOfSections)
    {
        [self insertTableSectionsWithRowAnimation:animation];
    }
    else {
        [self.table insertRowsAtIndexPaths:@[lastItemPath] withRowAnimation:animation];
    }
}


- (void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)section
{
    NSMutableArray *array = [self getValidTableSection:section];
    
    [array addObjectsFromArray:tableItems];
}

-(void)addTableItems:(NSArray *)tableItems toSection:(NSInteger)section
    withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.table beginUpdates];
    for (id tableItem in tableItems)
    {
        [self addTableItem:tableItem toSection:section withRowAnimation:animation];
    }
    [self.table endUpdates];
}

-(void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [self getValidTableSection:indexPath.section];
    
    [array insertObject:tableItem atIndex:indexPath.row];
}

-(void)insertTableItem:(NSObject *)tableItem toIndexPath:(NSIndexPath *)indexPath
      withRowAnimation:(UITableViewRowAnimation)animation
{
    [self insertTableItem:tableItem toIndexPath:indexPath];
    
    if (indexPath.section >= self.table.numberOfSections)
    {
        [self insertTableSectionsWithRowAnimation:animation];
    }
    else {
        [self.table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
}

-(void)replaceTableItem:(NSObject *)tableItemToReplace
          withTableItem:(NSObject *)replacingTableItem
{
    NSIndexPath * indexPathToReplace = [self indexPathOfTableItem:tableItemToReplace];
    
    NSMutableArray *section = [self getValidTableSection:indexPathToReplace.section];
    [section replaceObjectAtIndex:indexPathToReplace.row withObject:replacingTableItem];
}

-(void)replaceTableItem:(NSObject *)tableItemToReplace
          withTableItem:(NSObject *)replacingTableItem
        andRowAnimation:(UITableViewRowAnimation)animation
{
    NSIndexPath * indexPathToReplace = [self indexPathOfTableItem:tableItemToReplace];
    [self replaceTableItem:tableItemToReplace withTableItem:replacingTableItem];
    
    [self.table reloadRowsAtIndexPaths:@[indexPathToReplace]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeTableItem:(NSObject *)tableItem
{
    NSIndexPath *indexPath = [self indexPathOfTableItem:tableItem];
    if (indexPath)
    {
        NSArray *section = [self tableItemsInSection:indexPath.section];
        NSMutableArray *castedSection = (NSMutableArray *)section;
        [castedSection removeObject:tableItem];
    }
}

-(void)removeTableItems:(NSArray *)tableItems
{
    for (NSObject * item in tableItems)
    {
        [self removeTableItem:item];
    }
}

-(void)removeTableItems:(NSArray *)tableItems
       withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.table beginUpdates];
    for (NSObject * item in tableItems)
    {
        [self removeTableItem:item withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.table endUpdates];
}

-(void)removeTableItem:(NSObject *)tableItem withRowAnimation:(UITableViewRowAnimation)animation
{
    NSIndexPath *indexPath = [self indexPathOfTableItem:tableItem];
    [self removeTableItem:tableItem];
    [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

- (void)removeAllTableItems
{
    [self.sections removeAllObjects];
}

#pragma mark -
#pragma mark table delegate/data source implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

-(void)moveSection:(int)indexFrom toSection:(int)indexTo
{
    NSMutableArray * validSectionFrom = [[self getValidTableSection:indexFrom] retain];
    [self getValidTableSection:indexTo];
    
    [self.sections removeObject:validSectionFrom];
    [self.sections insertObject:validSectionFrom atIndex:indexTo];
    [validSectionFrom release];
    
    if (self.sections.count > self.table.numberOfSections)
    {
        //Row does not exist, moving section causes many sections to change, so we just reload
        [self.table reloadData];
    }
    else {
        [self.table moveSection:indexFrom toSection:indexTo];
    }
}

-(void)deleteSections:(NSIndexSet *)indexSet
{
    for (int i=0; i<= [self numberOfSections]; i++)
    {
        if ([indexSet containsIndex:i])
        {
            [self.sections removeObjectAtIndex:i];
        }
    }
}

-(void)deleteSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteSections:indexSet];
    [self.table beginUpdates];
    for (int i=0; i<= [self.table numberOfSections]; i++)
    {
        if ([indexSet containsIndex:i])
        {
            [self.table deleteSections:[NSIndexSet indexSetWithIndex:i]
                      withRowAnimation:animation];
        }
    }
    [self.table endUpdates];
}

-(void)reloadSections:(NSIndexSet *)indexSet withRowAnimation:(UITableViewRowAnimation)animation
{
    [self.table beginUpdates];
    for (int i=0; i<= self.table.numberOfSections; i++)
    {
        if ([indexSet containsIndex:i])
        {
            if (i==self.table.numberOfSections)
            {
                [self insertTableSectionsWithRowAnimation:animation];
            }
            else
            {
                [self.table reloadSections:[NSIndexSet indexSetWithIndex:i]
                          withRowAnimation:animation];
            }
        }
    }
    [self.table endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = [self tableItemsInSection:section];
    return sectionArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section < self.headers.count) ? [self.headers objectAtIndex:section] : nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return (section < self.footers.count) ? [self.footers objectAtIndex:section] : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *model = [self tableItemAtIndexPath:indexPath];
    UITableViewCell *cell = [[CellFactory sharedInstance] cellForModel:model inTable:tableView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark private
-(void)insertTableSectionsWithRowAnimation:(UITableViewRowAnimation)animation
{
    
    NSMutableIndexSet * sectionsToAdd = [[NSMutableIndexSet alloc] init];
    
    for (int i = self.table.numberOfSections; i<self.sections.count; i++)
    {
        [sectionsToAdd addIndex:i];
    }
    if ([sectionsToAdd count])
        [self.table insertSections:sectionsToAdd withRowAnimation:animation];
    [sectionsToAdd release];
}

- (NSMutableArray *)getValidTableSection:(NSInteger)index
{
    if (index < self.sections.count)
    {
        return (NSMutableArray *)[self tableItemsInSection:index];
    }
    else 
    {
        for (int i = self.sections.count; i <= index ; i++)
        {
            NSMutableArray *newSection = [NSMutableArray array];
            [self.sections addObject:newSection];
        }
        return [self.sections lastObject];
    }/*
      NSString *reason = [NSString stringWithFormat:@"Can't get section with index '%d',\
      contain only '%d' sections", index, self.sections.count];
      @throw [NSException exceptionWithName:@"Can't get section" reason:reason userInfo:nil];*/
}

-(void)setSectionHeaders:(NSArray *)headers
{
    self.headers = headers;
}

-(void)setSectionFooters:(NSArray *)footers
{
    self.footers = footers;
}

-(int)numberOfTableItemsInSection:(NSInteger)section
{
    NSArray * itemsInSection = [self tableItemsInSection:section];
    return [itemsInSection count];
}

-(int)numberOfSections
{
    return [self.sections count];
}

@end
