//
//  SwiftCode.swift
//  ChineseIDVerification
//
//  Created by wpf on 2017/3/4.
//  Copyright © 2017年 wpf. All rights reserved.
//

import Cocoa

class SwiftCode: NSObject {
    
    fileprivate let provinceCode =
        ["11","12","13","14","15","21","22",
         "23","31","32","33","34","35","36","37","41","42","43",
         "44","45","46","50","51","52","53","54","61","62","63",
         "64","65","71","81","82","91"]
    fileprivate let power = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
    fileprivate let verifyCode = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]
    
    
    func isValidatedChineseID(_ id: String) -> Bool{
        if is15ChineseID(id: id) {
            return isValidated15ChineseID(id: id)
        } else if is18ChineseID(id: id) {
            return isValidated18ChineseID(id: id)
        } else {
            return false
        }
    }
    
    fileprivate func isValidated18ChineseID(id: String) -> Bool {
        guard id.length == 18 else {
            return false
        }
        let id17 = id.substring(to: 17)

        guard isDigital(str: id) ,
              id17.length == 17 else {
            return false
        }
        let id18 = id.substring(from: 17)
        
        let c: [String] = stringToArray(id17)
        let sum17 = powerSum(c: c)
        let checkCode = checkCodeBySum(sum17: sum17)

        return checkCode == id18
    }
    
    fileprivate func isValidated15ChineseID(id: String) -> Bool {
        guard id.length == 15,
              isDigital(str: id) else {
            return false
        }
        
        let provinceid = id.substring(range: NSMakeRange(0, 2))
        let birthday = id.substring(range: NSMakeRange(6, 6 ))
        
        // 省份判断
        var flag1 = false
        for pID in provinceCode {
            if pID == provinceid {
                flag1 = true
                break
            }
        }
        guard flag1 else {
            return false
        }
        
        // 与当前日期比较判断
        guard let date = formatter("yyMMdd").date(from: birthday),
              date < Date() else {
            return false
        }
        
        guard let year = Int(id.substring(range: NSMakeRange(6, 2))),
              let month = Int(id.substring(range: NSMakeRange(8, 2))),
              month >= 1,
              month <= 12,
              let day = Int(id.substring(range: NSMakeRange(10, 2))),
              let current = Int(formatter("yyyy").string(from: Date()).substring(from: 2)) else {
            return false
        }
        
        if year < 50 && year > current {
            return false
        }
        
        // 天数判断
        var flag2 = false
        switch month {
        case 1,3,5,7,8,10,12:
            flag2 = (day >= 1 && day <= 31)
        case 4,6,9,11:
            flag2 = (day >= 1 && day <= 30)
            break
        case 2:
            if isLeapYear(dateToYear(birthday: birthday)) {
                flag2 = (day >= 1 && day <= 29)
            } else {
                flag2 = (day >= 1 && day <= 28)
            }
        default:
            flag2 = false
        }
        guard flag2 else {
            return false
        }
        return true
    }

    
    fileprivate func convertChineseID(from15ID: String) -> String? {
        
        guard from15ID.length == 15 else {
            return nil
        }
        
        guard isDigital(str: from15ID) == true else {
            return nil
        }

        let birthday = from15ID.substring(range: NSMakeRange(6,6))
        let year = dateToYear(birthday: birthday)
        var id17 = "\(from15ID.substring(range: NSMakeRange(0, 6)))\(year)\(from15ID.substring(from: 8))"
        let c: [String] = stringToArray(id17)
        
        guard id17.length == 17 else {
            return nil
        }
        
        let sum17 = powerSum(c: c)
        let checkCode = checkCodeBySum(sum17: sum17)
        
        id17 += checkCode
        
        return id17
    }
    
    
    //MARK: - SupportMethods
    fileprivate func powerSum(c: [String]) -> Int {
        
        var sum = 0
        guard power.count == c.count else {
            return sum
        }
        
        for i in 0 ..< c.count {
            if let c = Int(c[i]) {
                sum += c * power[i]
            }
        }
        
        return sum
    }
    
    fileprivate func checkCodeBySum(sum17: Int) -> String {
        let index: Int = sum17 % 11
        return verifyCode[index]
    }
    
    fileprivate func dateToYear(birthday: String) -> String!{
        
        if let birthdate: Date = formatter("yyMMdd").date(from: birthday) {
            
            let calendar: Calendar = Calendar(identifier: .gregorian)
            let component: Set<Calendar.Component> = [.year];
            let components: DateComponents = calendar.dateComponents(component, from: birthdate)
            return "\(components.year)"
            
        } else {
            return ""
        }
    }
    
    let dateFormatter: DateFormatter = DateFormatter()
    fileprivate func formatter(_ format: String, _ tz: TimeZone = TimeZone.current) -> DateFormatter {
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = tz
        return dateFormatter
    }
    
    fileprivate func isLeapYear(_ year: String) -> Bool {
        if let yy = Int(year) {
            if ((yy % 4 == 0 && yy % 100 != 0) || yy % 400 == 0) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    
    fileprivate func stringToArray(_ str: String) -> [String]{
        var array: [String] = []
        for (_, c) in str.characters.enumerated() {
            array.append(String(c))
        }
        return array
    }
    
    
}


//MARK: - RegexMethods
fileprivate func isChineseID(id: String) -> Bool {
    return id =~ RegexChineseID
}

fileprivate func is15ChineseID(id: String) -> Bool {
    return id =~ Regex15ChineseID
}

fileprivate func is18ChineseID(id: String) -> Bool {
    return id =~ Regex18ChineseID
}

fileprivate func isDigital(str: String) -> Bool {
    return str =~ RegexDigital
}


// 15&&18位身份证号码数字和位数校验
fileprivate let RegexChineseID = "^(^\\d{15}$)|(\\d{17}(?:\\d|x|X)$)"
fileprivate let Regex15ChineseID = "^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$"
fileprivate let Regex18ChineseID = "^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([\\d|x|X]{1})$"
// 数字验证
fileprivate let RegexDigital = "^[0-9]*$"

// 自定义操作符
infix operator =~
func =~(str: String, matchs: String) -> Bool {
    do {
        return try RegexHelper(matchs).match(str)
    } catch _ {
        return false
    }
}

/// 正则操作类
class RegexHelper {
    
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern,
                                        options: .caseInsensitive)
    }
    func match(_ inputStr: String) -> Bool {
        let matches = regex.matches(in: inputStr,
                                    options: [],
                                    range: NSMakeRange(0, inputStr.length))
        return matches.count > 0
    }
    
}

// String 拓展
extension String {
    /// 字符串长度
    var length: Int {
        return self.characters.count
    }
    
    /// 截取字符串 from
    /// - Parameter from: 开始位置
    func substring(from: UInt) -> String {
        
        guard self.length > Int(from) else {
            return ""
        }
        return self.substring(from: self.index(self.startIndex, offsetBy:String.IndexDistance(from)))
    }
    /// 截取字符串 to
    /// - Parameter to: 结束为止
    func substring(to: UInt) -> String {
        guard self.length >= Int(to) else {
            return self
        }
        return self.substring(to: self.index(self.startIndex, offsetBy:String.IndexDistance(to)))
    }
    /// 截取字符串 to
    /// - Parameter to: 结束为止
    func substring(range: NSRange) -> String {
        
        if let r = range.toRange() {
            let start = self.index(self.startIndex, offsetBy: r.lowerBound)
            let end = self.index(self.startIndex, offsetBy: r.upperBound)
            return self.substring(with: Range(start..<end))
        }
        return self
        
    }
}
