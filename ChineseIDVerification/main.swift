//
//  main.swift
//  ChineseIDVerification
//
//  Created by wpf on 2017/3/4.
//  Copyright © 2017年 wpf. All rights reserved.
//

import Foundation

print("Hello, World!")

// 验证请输入自己身份证号码

let oc = OCCode()
let result1 = oc.isValidatedChineseID("")
print(result1)

let swift = SwiftCode()
let result2 = swift.isValidatedChineseID("")
print(result2)

