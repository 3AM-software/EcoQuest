import SwiftUI
import UIKit

struct ImpactView: View {
    @ObservedObject var userViewModel: UserViewModel
    
    let isDarkMode: Bool
    
    var co2String: String {
        String(userViewModel.co2)
    }
    
    var energyString: String {
        String(userViewModel.energy)
    }
    
    var waterString: String {
        String(userViewModel.bottles)
    }
    
    var wasteString: String {
        String(Int(ceil(userViewModel.waste)))
    }
    
    @State private var showCards = false
    @State private var selectedCard: Int? = nil
    @Namespace private var namespace

    init(userViewModel: UserViewModel, isDarkMode: Bool) {
        self.userViewModel = userViewModel
        self.isDarkMode = isDarkMode
    }
    
    // Card dat
    var body: some View {
            VStack {
                ZStack {
                    RadialGradient(
                        gradient: Gradient(
                            colors: isDarkMode ?
                                [Color(red: 1/255, green: 66/255, blue: 134/255), Color(red: 0/255, green: 48/255, blue: 97/255)] :
                                [Color(red: 98/255, green: 207/255, blue: 244/255), Color(red: 50/255, green: 147/255, blue: 227/255)]
                        ),
                        center: UnitPoint(x: 0.5, y: 0.3),
                        startRadius: isDarkMode ? 50 : 100,
                        endRadius: isDarkMode ? 300 : 300
                    )
                    .frame(height: 620)
                    .ignoresSafeArea()
                    
                    ZStack(alignment: .center) {
                        // Outer Circle
                        Circle()
                            .fill(isDarkMode ?
                                Color(red: 3/255, green: 76/255, blue: 144/255) :
                                    Color(red: 135/255, green: 206/255, blue: 250/255)
                            )
                            .frame(width: 360, height: 360)
                            .opacity(0.8)
                        // Inner Circle
                        Circle()
                            .fill(isDarkMode ?
                                Color(red: 5/255, green: 93/255, blue: 164/255) :
                                Color(red: 160/255, green: 210/255, blue: 240/255)
                            )
                            .frame(width: 310, height: 310)
                            .opacity(0.8)
                        
                        // Stars for night mode, clouds for day mode
                        if isDarkMode {
                            StarrySky()
                        } else {
                            CloudySky()
                        }
                        
                        Image("Earth")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                        AnimalAwards(isDarkMode: isDarkMode)
                    }
                    .padding(.bottom, 200)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    
    private func getValue(for index: Int) -> String {
        switch index {
        case 0: return co2String
        case 1: return energyString
        case 2: return waterString
        case 3: return wasteString
        default: return ""
        }
    }
    
    private func getUnit(for index: Int) -> String {
        switch index {
        case 0: return "kg"
        case 1: return "kWh"
        case 2: return ""
        case 3: return "kg"
        default: return ""
        }
    }
}

// MARK: - Supporting Types
struct ImpactCardData {
    let gradient: [Color]
    let color: Color
    let outline: Color
    let text: Color
    let icon: String
    let title: String
    let detail: String
}

struct CompactImpactBarView: View {
    let userViewModel: UserViewModel
    let isDarkMode: Bool
    @State private var showCards = true

    var body: some View {
        let cards = [
            ImpactCardData(
                gradient: [Color(red: 16/255, green: 185/255, blue: 129/255), Color(red: 5/255, green: 150/255, blue: 105/255)],
                color: Color.green.opacity(0.15),
                outline: Color.green,
                text: Color.green,
                icon: "leaf.fill",
                title: "CO2 Saved",
                detail: """
                Your carbon savings are making a real difference:
                • Equivalent to \(userViewModel.trips) car trip(s) avoided
                • Equal to planting \(Double(userViewModel.trips) * 0.4) trees
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 245/255, green: 158/255, blue: 11/255), Color(red: 234/255, green: 138/255, blue: 0/255)],
                color: Color.yellow.opacity(0.15),
                outline: Color.yellow,
                text: Color.yellow,
                icon: "bolt.fill",
                title: "Energy Saved",
                detail: """
                Powered \(userViewModel.energy / 30) home(s) for a day and saved \(userViewModel.energy) kWh of electricity.
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 59/255, green: 130/255, blue: 246/255), Color(red: 37/255, green: 99/255, blue: 235/255)],
                color: Color.blue.opacity(0.15),
                outline: Color.blue,
                text: Color.blue,
                icon: "drop.fill",
                title: "Bottles Saved",
                detail: """
                Saved \(userViewModel.bottles) glass(es) of water, equal to \(Float(userViewModel.bottles) / 300) bathtubs.
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 139/255, green: 92/255, blue: 246/255), Color(red: 124/255, green: 58/255, blue: 237/255)],
                color: Color.purple.opacity(0.15),
                outline: Color.purple,
                text: Color.purple,
                icon: "arrow.3.trianglepath",
                title: "Waste Saved",
                detail: """
                Prevented \(userViewModel.waste * 3) plastic bags from landfills and recycled \(userViewModel.waste) kg of materials.
                """
            )
        ]

        let values = [
            String(userViewModel.trips),
            String(userViewModel.energy),
            String(userViewModel.bottles),
            String(Int(ceil(userViewModel.waste)))
        ]
        
        let units = ["kg", "kWh", "", "kg"]
        
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(0..<cards.count, id: \.self) { index in
                CompactCompactCardView(
                    card: cards[index],
                    value: values[index],
                    unit: units[index],
                    show: showCards,
                    isDarkMode: isDarkMode
                )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y:5)
        .padding(10)
        
    }
}

struct CompactCompactCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let show: Bool
    let isDarkMode: Bool
    @State private var showDetailSheet = false
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Image(systemName: card.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(card.text)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 2) {
                    Text(value)
                        .font(.custom("Fredoka", size: 24))
                        .fontWeight(.heavy)
                        .foregroundStyle(ThemeColors.Text.primary(isDarkMode))

                    Text(" \(unit)")
                        .font(.custom("Fredoka", size: 18))
                        .fontWeight(.medium)
                        .foregroundStyle(ThemeColors.Text.primary(isDarkMode))
                        .opacity(0.8)
                }
                .padding(.horizontal)

                Text(card.title)
                    .font(.custom("Fredoka", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .opacity(0.8)
                    .padding(.leading)
            }
        }
        .padding(6)
        .frame(width: 165, height: 80)
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(14)
        .scaleEffect(isPressed ? 0.95 : 1.0) // Scale down slightly when pressed
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                .scaleEffect(isPressed ? 0.95 : 1.0) // Scale down slightly when pressed
        )
        .onTapGesture {
            showDetailSheet = true
        }
        .onLongPressGesture(minimumDuration: 0.1, pressing: { inProgress in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = inProgress
            }
        }, perform: {})
        .sheet(isPresented: $showDetailSheet) {
            ImpactDetailSheet(
                card: card,
                value: value,
                unit: unit,
                isDarkMode: isDarkMode
            )
            .presentationDetents([.height(700)])
            .presentationDragIndicator(.visible)
        }
    }
}


struct StarrySky: View {
    let numberOfStars = 50
    
    var body: some View {
        ZStack {
            ForEach(0..<numberOfStars, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...1.0))) // Random opacity
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5)) // Random size
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...400) // Match the ZStack height
                    )
            }
        }
    }
}

struct CloudySky: View {
    let cloudPositions = [
        CGPoint(x: 50, y: 80),
        CGPoint(x: 340, y: 280),
        CGPoint(x: 90, y: 340),
        CGPoint(x: 120, y: 355),
        CGPoint(x: 345, y: 50)
    ]
    
    var body: some View {
        ZStack {
            ForEach(0..<cloudPositions.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 80, height: 30)
                    .position(cloudPositions[index])
            }
        }
    }
}

struct Animal: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let unlocked: Bool
    let blurb: String
}

struct AnimalAwards: View {
    @State private var selectedAnimalIndex: Int? = nil
    @State private var showAnimalSheet = false
    let isDarkMode: Bool
    
    let positions = [
        CGPoint(x: 250, y: 70), // Polar Bear
        CGPoint(x: 100, y: 150), // Pika
        CGPoint(x: 325, y: 210), // Elephant
        CGPoint(x: 220, y: 265), // Turtle
    ]
    
    let animals = [
        Animal(title: "Polar Bear", icon: "polar_bear", unlocked: false, blurb: "As CO2 emissions heat up the planet, polar bears are left stranded on shrinking ice, struggling to hunt their favorite meal: seals! If we don't cut emissions, these Arctic giants could be in big trouble as their icy homes melt away."),
        Animal(title: "American Pika", icon: "pika", unlocked: false, blurb: "These tiny, mountain-dwelling mammals are super sensitive to temperature changes, and fossil fuel pollution is making their high-altitude homes dangerously warm. As coal and other dirty energy sources heat up their cool mountain habitats, pikas are running out of places to hide from the heat!"),
        Animal(title: "Elephant", icon: "elephant", unlocked: false, blurb: "Elephants munch through tons of plants, keeping ecosystems balanced, but piles of waste and habitat loss make it harder for them to thrive. Reducing waste helps protect the land they need to roam free and healthy!"),
        Animal(title: "Sea Turtle", icon: "turtle", unlocked: false, blurb: "Sea turtles are mistaking plastic bottles for jellyfish, their favorite snack, and it's not doing them any favors. By cutting down on single-use plastics, we can help these ocean wanderers dodge a serious health hazard.")
    ]
    
    var body: some View {
        ZStack {
            ForEach(animals.indices, id: \.self) { index in
                AnimalCardView(
                    animal: animals[index],
                    isDarkMode: isDarkMode,
                    index: index
                )
                .position(positions[index])
                .onTapGesture {
                    selectedAnimalIndex = index
                    showAnimalSheet = true
                    print("pressed")
                }
            }
        }
    }
}

// Individual card view with press animation
struct AnimalCardView: View {
    let animal: Animal
    let isDarkMode: Bool
    @State private var isPressed = false
    @State private var showAnimalSheet = false
    let index: Int
    
    let animals = [
        Animal(title: "Polar Bear", icon: "polar_bear", unlocked: true, blurb: "As CO2 emissions heat up the planet, polar bears are left stranded on shrinking ice, struggling to hunt their favorite meal: seals! If we don't cut emissions, these Arctic giants could be in big trouble as their icy homes melt away."),
        Animal(title: "American Pika", icon: "pika", unlocked: false, blurb: "These tiny, mountain-dwelling mammals are super sensitive to temperature changes, and fossil fuel pollution is making their high-altitude homes dangerously warm. As coal and other dirty energy sources heat up their cool mountain habitats, pikas are running out of places to hide from the heat!"),
        Animal(title: "Elephant", icon: "elephant", unlocked: false, blurb: "Elephants munch through tons of plants, keeping ecosystems balanced, but piles of waste and habitat loss make it harder for them to thrive. Reducing waste helps protect the land they need to roam free and healthy!"),
        Animal(title: "Sea Turtle", icon: "turtle", unlocked: false, blurb: "Sea turtles are mistaking plastic bottles for jellyfish, their favorite snack, and it's not doing them any favors. By cutting down on single-use plastics, we can help these ocean wanderers dodge a serious health hazard.")
    ]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeColors.Card.background(isDarkMode))
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
            
            if animal.unlocked {
                Image("\(animal.icon)_color")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } else {
                ZStack {
                    Image(isDarkMode ? "\(animal.icon)_dark" : "\(animal.icon)_light")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Image(systemName: "questionmark")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                        .opacity(0.5)
                }
            }
        }
        .onTapGesture {
            showAnimalSheet = true
            print("pressed")
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0.1,
            pressing: { inProgress in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = inProgress
                }
            },
            perform: {}
        )
        .sheet(isPresented: $showAnimalSheet) {
            AnimalSheetView(
                animal: animals[index],
                isDarkMode: isDarkMode
            )
            .presentationDetents([.height(400),.height(700)])
            .presentationDragIndicator(.visible)
        }
    }
}


struct AnimalSheetView: View {
    let animal: Animal
    let isDarkMode: Bool
    
    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            VStack {
                if animal.unlocked {
                    Image("\(animal.icon)_color")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Text(animal.title)
                        .padding([.bottom,.leading,.trailing])
                        .font(.custom("Fredoka", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                    Text(animal.blurb)
                        .padding([.leading,.trailing], 32)
                        .font(.custom("Fredoka", size: 18))
                        .fontWeight(.regular)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                } else {
                    Image(isDarkMode ? "\(animal.icon)_dark" : "\(animal.icon)_light")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("Unlock this animal by achieving the milestone award:")
                        .padding()
                        .font(.custom("Fredoka", size: 18))
                        .fontWeight(.regular)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                    Text(unlockRequirement(for: animal.icon))
                        .font(.custom("Fredoka", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private func unlockRequirement(for icon: String) -> String {
        switch icon {
        case "pika": return "1000 kWh Energy Saved"
        case "polar_bear": return "100 kg CO2 Saved"
        case "turtle": return "100 Bottles Saved"
        case "elephant": return "50 kg Waste Saved"
        default: return "Unknown Milestone"
        }
    }
}

struct DetailCard: View {
    let icon: String
    let value: String
    let label: String
    let isDarkMode: Bool
    let color: Color
    let maxDisplay: Int = 10
    
    private var filledCount: Int {
        min(Int(Double(value) ?? 0), maxDisplay)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with label
            HStack(spacing: 16) {
                Text(value)
                    .font(.custom("Fredoka", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                
                Text(label)
                    .font(.custom("Fredoka", size: 16))
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                
                Spacer()
                
                
            }
            
            // Grid of icons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(0..<maxDisplay, id: \.self) { index in
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(index < filledCount ? color : color.opacity(0.2))
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
        )
    }
}

struct ImpactDetailSheet: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let isDarkMode: Bool
    
    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: card.gradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: card.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 16) {
                        // Main Value and Unit
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(value)
                                .font(.custom("Fredoka", size: 36))
                                .fontWeight(.heavy)
                            Text(unit)
                                .font(.custom("Fredoka", size: 24))
                                .fontWeight(.medium)
                                .opacity(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                        
                        // Title
                        Text(card.title)
                            .font(.custom("Fredoka", size: 24))
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                        
                        // Equivalent To - Left aligned
                        Text("Equivalent To:")
                            .font(.custom("Fredoka", size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                    
                    // Impact Details with colored grids
                    ImpactDetailCards(card: card, value: value, isDarkMode: isDarkMode)
                        .padding(.horizontal, 16)
                    
                    // Description
                    Text(card.detail)
                        .font(.custom("Fredoka", size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 32)
            }
        }
    }
}

struct ImpactDetailCards: View {
    let card: ImpactCardData
    let value: String
    let isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            switch card.title {
            case "CO2 Saved":
                let trees = Int((Double(value) ?? 0) * 0.4)
                
                DetailCard(
                    icon: "car.fill",
                    value: value,
                    label: "Car Trips Avoided",
                    isDarkMode: isDarkMode,
                    color: .green
                )
                
                DetailCard(
                    icon: "tree.fill",
                    value: "\(trees)",
                    label: "Trees Planted",
                    isDarkMode: isDarkMode,
                    color: .green
                )
                
            case "Energy Saved":
                let homes = Int((Double(value) ?? 0) / 30)
                let bulbs = Int((Double(value) ?? 0) / 5)
                
                DetailCard(
                    icon: "house.fill",
                    value: "\(homes)",
                    label: "Homes Powered for 1 Day",
                    isDarkMode: isDarkMode,
                    color: .yellow
                )
                
                DetailCard(
                    icon: "lightbulb.fill",
                    value: "\(bulbs)",
                    label: "Light Bulbs Powered for 1 Month",
                    isDarkMode: isDarkMode,
                    color: .yellow
                )
                
            case "Bottles Saved":
                let glasses = Int(Double(value) ?? 0)
                let bathtubs = Int((Double(value) ?? 0) / 300)
                
                DetailCard(
                    icon: "drop.fill",
                    value: "\(glasses)",
                    label: "Glasses of Water",
                    isDarkMode: isDarkMode,
                    color: .blue
                )
                
                DetailCard(
                    icon: "shower.fill",
                    value: "\(bathtubs)",
                    label: "Bathtubs",
                    isDarkMode: isDarkMode,
                    color: .blue
                )
                
            case "Waste Saved":
                let bags = Int((Double(value) ?? 0) * 3)
                
                DetailCard(
                    icon: "bag.fill",
                    value: "\(bags)",
                    label: "Plastic Bags Avoided",
                    isDarkMode: isDarkMode,
                    color: .purple
                )
                
                DetailCard(
                    icon: "arrow.3.trianglepath",
                    value: value,
                    label: "Kilograms of Materials Recycled",
                    isDarkMode: isDarkMode,
                    color: .purple
                )
            default:
                EmptyView()
            }
        }
    }
}
