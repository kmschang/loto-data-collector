//
//  LOTOEditView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI

struct LOTOEditView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Bindable var item:LOTO
    
    private func updateDateEdited() {
        item.dateEdited = Date.now
    }
    
    @State private var sourceEdit:SourceInfo?

    var body: some View {
        NavigationStack {
            Group {
                List {
                    Section(header: Text("General"), footer: Text("\(item.status.statusString) | \(item.favorite.favoriteString)")) {
                        textField(fieldName: "Form Name", fieldData: $item.formName, onEdit: updateDateEdited)
                        Picker("Form Status", selection: $item.status) {
                            ForEach(Status.allCases) { status in
                                status.statusIcon
                                    .tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        Picker("Favorite", selection: $item.favorite) {
                            ForEach(Favorite.allCases) { status in
                                status.favoriteIcon
                                    .tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                    }
                    
                    Section(header: Text("Main Information")) {
                        textField(fieldName: "Description", fieldData: $item.formDescription, onEdit: updateDateEdited)
                        numberField(fieldName: "Procedure Number", upperLimit: 3, fieldData: $item.procedureNumber, onEdit: updateDateEdited)
                        textField(fieldName: "Facility", fieldData: $item.facility, onEdit: updateDateEdited)
                        textField(fieldName: "Location", fieldData: $item.location, onEdit: updateDateEdited)
                        numberField(fieldName: "Revision", upperLimit: 1, fieldData: $item.revision, onEdit: updateDateEdited)
                        dateField(fieldName: "Date", fieldData: $item.revisionDate, onEdit: updateDateEdited)
                        dateField(fieldName: "Origin", fieldData: $item.originDate, onEdit: updateDateEdited)
                        textField(fieldName: "Notes", fieldData: $item.notes, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Isolation Points")) {
                        numberField(fieldName: "Isolation Points", upperLimit: 1, fieldData: $item.isolatoinPoints, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Sources")) {
                        
                        
                        ForEach(item.sourceInfo) { source in
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
                                        if let index = item.sourceInfo.firstIndex(where: { $0.id == source.id }) {
                                            item.sourceInfo.remove(at: index)
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
                                item.sourceInfo.append(SourceInfo(source_id: "", source_type: .electrical, source_device: "", source_location: "", source_method: "", source_check: ""))
                                updateDateEdited()
                            }
                        } label: {
                            Label("Add Source", systemImage: "plus")
                        }
                        .disabled(item.sourceInfo.count >= 8)
                        
                    }
                        

                    
                    Section(header: Text("Shutdown Sequence Steps")) {
                        textField(fieldName: "Machine Stop Step", fieldData: $item.machineShopSequence, onEdit: updateDateEdited)
                        textField(fieldName: "Isolate Step", fieldData: $item.isolateSequence, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Additional Notes")) {
                        textField(fieldName: "Additional Notes", fieldData: $item.additionalNotes, onEdit: updateDateEdited)
                    }
                    
                    Section(header: Text("Completion and Approval")) {
                        textField(fieldName: "Completed By", fieldData: $item.completedBy, onEdit: updateDateEdited)
                        textField(fieldName: "Approval By", fieldData: $item.approvedBy, onEdit: updateDateEdited)
                        textField(fieldName: "Approval Company", fieldData: $item.approvedByCompany, onEdit: updateDateEdited)
                        dateField(fieldName: "Approval Date", fieldData: $item.approvalDate, onEdit: updateDateEdited)
                    }
                    
                    Section {
                        VStack(spacing: 10) {
                            Text("Date Added: \(formattedDateTime(item.dateAdded))")
                            Text("Last Edited: \(formattedDateTime(item.dateEdited))")
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .font(.subheadline)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .sheet(item: $sourceEdit) {
                sourceEdit = nil
            } content: { item in
                SourceEditView(source: item)
            }
            .navigationTitle(item.formName)
            .navigationBarTitleDisplayMode(.large)
            .interactiveDismissDisabled(!isValidName(item.formName))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .disabled(!isValidName(item.formName))
                }
            }
        }
    }
}

#Preview {
    LOTOEditView(item: LOTO(formName: "", formDescription: "", procedureNumber: "", facility: "", location: "", revision: "", revisionDate: Date.now, originDate: Date.now, isolatoinPoints: "", notes: "", sourceInfo: [], machineShopSequence: "", isolateSequence: "", additionalNotes: "", completedBy: "", approvedBy: "", approvedByCompany: "", approvalDate: Date.now, status: .inProgress, favorite: .notFavorite, dateAdded: Date.now, dateEdited: Date.now))
}
