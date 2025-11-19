import SwiftUI

struct SkillPickerView: View {
    @Binding var selectedSkills: [SkillModel]
    @State private var searchText: String = ""
    @State private var suggestions: [SkillModel] = []
    @State private var isLoading: Bool = false
    @State private var showSuggestions: Bool = false
    
    private let maxSkills: Int = 10
    private let suggestionService = SkillSuggestionService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Search field
            HStack {
                TextField("Search skills...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchText) { _, newValue in
                        if !newValue.isEmpty {
                            searchSkills(query: newValue)
                        } else {
                            suggestions = []
                            showSuggestions = false
                        }
                    }
                    .onSubmit {
                        if !searchText.isEmpty {
                            // Try to add as custom skill if not in suggestions
                            addCustomSkill(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                // Add custom skill button
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !suggestions.contains(where: { $0.name.lowercased() == searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) &&
                   !selectedSkills.contains(where: { $0.name.lowercased() == searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
                    Button {
                        addCustomSkill(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.Colors.primary)
                            .font(.system(size: 20))
                    }
                    .disabled(selectedSkills.count >= maxSkills)
                }
            }
            
            // Suggestions dropdown
            if showSuggestions && !suggestions.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                      ForEach(suggestions.filter { skill in
                          !selectedSkills.contains { $0.name.lowercased() == skill.name.lowercased() }
                      }, id: \.uniqueId) { skill in
                            Button {
                                addSkill(skill)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(skill.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Text(skill.isEsco ? "ESCO" : "User Created")
                                            .font(.system(size: 12))
                                            .foregroundColor(skill.isEsco ? AppTheme.Colors.primary : AppTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedSkills.count < maxSkills {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(AppTheme.Colors.primary)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(AppTheme.Colors.cardBackground)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            .disabled(selectedSkills.count >= maxSkills)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(AppTheme.Colors.cardBackground)
                .cornerRadius(12)
                .shadow(color: AppTheme.Colors.cardShadow, radius: 4, x: 0, y: 2)
            }
            
            // Selected skills chips
            if !selectedSkills.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(selectedSkills, id: \.uniqueId) { skill in
                        HStack(spacing: 6) {
                            Text(skill.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.primary)
                            
                            Button {
                                removeSkill(skill)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
            
            // Max skills indicator
            if selectedSkills.count >= maxSkills {
                Text("Maximum \(maxSkills) skills allowed")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func searchSkills(query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            suggestions = []
            showSuggestions = false
            return
        }
        
        isLoading = true
        showSuggestions = true
        
        Task {
            do {
                let skills = try await suggestionService.searchSkills(query: query)
                await MainActor.run {
                    suggestions = skills
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("❌ Error fetching skills: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addSkill(_ skill: SkillModel) {
        guard selectedSkills.count < maxSkills else { return }
        guard !selectedSkills.contains(where: { $0.name.lowercased() == skill.name.lowercased() }) else { return }
        
        selectedSkills.append(skill)
        searchText = ""
        showSuggestions = false
    }
    
    private func removeSkill(_ skill: SkillModel) {
        selectedSkills.removeAll { $0.name.lowercased() == skill.name.lowercased() }
    }
    
    private func addCustomSkill(_ skillName: String) {
        guard selectedSkills.count < maxSkills else { return }
        let trimmed = skillName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !selectedSkills.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }
        
        // Create a custom skill model with a unique temporary ID
        // The backend will assign a real ID when the skill is created
        // Using UUID ensures each skill instance has a unique identifier for SwiftUI ForEach
        let tempId = UUID().uuidString
        let customSkill = SkillModel(
            id: tempId,
            _id: nil,
            name: trimmed,
            source: "USER",
            createdBy: nil,
            createdAt: nil,
            updatedAt: nil
        )
        selectedSkills.append(customSkill)
        searchText = ""
        showSuggestions = false
    }
}

