import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            Tab("Home", systemImage: "house.fill") {
                HomeContentView()
            }
            
            Tab("Events", systemImage: "list.bullet.clipboard") {
                EventsTabView()
            }
            
            Tab("Messages", systemImage: "bubble.left.and.bubble.right.fill") {
                MessagesTabView()
            }
            
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsTabView()
            }
        }
    }
}
struct HomeContentView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    HStack(spacing: 12) {
                        NavigationLink(destination: AccountView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(.primary)
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)

                            TextField("Find a team, league, player", text: .constant(""))
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                        Button(action: {}) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Label("Games", systemImage: "sportscourt.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GameFieldButtonStyle())

                        Button(action: {}) {
                            Label("Teams", systemImage: "person.3.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GameFieldButtonStyle())
                    }

                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.blue.opacity(0.65),
                                        Color.black.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 210)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("GAME CHANGER")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.8))

                            Text("PLAY.\nCOMPETE.\nCHANGE THE GAME.")
                                .font(.system(size: 30, weight: .black))
                                .foregroundStyle(.white)

                            Button(action: {}) {
                                Text("Explore Games")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(22)
                    }
                    
                    

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Quick Access")
                                .font(.title3.bold())

                            Spacer()
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 12
                        ) {
                            QuickButton(
                                title: "Live Games",
                                icon: "dot.radiowaves.left.and.right"
                            )

                            QuickButton(
                                title: "Schedule",
                                icon: "calendar"
                            )

                            QuickButton(
                                title: "Standings",
                                icon: "list.number"
                            )

                            QuickButton(
                                title: "Highlights",
                                icon: "play.rectangle.fill"
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Featured Game")
                                .font(.title3.bold())

                            Spacer()

                            Button("See All") {
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.blue)
                        }

                        GameCard(
                            homeTeam: "TIGERS",
                            awayTeam: "WILDCATS",
                            date: "FRIDAY • 7:00 PM",
                            location: "Main Stadium"
                        )

                        GameCard(
                            homeTeam: "EAGLES",
                            awayTeam: "HAWKS",
                            date: "SATURDAY • 6:30 PM",
                            location: "Field 2"
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Game Field")
                            .font(.title3.bold())

                        HStack(spacing: 12) {
                            StatBox(
                                number: "12",
                                title: "Games"
                            )

                            StatBox(
                                number: "8",
                                title: "Teams"
                            )

                            StatBox(
                                number: "24",
                                title: "Players"
                            )
                        }
                    }

                    VStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create a Game")
                                    .fontWeight(.bold)

                                Spacer()

                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Join a Team")
                                    .fontWeight(.bold)

                                Spacer()

                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding()
            }
        }
    }
}


struct GameFieldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(.white)
            .padding(.vertical, 13)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct QuickButton: View {
    let title: String
    let icon: String

    var body: some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 95, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}


struct GameCard: View {
    let homeTeam: String
    let awayTeam: String
    let date: String
    let location: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(date)
                        .font(.caption.bold())
                        .foregroundStyle(.blue)

                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "football.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }

            HStack {
                VStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 55, height: 55)
                        .overlay {
                            Text(String(homeTeam.prefix(1)))
                                .font(.title2.bold())
                                .foregroundStyle(.blue)
                        }

                    Text(homeTeam)
                        .font(.caption.bold())
                }

                Spacer()

                Text("VS")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 6) {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 55, height: 55)
                        .overlay {
                            Text(String(awayTeam.prefix(1)))
                                .font(.title2.bold())
                                .foregroundStyle(.gray)
                        }

                    Text(awayTeam)
                        .font(.caption.bold())
                }
            }

            Button(action: {}) {
                Text("View Game")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct StatBox: View {
    let number: String
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Text(number)
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(.blue)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
}
