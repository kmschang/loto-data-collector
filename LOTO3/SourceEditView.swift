//
//  SourceEditView.swift
//  LOTO3
//
//  Created by Kyle Schang on 8/5/24.
//

import SwiftUI
import PhotosUI

struct SourceEditView: View {
    
    @Bindable var source:SourceInfo
    
    @State private var selectedPhoto:PhotosPickerItem? = nil
    @State private var photo:UIImage? = nil
    
    @State private var showCamera:Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        NavigationStack {
            Group {
                Form {
                    Picker("Source Type", selection: $source.source_type) {
                        ForEach(Source.allCases) {source in
                            HStack(spacing: 10) {
                                Label(source.sourceString, systemImage: source.sourceIconString)
                                    .foregroundStyle(source.sourceColor)
                            }
                        }
                    }
                    .pickerStyle(.inline)
                    
                    sourceTextField(fieldName: "Source ID", fieldData: $source.source_id)
                    sourceTextField(fieldName: "Device", fieldData: $source.source_device)
                    sourceTextField(fieldName: "Locatoin", fieldData: $source.source_location)
                    sourceTextField(fieldName: "Method", fieldData: $source.source_method)
                    sourceTextField(fieldName: "Check", fieldData: $source.source_check)
                    
                    Section(header: Text("Photos")) {
                        if let photo = unwrapPhotoOptional(source.source_photo) {
                            HStack {
                                Spacer()
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                Spacer()
                            }
                        }
                        
                        
                        if (source.source_photo == nil && checkCameraPermissions()) {
                            Button {
                                showCamera = true
                            } label: {
                                Label("Take photo", systemImage: "camera.fill")
                            }
                        }
                        
                        if (source.source_photo == nil ){
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Label("Add Photo for Library", systemImage: "photo")
                            }
                            .disabled(photo != nil)
                            .onChange(of: selectedPhoto) { _, newValue in
                                if let newValue {
                                    Task {
                                        if let wrappedPhoto = await wrapPhoto(newValue) {
                                            source.source_photo = wrappedPhoto
                                            photo = unwrapPhoto(wrappedPhoto)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if (source.source_photo != nil) {
                            Button(role: .destructive) {
                                photo = nil
                                source.source_photo = nil
                                selectedPhoto = nil
                            } label: {
                                Label("Remove Image", systemImage: "clear")
                                    .foregroundStyle(.red)
                            }
                        }
                        
//                        if let photoData = source.source_photo {
//                            ShareLink(item: Image(uiImage: unwrapPhoto(photoData)),
//                                      preview: SharePreview(source.source_id.isEmpty ? "\(source.source_type.sourceString) Source Photo" : "\(source.source_type.sourceString) - \(source.source_id) Source Photo", image: Image(uiImage: unwrapPhoto(photoData))))
//                        }

                        
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePickerView(sourceType: .camera) { image in
                    Task {
                        if let wrappedPhoto = await wrapPhoto(image) {
                            source.source_photo = wrappedPhoto
                            photo = unwrapPhoto(wrappedPhoto)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .navigationTitle("Edit Source")
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    SourceEditView(source: SourceInfo(source_id: "1000 PSI", source_type: .air, source_device: "Air Compressor", source_location: "Back of Garage", source_method: "Unplug and Lock", source_check: "Turn on after locking out", source_photo: Data()))
}

struct sourceTextField:View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    let fieldName:String
    @Binding var fieldData:String
    @FocusState var isFocused:Bool
    
    var body: some View {
        
        HStack {
            TextField("\(fieldName)", text: $fieldData, axis: .vertical)
                .focused($isFocused)
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

func wrapPhoto(_ image: UIImage) async -> Data? {
    return await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let data = image.pngData()
            continuation.resume(returning: data)
        }
    }
}

func wrapPhoto(_ photo: PhotosPickerItem) async -> Data? {
    if let data = try? await photo.loadTransferable(type: Data.self) {
        return data
    }
    return nil
}


func unwrapPhotoOptional(_ photoData: Data?) -> UIImage? {
    guard let data = photoData else { return nil }
    return UIImage(data: data)
}

func unwrapPhoto(_ photoData: Data?) -> UIImage {
    guard let data = photoData, let image = UIImage(data: data) else {
        return UIImage(systemName: "photo") ?? UIImage() // Return a default image if unwrapping fails
    }
    return image
}



extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


struct ImagePickerView: UIViewControllerRepresentable {
    
    private var sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }
    
    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController,
                                          didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
}

func checkCameraPermissions() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
        return true
    } else {
        return false
    }
}
