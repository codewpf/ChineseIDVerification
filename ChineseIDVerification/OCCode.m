//
//  OCCode.m
//  ChineseIDVerification
//
//  Created by wpf on 2017/3/4.
//  Copyright © 2017年 wpf. All rights reserved.
//

#import "OCCode.h"

@interface OCCode ()

@property (nonatomic, strong) NSArray *provinceCode;
@property (nonatomic, strong) NSArray *power;              // 加权因子
@property (nonatomic, strong) NSArray *verifyCode;         // 校验码
@property (nonatomic, strong) NSDateFormatter *formatter;  //

@end

@implementation OCCode

- (instancetype)init
{
    if(self = [super init])
    {
        /**
         * 省，直辖市代码表： { 11:"北京",12:"天津",13:"河北",14:"山西",15:"内蒙古",
         * 21:"辽宁",22:"吉林",23:"黑龙江",31:"上海",32:"江苏",
         * 33:"浙江",34:"安徽",35:"福建",36:"江西",37:"山东",41:"河南",
         * 42:"湖北",43:"湖南",44:"广东",45:"广西",46:"海南",50:"重庆",
         * 51:"四川",52:"贵州",53:"云南",54:"西藏",61:"陕西",62:"甘肃",
         * 63:"青海",64:"宁夏",65:"新疆",71:"台湾",81:"香港",82:"澳门",91:"国外"}
         */
        
        self.provinceCode = @[@"11",@"12",@"13",@"14",@"15",@"21",@"22",
                          @"23",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"41",@"42",@"43",
                          @"44",@"45",@"46",@"50",@"51",@"52",@"53",@"54",@"61",@"62",@"63",
                          @"64",@"65",@"71",@"81",@"82",@"91" ];
        
        // 加权因子
        self.power = @[@7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2];
        // 第18位校检码
        self.verifyCode = @[ @"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
        
    }
    return self;
}

/**
 * 验证所有的身份证的合法性
 *
 * @param idcard 身份证号码
 * @return 合法性
 */
- (BOOL)isValidatedChineseID:(NSString *)idcard
{
    if ([self is15Idcard:idcard]) {
        return [self isValidate15Idcard:idcard];
    } else if ([self is18Idcard:idcard]){
        return [self isValidate18Idcard:idcard];
    } else {
        return NO;
    }
}

/**
 * 判断18位身份证的合法性
 *
 * @param idcard 18位身份证号码
 * @return 合法性
 * @note
 * 根据〖中华人民共和国国家标准GB11643-1999〗中有关公民身份号码的规定，公民身份号码是特征组合码，由十七位数字本体码和一位数字校验码组成。
 * 排列顺序从左至右依次为：六位数字地址码，八位数字出生日期码，三位数字顺序码和一位数字校验码。
 * 
 * 顺序码: 表示在同一地址码所标识的区域范围内，对同年、同月、同 日出生的人编定的顺序号，顺序码的奇数分配给男性，偶数分配 给女性。
 *
 * 1.前1、2位数字表示：所在省份的代码； 
 * 2.第3、4位数字表示：所在城市的代码； 
 * 3.第5、6位数字表示：所在区县的代码；
 * 4.第7~14位数字表示：出生年、月、日； 
 * 5.第15、16位数字表示：所在地的派出所的代码；
 * 6.第17位数字表示性别：奇数表示男性，偶数表示女性；
 * 7.第18位数字是校检码：也有的说是个人信息码，一般是随计算机的随机产生，用来检验身份证的正确性。校检码可以是0~9的数字，有时也用x表示。
 *
 * 
 * 第十八位数字(校验码)的计算方法为： 
 *
 * 1.将前面的身份证号码17位数分别乘以不同的加权因子。位数与加权因子对照如下：
 *      位数：01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17
 *      系数：7  9  10  5  8  4  2  1  6  3  7  9 10  5  8  4  2
 * 2.将这17位数字和系数相乘的结果相加。
 * 3.用加出来和除以11，看余数是多少？
 * 4.余数与校验码对照如下：
 *      余数：0 1 2 3 4 5 6 7 8 9 10
 *      校验：1 0 X 9 8 7 6 5 4 3 2
 * 5.通过上面得知如果余数是2，就会在身份证的第18位数字上出现罗马数字的Ⅹ。如果余数是10，身份证的最后一位号码就是2。
 *
 */
- (BOOL)isValidate18Idcard:(NSString *)idcard
{
    if(idcard.length != 18) return NO;
    // 获取前17位
    NSString *idcard17 = [idcard substringToIndex:17];
    // 获取第18位
    NSString *idcard18Code = [[idcard substringWithRange:NSMakeRange(17, 1)] lowercaseString];
    
    NSMutableArray *c = [NSMutableArray new];
    
    // 是否都为数字
    if([self isDigital:idcard17])
    {
        [c addObjectsFromArray:[self stringToArray:idcard17]];
    }
    else return NO;
    
    if(idcard17.length == 17)
    {
        NSInteger sum17 = 0;
        sum17 = [self getPowerSum:c];
        // 获取和值与11取模得到余数进行校验码
        NSString *checkCode = [self getCheckCodeBySum:sum17];
        // 获取不到校验位
        if(nil == checkCode) return NO;
        if(![idcard18Code isEqualToString:checkCode]) return NO;
        
    }
    else return NO;
    return YES;
}

/**
 * 验证15位身份证的合法性,该方法验证不一定准确。
 *
 * @param idcard 15位身份证号码
 * @return 合法性
 */
- (BOOL)isValidate15Idcard:(NSString *)idcard
{
    if(idcard.length != 15) return NO;
    if([self isDigital:idcard])
    {
        NSString *proviceid = [idcard substringWithRange:NSMakeRange(0, 2)];
        NSString *birthday = [idcard substringWithRange:NSMakeRange(6, 6)];
        NSInteger year = [[idcard substringWithRange:NSMakeRange(6, 2)] integerValue];
        NSInteger month = [[idcard substringWithRange:NSMakeRange(8, 2)] integerValue];
        NSInteger day = [[idcard substringWithRange:NSMakeRange(10, 2)] integerValue];
        
        BOOL flag1 = NO;
        for(NSString *pID in self.provinceCode)
        {
            if([pID isEqualToString:proviceid])
            {
                flag1 = YES; break;
            }
        }
        if(!flag1) return NO;
        
        NSDate *date = [[self getFormatter:@"yyMMdd"] dateFromString:birthday];
        if(date == nil ||
           [[NSDate date] compare:date] == NSOrderedAscending)
        {
            return NO;
        }
        
        NSInteger year2bit = [[[self getFormatter:@"yy"] stringFromDate:[NSDate date]] integerValue];
        
        // 判断该年份的两位表示法，小于50的和大于当前年份的，为假
        if(year < 50 && year > year2bit) return NO;
        // 判断是否为合法的月份
        if(month < 1 || month >12) return NO;
        
        BOOL flag2 = NO;
        switch (month) {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
                flag2 = (day >= 1 && day <= 31);
                break;
            case 2: // 公历的2月非闰年有28天,闰年的2月是29天。
                if([self isLeapYear:[self dateToYear:birthday]])
                {
                    flag2 = (day >= 1 && day <= 29);
                } else {
                    flag2 = (day >= 1 && day <= 28);
                }
                break;
            case 4:
            case 6:
            case 9:
            case 11:
                flag2 = (day >= 1 && day <= 30);
                break;
        }
        if(!flag2) return NO;
    }
    else
    {
        return NO;
    }
    return YES;
}

/**
 * 将15位的身份证转成18位身份证
 *
 * @param idcard 15位身份证号码
 * @return 18位身份证号码
 */
- (NSString *)convertIdcarBy15bit:(NSString *)idcard
{
    NSString *idcard17 = nil;
    if(idcard.length != 15) return nil;
    if([self isDigital:idcard])
    {
        NSString *birthday = [idcard substringWithRange:NSMakeRange(6, 6)];
        
        NSString *year = [self dateToYear:birthday];
        idcard17 = [NSString stringWithFormat:@"%@%@%@",[idcard substringWithRange:NSMakeRange(0, 6)],year,[idcard substringFromIndex:8]];
        NSMutableArray *c = [NSMutableArray new];
        for(NSInteger i=0;i<idcard17.length;i++) [c addObject:[idcard17 substringWithRange:NSMakeRange(i, 1)]];
        NSString *checkCode = @"";
        if(idcard17.length == 17)
        {
            
            NSInteger sum17 = 0;
            sum17 = [self getPowerSum:c];
            // 获取和值与11取模得到余数进行校验码
            checkCode = [self getCheckCodeBySum:sum17];
            // 获取不到校验位
            if(nil == checkCode) return nil;
            
            // 将前17位与第18位校验码拼接
            idcard17 = [idcard17 stringByAppendingString:checkCode];
        }
    }
    else
    {
        return nil;
    }
    return idcard17;
}

#pragma mark - RegexMethods

/**
 * 15位和18位身份证号码的基本数字和位数验校
 *
 * @param idcard 身份证号码
 * @return 校验结果
 */
- (BOOL)isIdcard:(NSString *)idcard
{
    NSString *nullRegex = @"^(^\\d{15}$)|(\\d{17}(?:\\d|x|X)$)";
    NSPredicate *nullPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nullRegex];
    return idcard==nil || [idcard isEqualToString:@""]?NO:[nullPredicate evaluateWithObject:idcard];
}

