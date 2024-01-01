//
//  WeekViewController.swift
//  MSP
//
//  Created by Marko Lazovic on 09.12.23.
//

import Foundation


class WeekViewController {
    
    
    static let calendar = createCalendar()
    
    private static func createCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
    
    static func isToday(date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: Date())
    }
}

extension Date {
    func get(_ component: Calendar.Component) -> Int {
        return WeekViewController.calendar.component(component, from: self)
    }
}

func getAllWeeks(yearStart: Date) -> [Date] {
    let calendar = WeekViewController.calendar
    
    var yearStartNew = yearStart
    while yearStartNew.get(.yearForWeekOfYear) != yearStart.get(.year) {
        yearStartNew = calendar.date(byAdding: .day, value: 1, to: yearStartNew)!
    }
    
    var weeks: [Date] = []
    let toDate = calendar.date(byAdding: .month, value: 12, to: yearStartNew)!
    var date = yearStartNew
    while date <= toDate {
        guard let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: date) else { break }
        if date.get(.yearForWeekOfYear) == yearStartNew.get(.yearForWeekOfYear) {
            weeks.append(date)
        }
    
        date = newDate
    }
    return weeks
}

func getAllYears() -> [Date] {
    let calendar = WeekViewController.calendar
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let today = dateFormatter.date(from: "01/01/2022")!
    var years = [Date]()
    if let weekInterval = calendar.dateInterval(of: .year, for: today) {
        for i in 0...2 {
            if let day = calendar.date(byAdding: .year, value: i, to: weekInterval.start) {
                years += [day]
            }
        }
    }
    return years
}




