import SwiftUI

struct RadarChartView: View {
    let data: RadarData
    @State private var animationProgress: CGFloat = 0
    
    private let axes = [
        ("Skills Match", "skillsMatch"),
        ("Experience Fit", "experienceFit"),
        ("Project Relevance", "projectRelevance"),
        ("Mission Requirements", "missionRequirementsFit"),
        ("Soft Skills Fit", "softSkillsFit")
    ]
    
    private var maxValue: CGFloat {
        100
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40
            let points = getDataPoints(center: center, radius: radius)
            
            ZStack {
                // Background grid circles
                ForEach(0..<5) { index in
                    let circleRadius = radius * CGFloat(index + 1) / 5
                    Circle()
                        .stroke(
                            AppTheme.Colors.border.opacity(0.3),
                            lineWidth: 1
                        )
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(center)
                }
                
                // Axes lines
                ForEach(0..<5) { index in
                    let angle = Double(index) * 2 * .pi / 5 - .pi / 2
                    let endX = center.x + radius * cos(angle)
                    let endY = center.y + radius * sin(angle)
                    
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(
                        AppTheme.Colors.border.opacity(0.3),
                        lineWidth: 1
                    )
                }
                
                // Data polygon
                Path { path in
                    path.move(to: points[0])
                    for i in 1..<points.count {
                        path.addLine(to: points[i])
                    }
                    path.closeSubpath()
                }
                .fill(AppTheme.Colors.primary.opacity(0.3))
                .overlay(
                    Path { path in
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            path.addLine(to: points[i])
                        }
                        path.closeSubpath()
                    }
                    .stroke(AppTheme.Colors.primary, lineWidth: 2)
                )
                
                // Data points
                ForEach(0..<5) { index in
                    Circle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: 8, height: 8)
                        .position(points[index])
                }
                
                // Axis labels
                ForEach(0..<5) { index in
                    let angle = Double(index) * 2 * .pi / 5 - .pi / 2
                    let labelRadius = radius + 25
                    let labelX = center.x + labelRadius * cos(angle)
                    let labelY = center.y + labelRadius * sin(angle)
                    
                    Text(axes[index].0)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .position(x: labelX, y: labelY)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func getDataPoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        // Use new category names, fallback to legacy names for backward compatibility
        let values = [
            CGFloat(data.skillsMatch),
            CGFloat(data.experienceFit),
            CGFloat(data.projectRelevance),
            CGFloat(data.missionRequirementsFit),
            CGFloat(data.softSkillsFit)
        ]
        
        return (0..<5).map { index in
            let angle = Double(index) * 2 * .pi / 5 - .pi / 2
            let value = values[index] * animationProgress
            let normalizedRadius = radius * (value / maxValue)
            let x = center.x + normalizedRadius * cos(angle)
            let y = center.y + normalizedRadius * sin(angle)
            return CGPoint(x: x, y: y)
        }
    }
}

#Preview {
    RadarChartView(
        data: RadarData(
            skillsMatch: 85,
            experienceFit: 75,
            projectRelevance: 80,
            missionRequirementsFit: 82,
            softSkillsFit: 78
        )
    )
    .frame(width: 300, height: 300)
    .padding()
}

