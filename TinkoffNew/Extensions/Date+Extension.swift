//
//  Date+Extenstions.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 03/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import Foundation

extension Date {
    private struct DateFormatters {
        static let todayFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
        
        static let passedDaysFormatter = { () -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            return formatter
        }()
    }
    
    func getDateForMessage() -> String {
        if Calendar.current.isDateInToday(self) {
            return DateFormatters.todayFormatter.string(from: self)
        } else {
            return DateFormatters.passedDaysFormatter.string(from: self)
        }
    }
}
