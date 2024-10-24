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
        let cards = [
                ImpactCardData(
                    gradient: [Color(red: 16/255, green: 185/255, blue: 129/255),
                              Color(red: 5/255, green: 150/255, blue: 105/255)],
                    color: Color.green.opacity(0.15),
                    outline: Color.green,
                    text: Color.green,
                    icon: "leaf.fill",
                    title: "CO₂ Saved",
                    detail: """
                    Your carbon savings are making a real difference:
                    • Equivalent to \(userViewModel.trips) car trip(s) avoided
                    • Equal to planting \(userViewModel.trees) trees
                    
                    Keep up the great work! Your daily choices are helping combat climate change.
                    """
                ),
                ImpactCardData(
                    gradient: [Color(red: 245/255, green: 158/255, blue: 11/255),
                              Color(red: 234/255, green: 138/255, blue: 0/255)],
                    color: Color.yellow.opacity(0.15),
                    outline: Color.yellow,
                    text: Color.yellow,
                    icon: "bolt.fill",
                    title: "Energy Saved",
                    detail: """
                    Your energy conservation efforts:
                    • Powered 1 home(s) for a day
                    • Saved \(userViewModel.energy) kWh of electricity
                    • Reduced peak grid demand
                    
                    These savings help reduce strain on power plants and promote sustainability.
                    """
                ),
                ImpactCardData(
                    gradient: [Color(red: 59/255, green: 130/255, blue: 246/255),
                              Color(red: 37/255, green: 99/255, blue: 235/255)],
                    color: Color.blue.opacity(0.15),
                    outline: Color.blue,
                    text: Color.blue,
                    icon: "drop.fill",
                    title: "Bottles Saved",
                    detail: """
                    Your bottle conservation impact:
                    • Saved \(userViewModel.bottles) glass(es) of water
                    • Equivalent to 32 full bathtubs
                    • Protected vital water resources
                    
                    Every drop counts in preserving our planet's most precious resource.
                    """
                ),
                ImpactCardData(
                    gradient: [Color(red: 139/255, green: 92/255, blue: 246/255),
                              Color(red: 124/255, green: 58/255, blue: 237/255)],
                    color: Color.purple.opacity(0.15),
                    outline: Color.purple,
                    text: Color.purple,
                    icon: "arrow.3.trianglepath",
                    title: "Waste Reduced",
                    detail: """
                    Your waste reduction achievements:
                    • Prevented 430 plastic bags from landfills
                    • Recycled 86 kg of materials
                    • Saved valuable landfill space
                    
                    Your efforts help create a cleaner, more sustainable future.
                    """
                )
            ]
        
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(zip(cards.indices, cards)), id: \.0) { index, card in
                        OpaqueCompactCardView(
                            card: card,
                            value: getValue(for: index),
                            unit: getUnit(for: index),
                            show: showCards
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedCard = index
                            }
                        }
                    }
                }
            }
            .padding()
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
            )
            .padding(.horizontal)
            
            // Full screen expanded card
            if let selected = selectedCard {
                ExpandedCardView(
                    card: cards[selected],
                    value: getValue(for: selected),
                    unit: getUnit(for: selected),
                    onClose: {
                        withAnimation(.easeInOut) {
                            selectedCard = nil
                        }
                    }
                )
                .zIndex(1)
                .transition(.move(edge: .bottom))
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full screen fill
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            showCards = true // Show cards immediately without animation
        }
        .padding(.bottom, selectedCard != nil ? 0 : 16)
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

// MARK: - Compact Card View
struct CompactCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let show: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: card.icon)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Text(value)
                        .font(.system(size: 28))
                        .tracking(-0.5)
                        .fontWeight(.heavy)
                    Text(unit)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                
                Text(card.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            .padding(.leading, -15)
        }
        .frame(height: 140)
        .opacity(show ? 1 : 0)
    }
}

struct OpaqueCompactCardView: View {
    let card: ImpactCardData
        let value: String
        let unit: String
        let show: Bool

        var body: some View {
            ZStack {
                Color(card.color)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.outline, lineWidth: 1.5))
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: card.icon)
                        .font(.title2)
                        .foregroundColor(card.text)

                    HStack {
                        Text(value)
                            .font(.system(size: 28))
                            .tracking(-0.5)
                            .fontWeight(.heavy)
                            .foregroundColor(card.text)
                        Text(unit)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(card.text)
                    }
                    .foregroundColor(.white)

                    Text(card.title)
                        .font(.subheadline)
                        .foregroundColor(card.text)
                        .opacity(0.8)
                }
                .padding(.leading, -15)
            }
            .frame(height: 140)
            .opacity(show ? 1 : 0)
        }
}

// MARK: - Expanded Card View
struct ExpandedCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let onClose: () -> Void // Close action closure

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: card.icon)
                    .font(.title)
                    .foregroundColor(.white)
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onClose) { // Close button
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 48))
                    .fontWeight(.heavy)
                Text(unit)
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            
            
            Text(card.detail)
                .font(.body)
                .foregroundColor(.white)

                .multilineTextAlignment(.leading)
                .padding(.vertical)
        
            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
        .transition(.move(edge: .bottom))
    }
}
