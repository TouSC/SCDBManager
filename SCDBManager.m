//
//  SCDBManager.m
//  
//
//  Created by user on 15/5/12.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import "SCDBManager.h"

@implementation SCDBManager
{
    FMDatabase *db;
    dispatch_semaphore_t semaphore;
}

+ (SCDBManager*)shareInstance;
{
    static SCDBManager *manager;
    if (manager==nil)
    {
        manager = [[SCDBManager alloc]init];
    }
    return manager;
}

- (instancetype)init;
{
    self = [super init];
    if (self)
    {
        NSString *dbPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DataBase.db"];
        db = [[FMDatabase alloc]initWithPath:dbPath];
        semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)createTableWithName:(NSString *)tableName keyArr:(NSArray *)keyArr;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    NSMutableString *commandStr = [[NSMutableString alloc]initWithFormat:@"create table if not exists %@ ",tableName];
    for (int i=0; i<keyArr.count; i++)
    {
        if (i==0)
        {
            [commandStr appendFormat:@"(%@ primary key",keyArr[i]];
            if (keyArr.count==1)
            {
                [commandStr appendFormat:@")"];
            }
        }
        else if (i!=keyArr.count-1)
        {
            [commandStr appendFormat:@",%@",keyArr[i]];
        }
        else
        {
            [commandStr appendFormat:@",%@)",keyArr[i]];
        }
    }
    if ([db executeUpdate:commandStr])
    {
        NSLog(@"%@",[NSString stringWithFormat:@"create table %@ success!",tableName]);
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat:@"create table %@ failed!",tableName]);
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (void)myCreateTableWithName:(NSString *)tableName keyArr:(NSArray *)keyArr;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    NSMutableString *commandStr = [[NSMutableString alloc]initWithFormat:@"create table if not exists %@ ",tableName];
    for (int i=0; i<keyArr.count; i++)
    {
        if (i==0)
        {
            [commandStr appendFormat:@"(%@ ",keyArr[i]];
            if (keyArr.count==1)
            {
                [commandStr appendFormat:@")"];
            }
        }
        else if (i!=keyArr.count-1)
        {
            [commandStr appendFormat:@",%@",keyArr[i]];
        }
        else
        {
            [commandStr appendFormat:@",%@)",keyArr[i]];
        }
    }
    if ([db executeUpdate:commandStr])
    {
        NSLog(@"%@",[NSString stringWithFormat:@"create table %@ success!",tableName]);
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat:@"create table %@ failed!",tableName]);
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (void)dropTableWithName:(NSString*)tableName;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    if ([db executeUpdate:[NSString stringWithFormat:@"drop table %@",tableName]])
    {
        NSLog(@"%@",[NSString stringWithFormat:@"drop table %@ success!",tableName]);
    }
    else
    {
        NSLog(@"%@",[NSString stringWithFormat:@"drop table %@ failed!",tableName]);
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (BOOL)insertIntoTable:(NSString*)tableName Values:(id)value,... NS_REQUIRES_NIL_TERMINATION;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    
    NSMutableString *commandStr = [[NSMutableString alloc]initWithFormat:@"insert into %@ values ",tableName];
    va_list list;
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    if (value)
    {
        va_start(list, value);
        NSString *curStr = value;
        do
        {
            if (([curStr isKindOfClass:[NSNull class]])||(curStr==nil))
            {
                break;
            }
            else
            {
                if ([curStr isKindOfClass:[NSDictionary class]]||[curStr isKindOfClass:[NSArray class]])
                {
                    curStr = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:curStr options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                }
                else
                {
                    curStr = [NSString stringWithFormat:@"%@",curStr];
                }
                [valueArr addObject:curStr];
            }
        }while ((curStr = va_arg(list, id)));
        va_end(list);
    }
    
    for (int i=0; i<valueArr.count; i++)
    {
        if (i==0)
        {
            [commandStr appendString:@"(?"];
            if (valueArr.count==1)
            {
                [commandStr appendString:@")"];
            }
        }
        else if (i==valueArr.count-1)
        {
            [commandStr appendString:@",?)"];
        }
        else
        {
            [commandStr appendString:@",?"];
        }
    }
    
    if (![db executeUpdate:commandStr withArgumentsInArray:valueArr])
    {
        NSLog(@"insert failed!");
        [db close];
        dispatch_semaphore_signal(semaphore);
        return NO;
    }
    else
    {
        NSLog(@"insert success!");
        [db close];
        dispatch_semaphore_signal(semaphore);
        return YES;
    }
}

