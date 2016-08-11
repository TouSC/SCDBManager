//
//  SCDBManager.h
//  SCGlobalProject
//
//  Created by user on 15/5/12.
//  Copyright (c) 2015年 tousan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SCDBManager : NSObject

+ (SCDBManager*)shareInstance;
- (void)createTableWithName:(NSString *)tableName keyArr:(NSArray *)keyArr;//新建一个表
- (void)dropTableWithName:(NSString*)tableName;//删除一个表
- (BOOL)insertIntoTable:(NSString*)tableName Values:(id)value,...;//向一个表内插入一行
- (void)deleteFromTable:(NSString*)tableName TargetKey:(NSString*)targetKey TargetValue:(id)targetValue;//删除一个表内的一行
- (void)updateTable:(NSString*)tableName SetTargetKey:(NSString*)targetKey WithValue:(id)targetValue WhereItsKey:(NSString*)locateKey IsValue:(id)locateValue;//更新一个表内一行的某个元素
- (id)getValueInTable:(NSString*)tableName WhereItsKey:(NSString*)locateKey IsValue:(id)locateValue TargetKey:(NSString*)targetKey;//获取一个表内一行内容
- (NSArray*)getAllObjectsFromTable:(NSString*)table KeyArr:(NSArray*)keyArr;//获取一个表的所有内容
+ (id)stringToObject:(NSString*)string;

- (void)myDeleteFromTable:(NSString*)tableName TargetKeys:(NSArray*)targetKey TargetValues:(NSArray *)targetValue;
- (void)myCreateTableWithName:(NSString *)tableName keyArr:(NSArray *)keyArr;
- (id)myGetValueInTable:(NSString*)tableName WhereItsKey:(NSArray*)locateKey IsValue:(NSArray *)locateValue TargetKey:(NSString*)targetKey;

@end
