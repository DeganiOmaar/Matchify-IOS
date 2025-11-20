import SwiftUI

struct MissionAddView: View {
    @StateObject private var vm = MissionAddViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onMissionCreated: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Title
                Section(header: Text("Title")) {
                    TextField("Mission title", text: $vm.title)
                }
                
                // MARK: - Description
                Section(header: Text("Description")) {
                    TextField("Mission description", text: $vm.description, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                // MARK: - Duration
                Section(header: Text("Duration")) {
                    TextField("e.g., 6 mois", text: $vm.duration)
                }
                
                // MARK: - Budget
                Section(header: Text("Budget")) {
                    TextField("Budget in euros", text: Binding(
                        get: { vm.budget },
                        set: { newValue in
                            // Filter out non-numeric characters
                            vm.budget = newValue.filter { $0.isNumber }
                        }
                    ))
                    .keyboardType(.numberPad)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                }
                
                // MARK: - Skills
                Section(header: Text("Skills")) {
                    HStack {
                        TextField("Add a skill", text: $vm.skillInput)
                            .onSubmit {
                                vm.addSkill()
                            }
                        
                        Button {
                            vm.addSkill()
                        } label: {
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .disabled(vm.skillInput.isEmpty)
                    }
                    
                    if !vm.skills.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(vm.skills, id: \.self) { skill in
                                    HStack(spacing: 6) {
                                        Text(skill)
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                        
                                        Button {
                                            vm.removeSkill(skill)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.15))
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // MARK: - Error
                if let error = vm.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                
                // MARK: - Save Button
                Section {
                    Button {
                        vm.createMission()
                    } label: {
                        if vm.isSaving {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save Mission")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!vm.isFormValid || vm.isSaving)
                }
            }
            .navigationTitle("New Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .onChange(of: vm.saveSuccess) { oldValue, newValue in
                if newValue {
                    dismiss()
                    onMissionCreated()
                }
            }
        }
    }
}

// Preview removed - all data is dynamic from backend