/**
 * 15位身份证号码的基本数字和位数验校
 *
 * @param idcard 身份证号码
 * @return 校验结果
 */
- (BOOL)is15Idcard:(NSString *)idcard
{
    NSString *nullRegex = @"^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$";
    NSPredicate *nullPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nullRegex];
    return [nullPredicate evaluateWithObject:idcard];
}

/**
 * 18位身份证号码的基本数字和位数验校
 *
 * @param idcard 身份证号码
 * @return 校验结果
 */
- (BOOL)is18Idcard:(NSString *)idcard
{
    NSString *nullRegex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([\\d|x|X]{1})$";
    NSPredicate *nullPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nullRegex];
    return [nullPredicate evaluateWithObject:idcard];
}

/**
 * 数字验证
 *
 * @param str 参数
 * @return 是否是数字
 */
- (BOOL)isDigital:(NSString *)str
{
    NSString *nullRegex = @"^[0-9]*$";
    NSPredicate *nullPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nullRegex];
    return str==nil || [str isEqualToString:@""]?NO:[nullPredicate evaluateWithObject:str];
    
}

#pragma mark - SupportMethods

/**
 * 将身份证的每位和对应位的加权因子相乘之后，再得到和值
 *
 * @param c 值数组
 * @return 和值
 */
- (NSInteger)getPowerSum:(NSArray *)c
{
    NSInteger sum = 0;
    if(self.power.count != c.count) return sum;
    for(NSInteger i=0; i<c.count; i++)
    {
        sum = sum + [c[i] integerValue]*[self.power[i] integerValue];
    }
    return sum;
}

