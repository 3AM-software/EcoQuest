import SwiftUI
import SVGKit

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 220/255, blue: 130/255),  // Light green
                        Color(red: 59/255, green: 131/255, blue: 245/255)   // Light blue
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                VStack (spacing: 0) {
                    HStack {
                        Text("EcoQuest")
                            .font(.system(size: 28))
                            .padding(.top, 10.0)
                            .tracking(-0.5)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Spacer()
                        Image("Shield")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding([.top, .trailing], 11.0)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    Text("Welcome back, Eco Warrior!")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 28.0)
                    Text("Level 7 | 1250 pts")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .padding()
            }
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView()
}
