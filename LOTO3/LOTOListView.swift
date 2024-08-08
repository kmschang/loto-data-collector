//
//  LOTOListView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI
import SwiftData
import PDFKit
import UIKit

struct LOTOListView: View {
    
    // Swift Data Model
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<LOTO> { loto in
        !loto.deleted}, sort: \LOTO.formName)
    
    var LOTOItems: [LOTO]

    @State private var sortingForward: Bool = true
    
    var filteredAndSortedItems: [LOTO] {
        let filteredBySearch = LOTOItems.filter { item in
            searchString.isEmpty ||
            item.formName.localizedCaseInsensitiveContains(searchString) ||
            item.formDescription.localizedCaseInsensitiveContains(searchString) ||
            item.procedureNumber.localizedCaseInsensitiveContains(searchString) ||
            item.sourceInfo.contains { $0.source_type.sourceString.localizedCaseInsensitiveCompare(searchString) == .orderedSame }
        }
        let filtered = filterItems(filteredBySearch)
        if (sortingForward) {
            return sortItems(filtered)
        } else {
            return sortItems(filtered).reversed()
        }
    }

    @State private var deletedItems: [LOTO] = []
    @State private var recoveredItems: [LOTO] = []

    func filterItems(_ items: [LOTO]) -> [LOTO] {
        switch selectedFilterOption {
        case .all:
            return items
        case .favorite:
            return items.filter { $0.favorite.isTrue }
        case .inProgress:
            return items.filter { $0.status == .inProgress }
        case .awaitingApproval:
            return items.filter { $0.status == .awaitingApproval }
        case .completed:
            return items.filter { $0.status == .completed }
        case .today:
            let calendar = Calendar.current
            return items.filter { calendar.isDateInToday($0.dateAdded) }
        case .electrical, .air, .water, .gas, .gravity, .othter:
            return items.filter { $0.sourceInfo.contains { $0.source_type.rawValue == selectedFilterOption.rawValue - 6 } }
        }
    }

    func sortItems(_ items: [LOTO]) -> [LOTO] {
        items.sort(on: selectedSortOption)
    }

    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var selectedSortOption: sortOption = .formName
    @State private var selectedFilterOption: filterOption = .all
    
    func checkForFavorites() -> Bool {
        return LOTOItems.contains { $0.favorite.isTrue == true }
    }
    
    @State private var showAddSheet:Bool = false
    @State private var showSettingsSheet:Bool = false

    @State private var searchString:String = ""
    
    @State private var LOTOEdit: LOTO?
    @State private var LOTOShare: LOTO?
    
    @State private var selectedRows = Set<String>()
    @State private var isEditing: Bool = false
    
    @State private var multiDeleteAlert:Bool = false
        
    var body: some View {
        
        NavigationStack {
            Group {
                ZStack {
                    // LOTO List
                    List(selection: $selectedRows) {
                        Section (
                            header: CustomHeaderView(
                                title: "All Forms",
                                selectedSortOption: $selectedSortOption,
                                ascending: sortingForward,
                                sortDirection: {
                                    sortingForward.toggle()
                                }
                            ))
                        {
                            ForEach(filteredAndSortedItems) { item in
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
                                            HStack(spacing: 10) {
                                                Text(item.formName)
                                                    .font(.headline)
                                                if item.favorite.isTrue {
                                                    Image(systemName: "star.fill")
                                                        .foregroundStyle(.yellow)
                                                }
                                            }
                                            switch selectedSortOption {
                                            case .formName, .formDescription, .favorite:
                                                if !item.formDescription.isEmpty {
                                                    Text(item.formDescription)
                                                        .font(.subheadline)
                                                        .lineLimit(2)
                                                }
                                            case .procedureNumber:
                                                if !item.procedureNumber.isEmpty {
                                                    Text("#\(item.procedureNumber)")
                                                        .font(.subheadline)
                                                        .lineLimit(1)
                                                }
                                            case .dateAdded:
                                                Text(formattedDateTime(item.dateAdded))
                                                    .font(.subheadline)
                                            case .dateEdited:
                                                Text(formattedDateTime(item.dateEdited))
                                                    .font(.subheadline)
                                            case .sourceType:
                                                sourceDescription(item: item)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        updateItem(item)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button {
                                        favoriteItem(item)
                                    } label: {
                                        Label("Favorite", systemImage: "star.fill")
                                    }
                                    Button {
                                        exportItem(item)
                                    } label: {
                                        Label("Export", systemImage: "square.and.arrow.up")
                                    }
                                    Button {
                                        markAsDeleted(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            markAsDeleted(item)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    Button {
                                        withAnimation {
                                            duplicateItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "square.and.arrow.down.on.square.fill")
                                    }
                                    .tint(.green)
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
                                            exportItem(item)
                                        }
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
//                    .refreshable {
//                        print("Refreshed")
//                    }
                    .environment(\.editMode, isEditing ? .constant(.active) : .constant(.inactive))
                    
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
            .sheet(item: $LOTOShare) {
                 LOTOShare = nil
            } content: { item in
                LOTOExportView(item: item)
                    .interactiveDismissDisabled()
            }
            .overlay {
                if filteredAndSortedItems.isEmpty && !searchString.isEmpty {
                    ContentUnavailableView(
                        "No Results for \"\(searchString)\"",
                        systemImage: "magnifyingglass",
                        description: Text("Check the spelling or try a new search")
                    )
                }
                if searchString.isEmpty && filteredAndSortedItems.isEmpty && selectedFilterOption == .all {
                    ContentUnavailableView(
                        "No LOTO Forms",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Click the + button to add LOTO Forms")
                    )
                }
                if searchString.isEmpty && filteredAndSortedItems.isEmpty && selectedFilterOption != .all {
                    ContentUnavailableView(
                        "No \(selectedFilterOption.filterString) LOTO Forms",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Click the + button to add LOTO Forms")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    withAnimation {
                        ZStack {
                            HStack(spacing: 10) {
                                Button {
                                    print("Settings")
                                } label: {
                                    Label("Settings", systemImage: "gear")
                                }
                                Button {
                                    undoDelete()
                                } label: {
                                    Label("Undo", systemImage: "arrow.uturn.backward.circle")
                                }
                                .disabled(deletedItems.isEmpty)
                                
                                Button {
                                    redoDelete()
                                } label: {
                                    Label("Redo", systemImage: "arrow.uturn.forward.circle")
                                }
                                .disabled(recoveredItems.isEmpty)
                            }
                            .opacity(isEditing ? 0 : 1)
                            
                            HStack(spacing: 20) {
                                Button() {
                                    withAnimation {
                                        multiDeleteAlert = true
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .foregroundStyle(.red)
                                }
                                .alert("Are you sure you want to delete \(selectedRows.count) \(selectedRows.count == 1 ? "item" : "items")? This can't be undone.", isPresented: $multiDeleteAlert) {
                                            Button("Yes", role: .destructive) {
                                                withAnimation {
                                                    deleteSelectedItems()
                                                    isEditing = false
                                                }
                                            }
                                    Button("Cancel", role: .cancel) {
                                        withAnimation {
                                            isEditing = false
                                        }
                                    }
                                }
                                Button {

                                } label: {
                                    Label("Export", systemImage: "square.and.arrow.up")
                                }
                                .disabled(true)
                                Spacer()
                            }
                            .opacity(isEditing ? 1 : 0)
                        }
                    }
                    
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 10) {
                        Button {
                            isEditing.toggle()
                        } label: {
                            Label("Select", systemImage: "checkmark.circle")
                        }

                        Menu {
                            Picker("Filter", selection: $selectedFilterOption) {
                                ForEach(filterOption.allCases) { option in
                                    Label(option.filterString, systemImage: option.filterIconString)
                                        .foregroundColor(option.filterIconColor)
                                        .tag(option)
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: selectedFilterOption.filterIconString)
                                .foregroundStyle(selectedFilterOption.filterIconColor)
                                .tint(selectedFilterOption.filterIconColor)
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
    
    func exportItem(_ item:LOTO) {
        LOTOShare = item
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
    
    func markAsDeleted(_ item: LOTO) {
        item.deleted = true
        deletedItems.append(item)
        try? modelContext.save()
    }
    
    private func deleteSelectedItems() {
        let itemsToDelete = filteredAndSortedItems.filter { selectedRows.contains($0.id) }
        itemsToDelete.forEach { item in
            markAsDeleted(item)
        }
        selectedRows.removeAll()
    }
    
    func redoDelete() {
        guard let lastRecovered = recoveredItems.popLast() else { return }
        lastRecovered.deleted = true
        deletedItems.append(lastRecovered)
        try? modelContext.save()
    }
    
    func undoDelete() {
        guard let lastDeleted = deletedItems.popLast() else { return }
        lastDeleted.deleted = false
        recoveredItems.append(lastDeleted)
        try? modelContext.save()
    }
    
}

#Preview {
    LOTOListView()
        .modelContainer(for: LOTO.self, inMemory: true)
}





enum sortOption: Int, Codable, Identifiable, CaseIterable {
    
    case formName = 1, formDescription, favorite, procedureNumber, sourceType, dateAdded, dateEdited
    
    var id: Self {
        self
    }
    
    var sortString: String {
        switch self {
        case .formName:
            return "Title"
        case .formDescription:
            return "Description"
        case .procedureNumber:
            return "Procedure Number"
        case .dateAdded:
            return "Date Added"
        case .dateEdited:
            return "Date Edited"
        case .sourceType:
            return "Source Type"
        case .favorite:
            return "Favorite"
        }
    }
    
    var sortIconString: String {
        switch self {
        case .formName:
            return "character"
        case .formDescription:
            return "character"
        case .procedureNumber:
            return "number"
        case .dateAdded:
            return "calendar"
        case .dateEdited:
            return "calendar"
        case .sourceType:
            return "poweroutlet.type.b"
        case .favorite:
            return "star.fill"
        }
    }
    
    var sortIconColor: Color {
        switch self {
        case .formName:
            return .blue
        case .formDescription:
            return .orange
        case .procedureNumber:
            return .yellow
        case .dateAdded:
            return .red
        case .dateEdited:
            return .red
        case .sourceType:
            return .teal
        case .favorite:
            return .yellow
        }
    }
}

private extension Array where Element == LOTO {
    func sort(on option: sortOption) -> [LOTO] {
        switch option {
        case .formName:
            return self.sorted { $0.formName < $1.formName }
        case .formDescription:
            return self.sorted { $0.formDescription < $1.formDescription }
        case .procedureNumber:
            return self.sorted { $0.procedureNumber < $1.procedureNumber }
        case .dateAdded:
            return self.sorted { $0.dateAdded > $1.dateAdded }
        case .dateEdited:
            return self.sorted { $0.dateEdited > $1.dateEdited }
        case .sourceType:
            return self.sorted {
                ($0.sourceInfo.first?.source_type.rawValue ?? 0) <
                ($1.sourceInfo.first?.source_type.rawValue ?? 0)
            }
        case .favorite:
            return self.sorted {
                // First, sort by favorite status (true first), then by formName
                if $0.favorite.isTrue != $1.favorite.isTrue {
                    return $0.favorite.isTrue && !$1.favorite.isTrue
                } else {
                    return $0.formName < $1.formName
                }
            }
        }
    }
}

enum filterOption: Int, Codable, Identifiable, CaseIterable {
    
    case all = 1, favorite, today, inProgress, awaitingApproval, completed, electrical, air, water, gas, gravity, othter
    
    var id: Self {
        self
    }
    
    var filterString: String  {
        switch self {
        case .all:
            return "All"
        case .favorite:
            return "Favorite"
        case .inProgress:
            return "In Progress"
        case .awaitingApproval:
            return "Awaiting Approval"
        case .completed:
            return "Completed"
        case .today:
            return "Today"
        case .electrical:
            return "Electrical"
        case .air:
            return "Air"
        case .water:
            return "Water"
        case .gas:
            return "Gas"
        case .gravity:
            return "Gravity"
        case .othter:
            return "Other"
        }
    }
    
    var filterIconString: String {
        switch self {
        case .all :
            return "ellipsis.circle"
        case .favorite:
            return "star.fill"
        case .inProgress:
            return "smallcircle.filled.circle"
        case .awaitingApproval:
            return "circle.dashed.inset.filled"
        case .completed:
            return "checkmark.circle.fill"
        case .today:
            return "calendar"
        case .electrical:
            return "bolt.fill"
        case .air:
            return "wind"
        case .water:
            return "drop.fill"
        case .gas:
            return "fuelpump.fill"
        case .gravity:
            return "globe.americas.fill"
        case .othter:
            return "diamond.inset.filled"
        }
    }
    
    var filterIconColor:Color {
        switch self {
        case .all:
            return .blue
        case .favorite:
            return .yellow
        case .inProgress:
            return .red
        case .awaitingApproval:
            return .purple
        case .completed:
            return .green
        case .today:
            return .red
        case .electrical:
            return .yellow
        case .air:
            return .teal
        case .water:
            return .green
        case .gas:
            return .red
        case .gravity:
            return .purple
        case .othter:
            return .primary
        }
    }
}

struct sourceDescription: View {
    
    let item: LOTO
    
    var body: some View {
        
        HStack(spacing: 10) {
            ForEach(Array(Set(item.sourceInfo.map { $0.source_type })), id: \.self) { sourceType in
                HStack(spacing: 2) {
                    if (UIScreen.screenWidth >= 700) {
                        Image(systemName: sourceType.sourceIconString)
                            .foregroundColor(sourceType.sourceColor)
                        Text(sourceType.sourceString)
                            .font(.caption)
                    } else {
                        Image(systemName: sourceType.sourceIconString)
                            .foregroundColor(sourceType.sourceColor)
                    }
                }
            }
        }
    }
}

struct CustomHeaderView: View {
    var title: String
    @Binding var selectedSortOption: sortOption
    var ascending: Bool
    var sortDirection: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Text(title)
            Spacer()
            Menu {
                Picker("Sort", selection: $selectedSortOption) {
                    ForEach(LOTO3.sortOption.allCases) { option in
                        Label(option.sortString, systemImage: option.sortIconString)
                            .foregroundColor(option.sortIconColor)
                            .tag(option)
                    }
                }
            } label: {
                HStack(spacing: 5){
                    Image(systemName: "line.3.horizontal.decrease")
                }
            }
            
            Image(systemName: ascending ? "arrow.down" : "arrow.up")
                .foregroundStyle(.blue)
                .onTapGesture {
                    sortDirection()
                }
        }
    }
}


struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
