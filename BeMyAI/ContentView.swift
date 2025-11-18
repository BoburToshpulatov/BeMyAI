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
                ComingSoonView()
            }
            Tab("Be My AI", systemImage: "camera"){
                BeMyAI()
            }
            Tab("Community", systemImage: "person.3"){
                ComingSoonView()
            }
            Tab("Settings", systemImage: "gearshape"){
                ComingSoonView()
            }
        }
        
    }
}

#Preview {
    ContentView()
}
