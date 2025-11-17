//
//  ContentView.swift
//  BeMyAI
//
//  Created by Bobur Toshpulatov on 14/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView(){
            Tab("Get Support", systemImage: "video"){
                Text("Coming Soon")
            }
            Tab("Be My AI", systemImage: "camera"){
                BeMyAI()
            }
            Tab("Community", systemImage: "person.3"){
                Text("Coming Soon")
            }
            Tab("Settings", systemImage: "gearshape"){
                Text("Coming Soon")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
