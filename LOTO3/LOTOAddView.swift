//
//  LOTOAddView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct LOTOAddView: View {
    
    // Swift Data Model
    @Environment(\.modelContext) var modelContext
    @Query var LOTOItems: [LOTO]
    
    // Environments
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FocusState private var startFocus:Bool
    @FocusState private var fieldIsFocused:Bool
    @State private var sourceEdit:SourceInfo?
    
    // Data
    //General Data
    @State private var formName:String = "Untitled Procedure"
    @State private var formDescription:String = ""
    @State private var procedureNumber:String = ""
    @State private var facility:String = ""
    @State private var location:String = ""
    @State private var revision:String = ""
    @State private var revisionDate:Date = Date.now
    @State private var originDate:Date = Date.now
    @State private var isolatoinPoints:String = ""
    @State private var notes:String = ""
    
    // Photos
    @State private var photosData:[Data] = []
    @State private var photoPickerPhotos:[PhotosPickerItem] = []
    @State private var photos:[UIImage] = []
    
    // Sources
    @State private var sourceInfo:[SourceInfo] = []
    
    // Shutdown Sequence
    @State private var machineShopSequence:String = ""
    @State private var isolateSequence:String = ""
    
    // Additional Notes
    @State private var additionalNotes:String = ""
    
    // Completion and Approval
    @State private var completedBy:String = ""
    @State private var approvedBy:String = ""
    @State private var approvedByCompany:String = ""
    @State private var approvalDate:Date = Date.now
    
    // Status
    @State private var status:Status = .inProgress
    
    // Favorite
    @State private var favorite:Favorite = .notFavorite
    
    // Dates
    @State private var dateAdded:Date = Date.now
    @State private var dateEdited:Date = Date.now
    private func updateDateEdited() {
        dateEdited = Date.now
    }
    
    
    var body: some View {
        
        NavigationStack {
            Group {
                List {
                    Section(header: Text("General"), footer: Text("\(status.statusString) | \(favorite.favoriteString)")) {
                        textField(fieldName: "Form Name", fieldData: $formName, onEdit: updateDateEdited)
                            .focused($startFocus)
                        Picker("Form Status", selection: $status) {
                            ForEach(Status.allCases) { status in
                                status.statusIcon
                                    .tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        Picker("Favorite", selection: $favorite) {
                            ForEach(Favorite.allCases) { status in
                                status.favoriteIcon
                                    .tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                    }
                    
                    Section(header: Text("Main Information")) {
                        textField(fieldName: "Description", fieldData: $formDescription, onEdit: updateDateEdited)
                        numberField(fieldName: "Procedure Number", upperLimit: 3, fieldData: $procedureNumber, onEdit: updateDateEdited)
                        textField(fieldName: "Facility", fieldData: $facility, onEdit: updateDateEdited)
                        textField(fieldName: "Location", fieldData: $location, onEdit: updateDateEdited)
                        numberField(fieldName: "Revision", upperLimit: 1, fieldData: $revision, onEdit: updateDateEdited)
                        dateField(fieldName: "Date", fieldData: $revisionDate, onEdit: updateDateEdited)
                        dateField(fieldName: "Origin", fieldData: $originDate, onEdit: updateDateEdited)
                        textField(fieldName: "Notes", fieldData: $notes, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Isolation Points")) {
                        numberField(fieldName: "Isolation Points", upperLimit: 1, fieldData: $isolatoinPoints, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Sources")) {
                        
                        ForEach(sourceInfo) { source in
                            Button {
                                sourceEdit = source
                            } label: {
                                HStack(spacing: 10) {
                                    source.source_type.sourceIcon
                                        .foregroundStyle(source.source_type.sourceColor)
                                    Text(source.source_id.isEmpty ? "\(source.source_type.sourceString)" : "\(source.source_type.sourceString) - \(source.source_id)")
                                        .tint(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .tint(.primary)
                                }
                            }
                            .onTapGesture {
                                sourceEdit = source
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        if let index = sourceInfo.firstIndex(where: { $0.id == source.id }) {
                                            sourceInfo.remove(at: index)
                                        }
                                        updateDateEdited()
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        Button {
                            withAnimation {
                                sourceInfo.append(SourceInfo(source_id: "", source_type: .electrical, source_device: "", source_location: "", source_method: "", source_check: ""))
                                updateDateEdited()
                            }
                        } label: {
                            Label("Add Source", systemImage: "plus")
                        }
                        .disabled(sourceInfo.count >= 8)
                        
                    }
                    
                    Section(header: Text("Shutdown Sequence Steps")) {
                        textField(fieldName: "Machine Stop Step", fieldData: $machineShopSequence, onEdit: updateDateEdited)
                        textField(fieldName: "Isolate Step", fieldData: $isolateSequence, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Additional Notes")) {
                        textField(fieldName: "Additional Notes", fieldData: $additionalNotes, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Completion and Approval")) {
                        textField(fieldName: "Completed By", fieldData: $completedBy, onEdit: updateDateEdited)
                        textField(fieldName: "Approval By", fieldData: $approvedBy, onEdit: updateDateEdited)
                        textField(fieldName: "Approval Company", fieldData: $approvedByCompany, onEdit: updateDateEdited)
                        dateField(fieldName: "Approval Date", fieldData: $approvalDate, onEdit: updateDateEdited)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Date Added: \(formattedDateTime(dateAdded))")
                            Text("Last Edited: \(formattedDateTime(dateEdited))")
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .font(.subheadline)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .onAppear {
                startFocus = true
            }
            .sheet(item: $sourceEdit) {
                sourceEdit = nil
            } content: { item in
                SourceEditView(source: item)
            }
            .onChange(of: status) {
                updateDateEdited()
            }
            .onChange(of: favorite) {
                updateDateEdited()
            }
            .navigationTitle(formName.isEmpty ? "Untitled Procedure" : formName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Add to LOTOItems
                        modelContext.insert(LOTO(formName: formName, formDescription: formDescription, procedureNumber: procedureNumber, facility: facility, location: location, revision: revision, revisionDate: revisionDate, originDate: originDate, isolatoinPoints: isolatoinPoints, notes: notes, sourceInfo: sourceInfo, machineShopSequence: machineShopSequence, isolateSequence: isolateSequence, additionalNotes: additionalNotes, completedBy: completedBy, approvedBy: approvedBy, approvedByCompany: approvedByCompany, approvalDate: approvalDate, status: status, favorite: favorite, dateAdded: dateAdded, dateEdited: dateEdited))
                        // Dismiss
                         dismiss()
                    } label: {
                        Text("Add")
                    }
                    .disabled(!isValidName(formName))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    LOTOAddView()
}


func formattedDateTime(_ date:Date) -> String {
    let formatter = DateFormatter()
    if areDatesOnTheSameDay(date1: Date.now, date2: date) {
        formatter.dateFormat = "'Today at' h:mm a"
        return formatter.string(from: date)
    } else if(isYesterday(date: date)) {
        formatter.dateFormat = "'Yesterday at' h:mm a"
        return formatter.string(from: date)
    } else if (isInPastDays(date: date, days: 6)) {
        formatter.dateFormat = "EEEE 'at' h:mm a"
        return formatter.string(from: date)
    } else {
        formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}

func isYesterday(date: Date) -> Bool {
    let calendar = Calendar.current
    let today = Date()
    
    // Get the start and end of today
    let startOfToday = calendar.startOfDay(for: today)
    _ = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
    
    // Get the start of yesterday
    let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    
    // Check if the date falls between the start and end of yesterday
    return date >= startOfYesterday && date < startOfToday
}

func isInPastDays(date: Date, days:Int) -> Bool {
    let calendar = Calendar.current
    let now = Date()
    
    // Get the start of today
    let startOfToday = calendar.startOfDay(for: now)
    
    // Calculate the date 6 days ago from the start of today
    guard let startOf6DaysAgo = calendar.date(byAdding: .day, value: -days, to: startOfToday) else {
        return false
    }
    
    // Check if the given date is between 6 days ago and now
    return date >= startOf6DaysAgo && date < startOfToday
}


struct textField: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let fieldName: String
    @Binding var fieldData: String
    @FocusState private var isFocused: Bool
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            TextField("\(fieldName)", text: $fieldData, axis: .vertical)
                .focused($isFocused)
                .onChange(of: fieldData) { oldValue, newValue in onEdit() }
            Spacer()
            if (!fieldData.isEmpty && isFocused) {
                Button {
                    fieldData = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

struct numberField:View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let fieldName:String
    let upperLimit:Int
    @Binding var fieldData:String
    @FocusState private var isFocused:Bool
    var onEdit: () -> Void
    
    private let filter = CharacterSet(charactersIn: "1234567890").inverted
    
    func limitText(_ upper: Int, _ string: String) -> String {
        if string.count > upper {
            return String(string.prefix(upper))
        } else {
            return string
        }
    }
    
    var body: some View {
        
        HStack {
            TextField(fieldName, text: $fieldData)
                .focused($isFocused)
                .onChange(of: fieldData) { oldValue, newValue in onEdit()}
                .keyboardType(.numberPad)
                .onChange(of: fieldData, { oldValue, newValue in
                    let filtered = newValue.uppercased().components(separatedBy: filter).joined()
                    if filtered != newValue {
                        self.fieldData = filtered
                    }
                    self.fieldData = limitText(upperLimit, fieldData)
                })
            Spacer()
            if (!fieldData.isEmpty && isFocused) {
                Button {
                    fieldData = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

struct dateField:View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let fieldName:String
    @Binding var fieldData:Date
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            Text("\(fieldName):")
            DatePicker("", selection: $fieldData, displayedComponents: .date)
                .onChange(of: fieldData) { oldValue, newValue in onEdit()}
            Spacer()
            if (!areDatesOnTheSameDay(date1: Date.now, date2: fieldData)) {
                Button {
                    fieldData = Date.now
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

func areDatesOnTheSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    
    // Extract year, month, and day components from both dates
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    // Compare components
    return components1 == components2
}

func isValidName(_ string: String?) -> Bool {

    guard let str = string, !str.isEmpty else {
        return false
    }
    

    guard str.count >= 5 else {
        return false
    }
    
    // Define a character set that includes letters, digits, and common punctuation
    let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-.' #:")
    
    // Check if all characters in the string are in the allowed set
    let characterSet = CharacterSet(charactersIn: str)
    return allowedCharacters.isSuperset(of: characterSet)
}
