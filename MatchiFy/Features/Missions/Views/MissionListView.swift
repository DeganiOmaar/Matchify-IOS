import SwiftUI

struct MissionListView: View {
    @StateObject private var vm = MissionListViewModel()
    @StateObject private var auth = AuthManager.shared
    @State private var showAddMission = false
    @State private var selectedMission: MissionModel? = nil
    @State private var showEditMission = false
    @State private var showDeleteAlert = false
    @State private var missionToDelete: MissionModel? = nil
    
    private var isRecruiter: Bool {
        auth.role == "recruiter"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if vm.isLoading && vm.missions.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if vm.missions.isEmpty {
                    emptyStateView
                } else {
                    missionsList
                }
            }
            .navigationTitle("Missions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Only show add button for Recruiters
                if isRecruiter {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddMission = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .refreshable {
                await vm.refreshMissions()
            }
            .onAppear {
                vm.loadMissions()
            }
            .sheet(isPresented: $showAddMission) {
                MissionAddView(onMissionCreated: {
                    vm.loadMissions()
                })
            }
            .navigationDestination(isPresented: $showEditMission) {
                if let mission = selectedMission {
                    MissionEditView(mission: mission, onMissionUpdated: {
                        vm.loadMissions()
                    })
                }
            }
            .alert("Delete Mission", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    missionToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let mission = missionToDelete {
                        vm.deleteMission(mission)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this mission? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Missions List
    private var missionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(vm.missions, id: \.missionId) { mission in
                    MissionCardView(
                        mission: mission,
                        isOwner: vm.isMissionOwner(mission) && isRecruiter, // Only show actions if owner AND recruiter
                        onEdit: {
                            selectedMission = mission
                            showEditMission = true
                        },
                        onDelete: {
                            missionToDelete = mission
                            showDeleteAlert = true
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No missions yet")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Create your first mission offer to get started")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Only show button for Recruiters
            if isRecruiter {
                Button {
                    showAddMission = true
                } label: {
                    Text("Create Mission")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .cornerRadius(14)
                }
                .padding(.top, 10)
            }
        }
    }
}

// Preview removed - all data is dynamic from backend

