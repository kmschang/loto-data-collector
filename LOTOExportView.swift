//
//  LOTOExportView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/8/24.
//

import SwiftUI
import PDFKit

struct LOTOExportView: View {
    
    @Bindable var item:LOTO
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "LOTO", withExtension: "pdf") {
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                        Spacer()
                        Button {
                            print("Exporting")
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                    PDFKitView(url: url, description: item.formName, item: item)
                }
            } else {
                VStack(spacing: 10){
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Text("Dismiss")
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                    ContentUnavailableView("PDF Not Found", systemImage: "list.bullet.clipboard.fill", description: Text("Can't find the file that you are looking for. Try restarting the app."))
                }
            }
        }
    }
}

#Preview {
    LOTOExportView(item: LOTO(formName: "", formDescription: "", procedureNumber: "", facility: "", location: "", revision: "", revisionDate: Date.now, originDate: Date.now, isolatoinPoints: "", notes: "", sourceInfo: [], machineShopSequence: "", isolateSequence: "", additionalNotes: "", completedBy: "", approvedBy: "", approvedByCompany: "", approvalDate: Date.now, status: .inProgress, favorite: .notFavorite, dateAdded: Date.now, dateEdited: Date.now))
}

func fillPDFFields(url: URL, description: String, item:LOTO) -> PDFDocument? {
    guard let document = PDFDocument(url: url) else { return nil }
    
    for i in 0..<document.pageCount {
        if let page = document.page(at: i) {
            for annotation in page.annotations {
                if annotation.fieldName == "Description" {
                    annotation.widgetStringValue = item.formDescription
                }
                if annotation.fieldName == "ProcedureNumber" {
                    annotation.widgetStringValue = item.procedureNumber
                }
                if annotation.fieldName == "Facility" {
                    annotation.widgetStringValue = item.facility
                }
                if annotation.fieldName == "Location" {
                    annotation.widgetStringValue = item.location
                }
                if annotation.fieldName == "Revision" {
                    annotation.widgetStringValue = item.revision
                }
                if annotation.fieldName == "RevisionDate" {
                    annotation.widgetStringValue = formatDateToMMDDYY(item.revisionDate)
                }
                if annotation.fieldName == "OriginDate" {
                    annotation.widgetStringValue = formatDateToMMDDYY(item.originDate)
                }
                if annotation.fieldName == "IsolationPoints" {
                    annotation.widgetStringValue = item.isolatoinPoints
                }
                if annotation.fieldName == "Notes" {
                    annotation.widgetStringValue = item.notes
                }
                if annotation.fieldName == "ID_1" {
                    annotation.widgetStringValue = item.sourceInfo[0].source_id
                }
            }
        }
    }
    
    return document
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    let description: String
    let item: LOTO
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        if let filledDocument = fillPDFFields(url: self.url, description: self.description, item: self.item) {
            pdfView.document = filledDocument
        } else {
            pdfView.document = PDFDocument(url: self.url)
        }
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
    }
}

func formatDateToMMDDYY(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy" // Define the date format
    return dateFormatter.string(from: date)
}
