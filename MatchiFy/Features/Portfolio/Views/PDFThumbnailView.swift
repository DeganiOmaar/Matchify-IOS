import SwiftUI
import PDFKit

struct PDFThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.Colors.secondaryBackground)
            } else {
                Rectangle()
                    .fill(AppTheme.Colors.secondaryBackground)
                    .overlay(
                        Image(systemName: "doc.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    )
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdfDocument = PDFDocument(url: url),
                  let firstPage = pdfDocument.page(at: 0) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let pageRect = firstPage.bounds(for: .mediaBox)
            let scale: CGFloat = 200.0 / max(pageRect.width, pageRect.height)
            let scaledSize = CGSize(
                width: pageRect.width * scale,
                height: pageRect.height * scale
            )
            
            let renderer = UIGraphicsImageRenderer(size: scaledSize)
            let thumbnail = renderer.image { context in
                context.cgContext.translateBy(x: 0, y: scaledSize.height)
                context.cgContext.scaleBy(x: 1.0, y: -1.0)
                firstPage.draw(with: .mediaBox, to: context.cgContext)
            }
            
            DispatchQueue.main.async {
                self.thumbnail = thumbnail
                self.isLoading = false
            }
        }
    }
}

