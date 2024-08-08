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
                    PDFKitView(url: url, description: item.formName)
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

func fillPDFFields(url: URL, description: String) -> PDFDocument? {
    guard let document = PDFDocument(url: url) else { return nil }
    
    for i in 0..<document.pageCount {
        if let page = document.page(at: i) {
            for annotation in page.annotations {
                if annotation.fieldName == "Description" {
                    annotation.widgetStringValue = description
                }
                if annotation.fieldName == "ProcedureNumber" {
                    annotation.widgetStringValue = description
                }
            }
        }
    }
    
    return document
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    let description: String
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        if let filledDocument = fillPDFFields(url: self.url, description: self.description) {
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
