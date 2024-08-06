//
//  LOTOListView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI
import SwiftData

struct LOTOListView: View {
    
    // Swift Data Model
    @Environment(\.modelContext) var modelContext
    @Query var LOTOItems: [LOTO]
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var showAddSheet:Bool = false
    @State private var showSettingsSheet:Bool = false

    @State private var searchString:String = ""
    
    @State private var LOTOEdit: LOTO?
    
    var body: some View {
        
        NavigationStack {
            Group {
                ZStack {
                    // LOTO List
                    List {
                        Section(header: Text("All Forms")) {
                            ForEach(LOTOItems) { item in
                                Button {
                                    LOTOEdit = item
                                } label: {
                                    HStack(spacing: 10) {
                                        VStack {
                                            Spacer()
                                            HStack(spacing: 10) {
                                                item.status.statusIcon
                                                    .foregroundStyle(item.status.statusColor)
                                            }
                                            Spacer()
                                        }
                                        VStack(alignment: .leading) {
                                            Text(item.formName)
                                                .font(.headline)
                                            if !item.formDescription.isEmpty {
                                                Text(item.formDescription)
                                                    .font(.subheadline)
                                                    .lineLimit(2)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            deleteItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    Button {
                                        withAnimation {
                                            updateItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        withAnimation {
                                            favoriteItem(item)
                                        }
                                    } label: {
                                        item.favorite.favoriteIconOpposite
                                    }
                                    .tint(.yellow)
                                    Button {
                                        withAnimation {
                                            duplicateItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "square.and.arrow.down.on.square.fill")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                    
                    // Add Button
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button {
                                showAddSheet.toggle()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 30))
                                }
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding()
                            .background(colorScheme == .dark ? Color(hex: "1C1C1F") : Color(hex: "EFEFF0"))
                            .cornerRadius(50)
                        }
                    }
                    .padding()
                    .padding(.horizontal, 20)
                    
                }
            }
            .navigationTitle("LOTO Forms")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(text: $searchString, prompt: "Seach for LOTO Forms")
            .listStyle(.plain)
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    LOTOAddView()
                }
                .presentationDetents([.large])
            }
            .sheet(item: $LOTOEdit) {
                LOTOEdit = nil
            } content: { item in
                LOTOEditView(item: item)
            }
            .overlay {
                if LOTOItems.isEmpty && !searchString.isEmpty {
                    ContentUnavailableView(
                        "No Results for \"\(searchString)\"",
                        systemImage: "magnifyingglass",
                        description: Text("Check the spelling or try a new search")
                    )
                }
                if searchString.isEmpty && LOTOItems.isEmpty{
                    ContentUnavailableView(
                        "No LOTO Forms",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Click the + button to add LOTO Forms")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 10) {
                        Button {
                            
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        
                        Button {
                            
                        } label: {
                            Label("Undo", systemImage: "arrow.uturn.backward.circle")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 10) {
                        Button {
                            
                        } label: {
                            Label("Sort", systemImage: "ellipsis.circle")
                        }
                        
                        Button {
                            
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
        }
    }
    
    func duplicateItem(_ item:LOTO) {
        modelContext.insert(item.duplicate())
    }
    
    func updateItem(_ item:LOTO) {
        LOTOEdit = item
    }
    
    func favoriteItem(_ item:LOTO) {
        if (item.favorite == .isFavorite) {
            item.favorite = .notFavorite
        } else {
            item.favorite = .isFavorite
        }
    }
    
    func deleteItem(_ item: LOTO) {
        modelContext.delete(item)
    }
    
}

#Preview {
    LOTOListView()
        .modelContainer(for: LOTO.self, inMemory: true)
}



