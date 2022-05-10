//
//  DynamicFilteredView.swift
//  SimpleTaskManager
//
//  Created by Vitalii Azarov on 2022-05-10.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject {
    
    //MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    //MARK: Building Custom ForEach which will give Coredata object to build View
    init(currentTab: String, @ViewBuilder content: @escaping (T)->Content) {
        
        //MARK: Predicate to Filter current date Tasks
        let calendar = Calendar.current
        var predicate: NSPredicate!
        
        if currentTab == "Today" {
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            //Filter key
            let filterKey = "deadline"
            
            //This will fetch tasks between today and tomorrow which is 24 hours
            //0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else if currentTab == "Upcoming" {
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tomorrow = Date.distantFuture
            
            //Filter key
            let filterKey = "deadline"
            
            //This will fetch tasks between today and tomorrow which is 24 hours
            //0-false, 1-true
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else {
            
        }
        
        // Initializing Request With NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: predicate)
        self.content = content
        
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No tasks found!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}

//struct DynamicFilteredView_Previews: PreviewProvider {
//    static var previews: some View {
//        DynamicFilteredView()
//    }
//}
