//
//  ContentView.swift
//  BetterRest
//
//  Created by OAA on 14/08/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var bedtime: String {
        bedtimeWithoutAlert()
    }
    
    // static -> can be accessed anytime. Otherwise wakeup cannot reads it
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
    
        VStack {
            NavigationView {
                
                Form {
                    
                    Section {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    } header: {
                        Text("When do you want to wake up?")
                            .font(.headline)
                    }
                    
                    
                    Section {
    //                    Text("Desired amount of sleep")
    //                        .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    } header: {
                        Text("Desired amount of sleep").font(.headline)
                    }
                        
                    
                    Section {

                        Picker("How many cups", selection: $coffeeAmount) {
                            ForEach(1..<20) {
                                Text($0 == 1 ? "1 cup" : "\($0) cups")
                            }
                        }
    //
    //                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                        
                    } header: {
                        Text("Daily coffee intake")
                            .font(.headline)
                    }

                }
                .navigationTitle("BetterRest")
    //            .toolbar {
    //                Button("Calculate", action: calculateBedTime)
    //            }
    //            .alert(alertTitle, isPresented: $showAlert) {
    //                Button("OK") {}
    //            } message: {
    //                Text(alertMessage)
    //            }
                       
                            
            }
            
            Text("Your ideal bedtime is:")
                .font(.title)
                 
            Text("\(bedtime)")
                .font(.system(size: 24, weight: .heavy))
        }
        
        
    }
    
    func calculateBedTime() {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60 // Nil Coalesceing is just in case
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is: "
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            alertTitle = "Error"
            alertMessage = "Sorry, there was an issue in calculation."
            
        }
        
        showAlert = true
    }
    
    func bedtimeWithoutAlert() -> String {
        
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60 // Nil Coalesceing is just in case
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
//            alertTitle = "Your ideal bedtime is: "
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            
            return "Error"
//            alertTitle = "Error"
//            alertMessage = "Sorry, there was an issue in calculation."
            
        }
        
//        showAlert = true
    }
    
    
    
    
    
    
    
    
    
//
//    func exampleDate() {
//        let tomorrow = Date.now.addingTimeInterval(86400)
//        let range = Date.now...tomorrow
//    }
//
//    func trivialExample() {
//        var components = DateComponents()
//        components.hour = 8
//        components.minute = 0
//        let date = Calendar.current.date(from: components) ?? Date.now
//
//        let components2 = Calendar.current.dateComponents([.hour, .minute], from: Date.now)
//        let hour = components2.hour ?? 0
//        let minute = components2.minute ?? 0
//    }
//
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
