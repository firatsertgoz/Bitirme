//
//  DateExtension.swift
//  Location
//
//  Created by Baris Can Vural on 4/11/15.
//  Copyright (c) 2015 Baris Can Vural. All rights reserved.
//

import Foundation


extension NSDate
{
    convenience
      init(dateString:String) {
      let dateStringFormatter = NSDateFormatter()
      dateStringFormatter.dateFormat = "yyyy-MM-dd"
      dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
      let d = dateStringFormatter.dateFromString(dateString)
      self.init(timeInterval:0, sinceDate:d!)
    }
 }