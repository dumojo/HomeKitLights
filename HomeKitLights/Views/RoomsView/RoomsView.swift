//
//  RoomsView.swift
//  HomeKitLights
//
//  Created by Kraig Spear on 1/8/20.
//  Copyright © 2020 Kraig Spear. All rights reserved.
//

import SwiftUI

/// View showing all of the rooms associated with this device / account
struct RoomsView: View {
    /// ViewModel for this View
    @ObservedObject var viewModel: RoomsViewModel

    /// Initialize with ViewModel
    /// - Parameter viewModel: ViewModel for this View
    init(viewModel: RoomsViewModel) {
        self.viewModel = viewModel
    }

    /// Initilize with a new instance of `RoomsViewModel`
    init() {
        self.init(viewModel: RoomsViewModel())
    }

    var body: some View {
        NavigationView {
            if viewModel.isMissingPermissionStateVisisble {
                MissingPermissionStateView(viewModel: viewModel)
                    .accentColor(Color("FilterLightsOn"))
            } else if viewModel.isEmptyStateVisible {
                EmptyStateView(viewModel: viewModel)
                    .accentColor(Color("FilterLightsOn"))
            }

            ScrollView {
                VStack {
                    if viewModel.isShowingSortFilter {
                        FilterSortButtons(viewModel: viewModel)
                            .padding(.top, 8)
                            .padding(.leading, 8)
                            .padding(.trailing, 8)
                    }

                    TitleView(title: "Rooms",
                              foregroundColor: .primary)
                        .padding(.bottom, 8)

                    ForEach(viewModel.rooms) {
                        RoomLightsView($0, viewModel: RoomLightsViewModel(room: $0,
                                                                          homeKitAccessible: self.viewModel.homeKitAccessible,
                                                                          roomDataAccessible: RoomAccessor.sharedAccessor,
                                                                          hapticFeedback: HapticFeedback.sharedHapticFeedback))
                            .roomStyle()
                    }

                    Spacer()
                }
            }
            .accentColor(Color("FilterLightsOn"))
            .onAppear { self.viewModel.onAppear() }
            .navigationBarTitle(Text("Lights"), displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: {
                    withAnimation {
                        self.viewModel.toggleShowingFilter()
                    }
                }, label: {
                    Image(self.viewModel.filterButtonImage)
                        .accentColor(Color("FilterLightsOn"))
            }))
        }
    }
}

struct EmptyStateView: View {
    private let viewModel: RoomsViewModel

    init(viewModel: RoomsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Text("There are no rooms with lights setup in HomeKit. Open the Home App and add at least one light to a room.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()

            Button("Open Home App") {
                self.viewModel.showHomeApp()
            }.padding()

            Spacer()
        }
    }
}

struct MissingPermissionStateView: View {
    private let viewModel: RoomsViewModel

    init(viewModel: RoomsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            Text("The app needs permission to access your HomeKit data.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()

            Button("Permissions") {
                self.viewModel.showPermissions()
            }.padding()

            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let homeKitAccess = HomeKitAccessMock()
        homeKitAccess.whenHasRooms()

        let roomData = RoomDataAccessibleMock()

        let refreshNotification = RefreshNotificationMock()
        let roomFilterMock = RoomFilterSortMock()

        let viewModel = RoomsViewModel(homeKitAccessible: homeKitAccess,
                                       roomDataAccessible: roomData,
                                       roomFilterSortable: roomFilterMock,
                                       refreshNotification: refreshNotification,
                                       urlOpener: URLOpener())

        viewModel.onAppear()

        return Group {
            RoomsView(viewModel: viewModel)
                .environment(\.colorScheme, .light)

            RoomsView(viewModel: viewModel)
                .environment(\.colorScheme, .dark)
        }
    }
}