/**
 * 将和值与11取余得到余数得到校验码
 *
 * @param sum17 17位和
 * @return 校验码
 */
- (NSString *)getCheckCodeBySum:(NSInteger)sum17
{
    NSInteger index = sum17 % 11;
    
    return self.verifyCode[index];
}

- (NSString *)dateToYear:(NSString *)birthday
{
    NSDate *birthdate = nil;
    birthdate = [[self getFormatter:@"yyMMdd"] dateFromString:birthday];
    if(!birthdate) return @"";
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit type = NSCalendarUnitYear;
    NSDateComponents *component = [calendar components:type fromDate:birthdate];
    return [NSString stringWithFormat:@"%ld",(long)component.year];
    
}

- (NSDateFormatter *)getFormatter:(NSString *)format
{
    if(!_formatter)
    {
        _formatter = [[NSDateFormatter alloc]init];
        [_formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    [_formatter setDateFormat:format];
    return _formatter;
}

- (BOOL)isLeapYear:(NSString *)year
{
    NSInteger yy = year.integerValue;
    
    if ((yy%4==0 && yy %100 !=0) || yy%400==0) {
        return YES;
    }else {
        return NO;
    }
}

- (NSArray *)stringToArray:(NSString *)str
{
    const char *chars = str.UTF8String;
    NSMutableArray *array = [NSMutableArray new];
    for(NSInteger i=0;i<str.length;i++)
    {
        [array addObject:[NSString stringWithFormat:@"%c",chars[i]]];
    }
    return [NSArray arrayWithArray:array];
}



@end
