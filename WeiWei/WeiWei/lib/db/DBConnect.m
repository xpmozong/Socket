//
//  DBConnect.m
//  Ershixiong
//
//  Created by tw001 on 14-8-29.
//  Copyright (c) 2014年 wave. All rights reserved.
//

#import "DBConnect.h"
#import "FMDB.h"
#define SQLNAME @"mytable.sqlite"

@implementation DBConnect

static DBConnect *dBHandle;

+ (DBConnect *)shareConnect
{
    if (dBHandle == nil) {
        dBHandle = [[DBConnect alloc] init];
        [dBHandle openDatabase];
    }
    return dBHandle;
}

+ (NSString *)bundleSQLPath
{
    return [[NSBundle mainBundle] pathForResource:@"mytable" ofType:@"sqlite"];
}

/// 打开数据库
- (void)openDatabase
{
    NSString *sqlPath = [[self getDocumentPath] stringByAppendingPathComponent:SQLNAME];
    NSLog(@"%@", sqlPath); // 拼接字符串
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:sqlPath] == NO) {
        NSString *bundleSQLPath = [DBConnect bundleSQLPath];
        NSError *err = nil;
        [fm copyItemAtPath:bundleSQLPath toPath:sqlPath error:&err];
        if (err != nil) {
            NSLog(@"copy db fail %@", [err localizedDescription]);
        }
    }
    
    self.dataBase = [FMDatabase databaseWithPath:sqlPath];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:sqlPath];
    NSLog(@"self.dbQueue==%@", self.dbQueue);
    [_dataBase open];
    if (![_dataBase open]) {
        NSLog(@"数据库打开失败");
    }else{
        NSLog(@"数据库打开成功");
    }
}

/// 获得document文件的路径
- (NSString *)getDocumentPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // 获取document文件的路径
    return documentPath;
}

/// 判断是否存在表
- (BOOL)isTableOK:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = '%@'", tableName];
    int count = [self getDBDataCount:sql];
    NSLog(@"Table count===%d", count);
    if (count > 0) {
        return YES;
    }
    
    return NO;
}

/// 创建表
- (BOOL)createTableSql:(NSString *)sql
{
    [self executeInsertSql:sql];
    return YES;
}

/// 获得数据
- (NSArray *)getDBlist:(NSString *)sql
{
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    NSLog(@"%@", sql);
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            
            [list addObject:dictionary];
            
            return 0;
        }];
        
    }];
    
    return list;
}

/// 获得单条数据
- (NSDictionary *)getDBOneData:(NSString *)sql
{
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    NSLog(@"%@", sql);
    
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            
            [list addObject:dictionary];
            
            return 0;
        }];
        
    }];
    
    if (list.count == 1) {
        return [list objectAtIndex:0];
    }
    
    return nil;
}

/// 统计数量
- (int)getDBDataCount:(NSString *)sql
{
    int count = 0;
    __block NSMutableArray *list = [[NSMutableArray alloc] init];
    NSLog(@"%@", sql);
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeStatements:sql withResultBlock:^int(NSDictionary *dictionary) {
            
            [list addObject:dictionary];
            
            return 0;
        }];
        
    }];
    
    if (list.count == 1) {
        NSDictionary *dict = [list objectAtIndex:0];
        if (dict) {
            count = [[dict objectForKey:@"count"] intValue];
        }
    }
    NSLog(@"getDBDataCount count===%d", count);
    
    return count;
}

/// 执行sql (主要用来执行插入操作)
- (unsigned)executeInsertSql:(NSString *)sql
{
    __block unsigned mid = 0;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSLog(@"%@", sql);
        BOOL success = [db executeStatements:sql];
        NSLog(@"sql语句执行成功 %d", success);
        sqlite_int64 lastId = [db lastInsertRowId];
        mid = (unsigned)lastId;
    }];
    
    return mid;
}

/// 更新操作，删除操作
- (void)executeUpdateSql:(NSString *)sql
{
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSLog(@"%@", sql);
        BOOL success = [db executeStatements:sql];
        NSLog(@"sql语句执行成功 %d", success);
    }];
}

/// 关闭数据库
- (void)closeDatabase
{
    [self.dataBase close];
}


@end
