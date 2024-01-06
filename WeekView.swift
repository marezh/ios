//
//  WeekView.swift
//  MSP
//
//  Created by Marko Lazovic on 05.12.23.
//

import SwiftUI
import Combine


struct WeekView: View {
    @StateObject private var realmManager = RealmManager()
    
    var date: Date
    var body: some View {
        
        NavigationView {
            ZStack{
                Image(GetTheTimeOfDayForBackground())
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                ScrollViewReader { scrollView in
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 10) {
                            
                            ForEach(getAllYears(), id: \.self) { year in
                                WeekColumnView(year: year, baseDate: date, realmManager: realmManager)                        .scrollTargetLayout()
                                    .safeAreaPadding(.horizontal, 12.0)
                                
                                
                                
                                
                            }
                            .onAppear {
                                
                                scrollView.scrollTo(getId(week: date), anchor: .center)
                                
                                
                            }
                        }
                        
                        
                    }
                    .scrollTargetBehavior(.viewAligned)
                    
                    
                }
                .contentMargins(0, for: .scrollContent)
                .padding(.top)
                .ignoresSafeArea()
                
                
            }
            
        }
        .navigationBarHidden(true)
    }
}

func getId(week: Date) -> String {
    let id = "\(week.get(.yearForWeekOfYear)) \(week.get(.weekOfYear))"
    return id
}
func getIdKW(week: Date) -> String {
    let weekOfYear = week.get(.weekOfYear)
    return "\(weekOfYear)"
}
func getIdYear(week: Date) -> String {
    let YearOfYear = week.get(.yearForWeekOfYear)
    return "\(YearOfYear)"
}

struct WeekColumnView: View {
    var year: Date
    var baseDate: Date
    
    
    var realmManager: RealmManager
    var body: some View {
        LazyHStack(spacing: 30) {
            ForEach(getAllWeeks(yearStart: year), id: \.self) { week in
                VStack(spacing: 10) {
                    HStack{
                        
                        ZStack{
                            Circle()
                                .stroke(.gray.opacity(0.4), style: StrokeStyle(lineWidth: 3))
                            Circle()
                                .trim(from: 0, to: CGFloat(min(Double(0.3) / 9.0, 1.0)))
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(width: 55, height: 55)
                        .offset(x: -100, y: 0)
                        
                        VStack(alignment: .leading){
                            Text("Woche \(getIdKW(week:week))")
                                .foregroundColor(.white)
                                .bold()
                                .font(.system(size: 20))
                            
                            Text(getIdYear(week:week))
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            
                        }
                        .offset(x: -80, y: 0)
                    }
                    .frame(width: 355, height: 70)
                    .cornerRadius(10)
                    .offset(x: 0, y: -30)
                    ForEach(0..<7) { day in
                        if let dayDate = WeekViewController.calendar.date(byAdding: .day, value: day, to: week) {
                            
                            
                            DayView(date: dayDate, realmManager: realmManager )
                            
                        }
                    }
                }
                .id(getId(week: week))
            }
            
        }
    }
    private func dayFullInformation(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE d MMMM M yyyy"
        return formatter.string(from: date)
        
    }
}

struct DayView: View {
    var date: Date
    var realmManager: RealmManager
    var totalHours: Int {
        realmManager.getTotalHours(for: "\(dayFullInformation(date))")
    }
    
    var calculatedValue: CGFloat {
        CGFloat(Double(totalHours) / 9.0)
    }
    var hoursColor: Color {
        switch totalHours {
        case 0:
            return .gray
        case 1...5:
            return .red
        case 6...7:
            return .yellow
        default:
            return .green
        }
    }
    var percentage: Int {
        Int((Double(totalHours) / 9.0) * 100)
    }
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }()
    
    
    var isToday: Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    
    var body: some View {
        
        NavigationLink(destination: DayOpenView(datum: dayFullInformation(date))) {
            VStack(alignment: .leading) {
                
                HStack{
                    
                    ZStack(){
                        Circle()
                            .stroke(.gray.opacity(0.4), style: StrokeStyle(lineWidth: 3))
                        Circle()
                            .trim(from: 0, to: CGFloat(min(Double(totalHours) / 9.0, 1.0)))
                            .stroke(hoursColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        if percentage == 0{
                            Text(" ")
                                .font(.system(size: 10))
                                .foregroundColor(hoursColor)
                        }else{
                            Text("\(percentage)%")
                                .font(.system(size: 10))
                                .foregroundColor(hoursColor)
                        }
                        
                        
                    }.offset(x: 10, y: 0)
                        .frame(width: 45, height: 45)
                    
                    VStack{
                        HStack{
                            Text(dayOfWeek(date))
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 80)
                            
                            Text("\(realmManager.getTotalHours(for: "\(dayFullInformation(date))"))Std. \(realmManager.getTotalMinutes(for: "\(dayFullInformation(date))"))Min").offset(x: 50,y:0).foregroundColor(    realmManager.getTotalHours(for: "\(dayFullInformation(date))") == 0 ? Color.gray :
                                                                                                                                                                                                                        realmManager.getTotalHours(for: "\(dayFullInformation(date))") > 5 && realmManager.getTotalHours(for: "\(dayFullInformation(date))") < 7 ? Color.yellow :
                                                                                                                                                                                                                        realmManager.getTotalHours(for: "\(dayFullInformation(date))") >= 7 ? Color.green : Color.red)
                            
                        }
                        
                        
                        Text(dayOfMonth(date))
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 80)
                    }
                    .offset(x: -60, y: 0)
                    
                }
                
                
                
            }
            .frame(width: 355, height: 70)
            .overlay (
                RoundedRectangle(cornerRadius: 10).stroke(isToday ? Color.gray : Color.clear)
            )
            .background(Color.black.opacity(0.4))
            .cornerRadius(10)
        }
        
    }
    
    
    func dayOfWeek(_ date: Date) -> String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func dayFullInformation(_ date: Date) -> String {
        dateFormatter.dateFormat = "EEEE d MMMM M yyyy"
        return dateFormatter.string(from: date)
    }
    func dayOfMonth(_ date: Date) -> String {
        dateFormatter.dateFormat = "d. MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    

}
