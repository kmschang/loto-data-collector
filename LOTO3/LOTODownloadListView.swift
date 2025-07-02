//
//  LOTODownloadListView.swift
//  LOTO3
//
//  Created by Kyle Schang on 7/2/25.
//

import SwiftUI

struct LOTODownloadListView: View {
    
    @State private var searchString:String = ""
    
    @State private var showSettingsSheet:Bool = false


    var body: some View {
        
        NavigationStack {
            Group {
                ZStack {
                    List {
                     
                        
                        
                    }
                        
                }
                
            }
            .navigationTitle("Downloaded PDF's")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $searchString, prompt: "Seach ... ")
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    withAnimation {
                        ZStack {
                            HStack(spacing: 10) {
                                Button {
                                    showSettingsSheet = true
                                } label: {
                                    Label("Settings", systemImage: "gear")
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettingsSheet, content: {
                NavigationView {
                    LOTOSettingView()
                }
            })
            .overlay {
                ContentUnavailableView(
                    "No Downloaded PDF's",
                    systemImage: "list.bullet.rectangle.portrait",
                    description: Text("Geneate PDF to see download")
                )
            }
        }
        
    }
}

#Preview {
    LOTODownloadListView()
}
