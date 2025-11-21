import SwiftUI

struct SignaturePadView: View {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentDrawing = DrawingPath()
    @State private var paths: [DrawingPath] = []
    
    private var signatureColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(white: 0.1) : .white
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Canvas { context, size in
                    for path in paths {
                        var pathToDraw = Path()
                        pathToDraw.move(to: path.points[0])
                        for point in path.points.dropFirst() {
                            pathToDraw.addLine(to: point)
                        }
                        context.stroke(pathToDraw, with: .color(signatureColor), lineWidth: 2)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(backgroundColor)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentDrawing.points.append(value.location)
                        }
                        .onEnded { _ in
                            paths.append(currentDrawing)
                            currentDrawing = DrawingPath()
                        }
                )
                
                HStack {
                    Button("Effacer") {
                        paths.removeAll()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Terminer") {
                        image = captureSignature()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationTitle("Signature")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func captureSignature() -> UIImage? {
        let size = CGSize(width: 400, height: 200)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Set background to transparent
        context.clear(CGRect(origin: .zero, size: size))
        
        // Set stroke color based on color scheme
        let strokeColor = colorScheme == .dark ? UIColor.white : UIColor.black
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(2)
        
        for path in paths {
            guard !path.points.isEmpty else { continue }
            context.move(to: path.points[0])
            for point in path.points.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

struct DrawingPath {
    var points: [CGPoint] = []
}