- (void)deleteFromTable:(NSString*)tableName TargetKey:(NSString*)targetKey TargetValue:(id)targetValue;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    if (([targetValue isKindOfClass:[NSNull class]])||(targetValue==nil))
    {
        return;
    }
    else
    {
        if (![targetValue isKindOfClass:[NSString class]])
        {
            targetValue = [NSString stringWithFormat:@"%@",targetValue];
        }
    }
    if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@ = ?",tableName,targetKey],targetValue])
    {
        NSLog(@"delete failed!");
    }
    else
    {
        NSLog(@"delete success!");
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (void)myDeleteFromTable:(NSString*)tableName TargetKeys:(NSArray*)targetKey TargetValues:(NSArray *)targetValue;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    if (([targetValue isKindOfClass:[NSNull class]])||(targetValue==nil))
    {
        return;
    }
    else
    {
        
    }
    NSMutableString *conditionStr = [NSMutableString string];
    for (int i = 0;i < targetKey.count ;i++) {
        [conditionStr appendFormat:@" %@ = '%@' %@",targetKey[i],targetValue[i],i==targetKey.count-1?@"":@"and"];
    }
    if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@",tableName,conditionStr]])
    {
        NSLog(@"delete failed!");
    }
    else
    {
        NSLog(@"delete success!");
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (void)updateTable:(NSString*)tableName SetTargetKey:(NSString*)targetKey WithValue:(id)targetValue WhereItsKey:(NSString*)locateKey IsValue:(id)locateValue;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    if ([targetValue isKindOfClass:[NSDictionary class]]||[targetValue isKindOfClass:[NSArray class]])
    {
        targetValue = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:targetValue options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    if (![db executeUpdate:[NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",tableName,targetKey,locateKey],[NSString stringWithFormat:@"%@",targetValue],[NSString stringWithFormat:@"%@",locateValue]])
    {
        NSLog(@"update failed!");
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
}

- (id)getValueInTable:(NSString*)tableName WhereItsKey:(NSString*)locateKey IsValue:(id)locateValue TargetKey:(NSString*)targetKey;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    if (![locateValue isKindOfClass:[NSString class]])
    {
        locateValue = [locateValue stringValue];
    }
    FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = ?",tableName,locateKey],locateValue];
    id targetValue;
    while ([result next])
    {
        targetValue = [result stringForColumn:targetKey];
    }
    [result close];
    [db close];
    dispatch_semaphore_signal(semaphore);
    return targetValue;
}

- (id)myGetValueInTable:(NSString*)tableName WhereItsKey:(NSArray*)locateKey IsValue:(NSArray *)locateValue TargetKey:(NSString*)targetKey;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
//    if (![locateValue isKindOfClass:[NSString class]])
//    {
//        locateValue = [locateValue stringValue];
//    }
    NSMutableString *conditionStr = [NSMutableString string];
    for (int i = 0;i < locateKey.count ;i++) {
        [conditionStr appendFormat:@" %@ = '%@' %@",locateKey[i],locateValue[i],i==locateKey.count-1?@"":@"and"];
    }
    FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@",tableName,conditionStr]];
    id targetValue;
    while ([result next])
    {
        targetValue =
        [result stringForColumn:targetKey];
    }
    [result close];
    [db close];
    dispatch_semaphore_signal(semaphore);
    return targetValue;
}

- (NSArray*)getAllObjectsFromTable:(NSString*)table KeyArr:(NSArray*)keyArr;
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [db open];
    NSMutableArray *elementArr = [[NSMutableArray alloc]init];
    FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"select * from %@",table]];
    while ([result next])
    {
        NSMutableDictionary *elementDic = [[NSMutableDictionary alloc]init];
        for (int i=0; i<keyArr.count; i++)
        {
            [elementDic setObject:[result stringForColumn:keyArr[i]] forKey:keyArr[i]];
        }
        [elementArr addObject:elementDic];
    }
    [db close];
    dispatch_semaphore_signal(semaphore);
    return elementArr;
}

+ (id)stringToObject:(NSString*)string;
{
    if (string==nil)
    {
        string = @"";
    }
    return [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
}

@end
