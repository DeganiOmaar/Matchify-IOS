import SwiftUI

struct PortfolioListView: View {
    @StateObject private var vm = PortfolioListViewModel()
    @State private var showAddProject = false
    @State private var selectedProject: ProjectModel? = nil
    @State private var showEditProject = false
    @State private var showProjectDetails = false
    @State private var projectToDelete: ProjectModel? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                if vm.isLoading && vm.projects.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if vm.projects.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(vm.projects, id: \.projectId) { project in
                                ProjectCardView(
                                    project: project,
                                    onEdit: {
                                        selectedProject = project
                                        showEditProject = true
                                    },
                                    onDelete: {
                                        projectToDelete = project
                                        showDeleteAlert = true
                                    },
                                    onTap: {
                                        selectedProject = project
                                        showProjectDetails = true
                                    }
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProject = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.Colors.primary)
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .onAppear {
                vm.loadProjects()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PortfolioDidUpdate"))) { _ in
                vm.loadProjects()
            }
            .navigationDestination(isPresented: $showAddProject) {
                AddEditProjectView()
            }
            .navigationDestination(isPresented: $showProjectDetails) {
                if let project = selectedProject {
                    ProjectDetailsView(project: project)
                }
            }
            .navigationDestination(isPresented: $showEditProject) {
                if let project = selectedProject {
                    AddEditProjectView(project: project)
                }
            }
            .alert("Delete Project", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let project = projectToDelete {
                        vm.deleteProject(project)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this project? This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
            
            Text("No Projects Yet")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Text("Start building your portfolio by adding your first project")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showAddProject = true
            } label: {
                Text("Add Your First Project")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
    }
}

