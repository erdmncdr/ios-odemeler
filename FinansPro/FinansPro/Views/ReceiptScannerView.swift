//
//  ReceiptScannerView.swift
//  FinansPro
//
//  Fiş/fatura tarama ekranı
//  Kamera, galeri ve PDF desteği
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ReceiptScannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = ReceiptScannerManager.shared

    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPDFPicker = false
    @State private var isProcessing = false
    @State private var parsedReceipt: ParsedReceipt?
    @State private var showingReview = false
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var isPDFMode = false
    @State private var shouldAutoScan = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 30) {
                    // Başlık
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("Fiş/Fatura Tara")
                            .font(Theme.largeTitle)
                            .fontWeight(.bold)

                        Text("Kamera veya galeriden fotoğraf seçerek fiş bilgilerinizi otomatik olarak okutun")
                            .font(Theme.callout)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)

                    Spacer()

                    // Seçilen fotoğraf önizlemesi ve tarama durumu
                    if let image = selectedImage {
                        VStack(spacing: 16) {
                            Text(isProcessing ? "Taranıyor..." : "Fotoğraf Seçildi")
                                .font(Theme.headline)
                                .foregroundColor(isProcessing ? .blue : .secondary)

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 10)
                                .padding(.horizontal)

                            if isProcessing {
                                VStack(spacing: 12) {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .tint(.blue)

                                    Text("Fiş okunuyor...")
                                        .font(Theme.callout)
                                        .foregroundColor(.secondary)

                                    Text("Türkçe karakterler tanınıyor...")
                                        .font(Theme.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                    }

                    Spacer()

                    // Butonlar
                    if selectedImage == nil {
                        VStack(spacing: 20) {
                            // Ana buton - Fotoğraf Çek
                            Button(action: {
                                HapticManager.shared.impact(style: .medium)
                                shouldAutoScan = true
                                showingCamera = true
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 48))

                                    Text("Fotoğraf Çek")
                                        .font(Theme.title3)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Theme.primaryGradient)
                                .cornerRadius(20)
                                .shadow(
                                    color: Color.blue.opacity(0.3),
                                    radius: 15,
                                    x: 0,
                                    y: 8
                                )
                            }
                            .padding(.horizontal)

                            // Alt butonlar - Dosya Yükle ve Galeriden Seç
                            HStack(spacing: 12) {
                                // Dosya Yükle butonu
                                Button(action: {
                                    HapticManager.shared.impact(style: .medium)
                                    showingPDFPicker = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "doc.fill")
                                            .font(.system(size: 28))

                                        Text("Dosya Yükle")
                                            .font(Theme.footnote)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                }

                                // Galeriden Seç butonu
                                Button(action: {
                                    HapticManager.shared.impact(style: .medium)
                                    shouldAutoScan = true
                                    showingImagePicker = true
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.fill")
                                            .font(.system(size: 28))

                                        Text("Fotoğraf Yükle")
                                            .font(Theme.footnote)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(image: $selectedImage, sourceType: .camera)
            }
            .onChange(of: selectedImage) { newImage in
                // Fotoğraf seçildiğinde otomatik tarama başlat
                if newImage != nil && shouldAutoScan && !isPDFMode {
                    shouldAutoScan = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        processImage()
                    }
                }
            }
            .sheet(isPresented: $showingPDFPicker) {
                PDFDocumentPicker(onPDFSelected: processPDF)
            }
            .sheet(isPresented: $showingReview) {
                if let receipt = parsedReceipt, let image = selectedImage {
                    ScannedReceiptReviewView(
                        parsedReceipt: receipt,
                        receiptImage: image,
                        onSave: {
                            dismiss()
                        }
                    )
                }
            }
            .alert("Hata", isPresented: $showingError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Bir hata oluştu")
            }
        }
    }

    private func processImage() {
        guard let image = selectedImage else { return }

        isProcessing = true
        HapticManager.shared.impact(style: .medium)

        scanner.recognizeText(from: image) { result in
            isProcessing = false

            switch result {
            case .success(let text):
                // Metin başarıyla tanındı, parse et
                let receipt = ReceiptParser.shared.parse(text: text)

                // Fiş kontrolü
                if !scanner.isReceiptOrInvoice(text: text) {
                    errorMessage = "Bu bir fiş veya fatura gibi görünmüyor. Yine de devam edebilirsiniz."
                    showingError = true
                }

                parsedReceipt = receipt
                HapticManager.shared.success()
                showingReview = true

            case .failure(let error):
                errorMessage = error.localizedDescription
                showingError = true
                HapticManager.shared.error()
            }
        }
    }

    private func processPDF(url: URL) {
        isProcessing = true
        isPDFMode = true
        HapticManager.shared.impact(style: .medium)

        DispatchQueue.global(qos: .userInitiated).async {
            let result = PDFReceiptProcessor.shared.extractText(from: url)

            DispatchQueue.main.async {
                isProcessing = false

                switch result {
                case .success(let text):
                    // PDF'den metin başarıyla çıkarıldı
                    let receipt = ReceiptParser.shared.parse(text: text)

                    // Thumbnail oluştur
                    if let thumbnail = PDFReceiptProcessor.shared.generateThumbnail(from: url) {
                        selectedImage = thumbnail
                    }

                    parsedReceipt = receipt
                    HapticManager.shared.success()
                    showingReview = true

                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showingError = true
                    HapticManager.shared.error()
                }
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - PDF Document Picker
struct PDFDocumentPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onPDFSelected: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: PDFDocumentPicker

        init(_ parent: PDFDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                // Security-scoped resource'a erişim başlat
                guard url.startAccessingSecurityScopedResource() else {
                    parent.dismiss()
                    return
                }

                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                parent.onPDFSelected(url)
            }
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.dismiss()
        }
    }
}

#Preview {
    ReceiptScannerView()
}
