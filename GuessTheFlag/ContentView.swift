//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Jennifer W on 2/11/22.
//

import SwiftUI
import AVKit // to play audio files

struct PracticeContentView: View {
    @State private var showAlert = false
    
    func printHello() {
        print("Hello!")
    }
    
    var body: some View {
        
        // Order things accoring to the y axis - "vetical"
        VStack(alignment: .leading, spacing: 20) {
            Text("Hello, world!")
            Text("This is another text view")
            
            // Color can be "primary" which changes from black to white
            // depending on the user's system settings
            Color.primary
                .frame(width: 20, height: 20)
    
            // Order things according to the x axis - "horizontal"
            HStack(spacing: 20) {
                // Color can also be given a specific RGB input
                Color(red: 1, green: 0.8, blue: 0)
                    .frame(width: 20, height: 20)
                Text("Hello, world!")
                Text("This is inside a stack")
            }
            
            // Order things according to the z axis
            ZStack {
                // Color is a View in and of itself
                Color.red
                    .frame(minWidth: 200, maxWidth: .infinity, maxHeight: 50)
                Text("Hello, world!")
                Text("This is inside a stack")
            }
            
            // Gradients can specify color and how far the gradient should go
            // All gradients can have Stops, be used as modifiers, backgrounds, etc.
            LinearGradient(gradient: Gradient(stops: [
                Gradient.Stop(color: .red, location: 0.45),
                Gradient.Stop(color: .blue, location: 0.55),
            ]), startPoint: .top, endPoint: .bottom)
            
            // Radial gradients mose outward from the center
            RadialGradient(gradient: Gradient(
                colors: [.blue, .red]),
                center: .center, startRadius: 20, endRadius: 200)
            
            // Angular gradient (aka "Conic/Conical")
            // This gradient cycles colors around a circle and radient outward
            AngularGradient(gradient: Gradient(
                colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
            
            // Buttons don't always have to be closures.
            // Buttons can be passed a function instead.
            // Roles - preset styles that automatically such as destructive
            // ButtonStyle - such as bordered
            // Tint - customize the colors used for a bordered button
            Button("Print Hello!", action: printHello)
            
            // Image
            // Be default all images are read aloud by screen readers, so always give your images clear names to avoid confusion
            // Image("imageName") - loads the image named imageName
            // Image(decorative: "imageName") - same as above but doesn't read it out for screen readers
            // Image(systemName: "imageName") - loads the imageName that comes from iOS, uses Apple's SF Symbols icons
            Button {
                print("Edit button was tapped")
            } label: {
                // adding a label to a button, iOS will automatically determine if it should show the icon, the text, or both.
                Label("Edit", systemImage: "pencil")
            }
        }
    }
}

// End the game after set amount of games
let MAX_NUMBER_OF_GAMES = 5

// percent correct needed to win the game
let PERCENTAGE_NEEDED_TO_WIN = 80

struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer! // link variable to AvAudioPlayer
    
    @State var isAudioPlaying = true // Audio plays during onAppear
    
    @State private var sigils = [
        "Arryn",
        "Baelish",
        "Baratheon",
        "Blackwood",
        "Clegane",
        "Frey",
        "Greyjoy",
        "Lannister",
        "Martell",
        "Manderly",
        "Stark",
        "Tyrell",
        "Tully",
        "Targaryen",
        "Umber",
    ]
        // automatically randomize the array order
        .shuffled()
    
    // Randomly chooses the sigil
    // Make sure the correct answer will always be one of the top 3 elements
    @State private var correctAnswer = Int.random(in: 0...2)
    
    // Show the final alert when the game is over
    @State private var showGameOver = false

    // Player's score
    @State private var score = 0
    
    // Number of total games played
    @State private var numberOfGames = 0
    
    // Handle what happens when a sigil is pressed.
    // Update player score accordingly
    // Update number of games accordingly
    func handleFlagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
        } else {
            if score > 0 {
                score -= 1
            }
        }

        numberOfGames += 1
        
        if numberOfGames == MAX_NUMBER_OF_GAMES {
            showGameOver = true // show modal
        } else {
            chooseNewAnswer()
        }
    }
    
    // handles resetting the game, shuffles the sigils
    // picks a new correct answer
    func chooseNewAnswer() {
        sigils.shuffle()
        // Choose a new correct answer
        // Make sure the correct answer is always one of the top 3 elements
        correctAnswer = Int.random(in: 0...2)
    }
    
    func resetGame() {
        score = 0
        numberOfGames = 0
        chooseNewAnswer()
    }
    
    // Render the eggs
    // Note: Eggs are visual representation of the player's score
    struct EggView: View {
        @Binding public var score: Int

        var body: some View {
            HStack {
                ForEach(0..<score, id: \.self) { index in
                    Image("egg-red")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 30, height: 50)
                }
            }
        }
    }
    
    // The Modal code
    struct SheetView: View {
        // Not sure what this does exactly - dismisses modal, but how?
        @Environment(\.dismiss) var dismiss
        
        // Pass in the score from parent View
        @Binding public var score: Int
        
        // Animation start value
        @State var rotation: CGFloat = 0.0
        
        // Pass in the button func from parent View
        var onButtonPress: () -> Void

        var body: some View {
            // calculate if the player won or not
            let percentCorrect = score / MAX_NUMBER_OF_GAMES * 100
            let over80Percent = percentCorrect >= PERCENTAGE_NEEDED_TO_WIN
            
            ZStack {
                // background image for the modal
                Image("throne")
                    .renderingMode(.original)
                    .opacity(0.7)
                    
                VStack {
                    
                    Spacer()
                    
                    Text(over80Percent
                         ? "I drink and you know things"
                         : "SHAME SHAME SHAME"
                    )
                        .font(.title.bold())
                        .foregroundColor(Color.white)
                    
                    Text("Your score: \(score) out of \(MAX_NUMBER_OF_GAMES)")
                        .foregroundColor(Color.white)
                    
                    // Need to add group here because there are over 10 items in the View
                    Group {
                        Spacer()
                        
                        EggView(score: $score)
                        
                        Spacer()
                    }
 
                    Image(over80Percent ? "tyrion" : "nun")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 300, height: 200)
                        .overlay(
                            // give image rounded corners + stroke
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 4)
                        )
                        
                    Spacer()
                    
                    // Ask player if they want to play the game again
                    // Resets the game and dismisses the modal
                    Button(action: {
                        onButtonPress()
                        dismiss()
                    }, label: {
                        VStack {
                            Text("Play Again?")
                                .foregroundColor(Color.white)
                            Image("varys")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 200, height: 250)
                                .clipped() // allow image to be clipped
                                .rotationEffect(Angle(degrees: rotation))
                                .onAppear {
                                    // duration - time to complete the animation
                                    // Note: Can't see varys's face if animation is linear, animation goes by too fast
                                    let baseAnimation = Animation.easeInOut(duration: 1)
                                    
                                    // autoreverse - once the animation completes, reverse it?
                                    let repeated = baseAnimation.repeatForever(autoreverses: false)

                                    withAnimation(repeated) {
                                        // Animation end value
                                        rotation = 360
                                    }
                                }
                        }
                        .padding(.bottom, -75) // clip varys's image a bit - squish the height of the container
                    })
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(30)
                    
                    Spacer()
                    Spacer()
                } // End of VStack
                .padding(.horizontal, 20)
            } // End of ZStack
                .onAppear {
                    // Play shame bell on lose?
                    //audioPlayer.pause()
                    
                    // WIP - Setup Shame bell
                    // Note: Audio cannot be re-initialized
                    //let bell = Bundle.main.path(forResource: "shame-bell", ofType: "m4a")
                }
        }
    }
    
    var body: some View {
        ZStack {
            // background image for the main game
            Image("dany-background")
                .ignoresSafeArea()
            
            VStack {
                // Manually create a div otherwise the spacer will push the rest of the UI off the screen
                Spacer()
                    .frame(height: 100)
                    .padding(.top, 135)
        
                // Audio button container
                VStack  {
                    // Make it a HStack to push the button to the right
                    HStack {
                        Spacer()
                            .frame(width: 320) // Push the button to the right - can this be done responsively?
                        
                        // the actual Audio Button
                        Button(action: {
                            if isAudioPlaying {
                                self.audioPlayer.pause()
                            } else {
                                self.audioPlayer.play()
                            }
                            isAudioPlaying.toggle()
                        }) {
                            Image(systemName: isAudioPlaying ? "pause.circle" : "play.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.white)
                                .opacity(0.5)
                        }
                    } // End of HStack (Audio button)
                } // End of VStack (audio button)
                
                // Main Game container
                VStack {
                    Text("KHALEESI'S QUIZ OF THRONES")
                        .font(.system(.largeTitle, design: .serif).weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 50) // make the text wrap
                        .padding(.bottom, 10)
                        .multilineTextAlignment(.center)

                    // Player instructions & buttons container
                    VStack {
                        // Instructions container
                        VStack {
                            Text("Tap the sigil of house")
                                .font(.subheadline.weight(.heavy))
                            Text(sigils[correctAnswer])
                                // Large Title is the largest font size that iOS offers
                                .font(.largeTitle.weight(.bold))
                        }
                        
                        // Buttons container
                        HStack {
                            ForEach(0..<3) { number in
                                Button {
                                    // Flag was tapped
                                    handleFlagTapped(number)
                                } label: {
                                    Image(sigils[number].lowercased())
                                        .renderingMode(.original)
                                        .scaledToFit()
                                }
                                    .clipShape(Capsule()) // rounds the corners
                                    .shadow(radius: 5)
                            } // End ForEach (sigil container)
                        } // End HStack (sigil container)
                        .scaleEffect(0.95) // adjust for any image clipping
                        .padding(.bottom, score > 0 ? 0 : 60) // adjust for egg images
                        
                        // Show the eggs (the score)
                        EggView(score: $score)
            
                    } // End of VStack (Instruction & Sigil container)
                        // Attach modal
                        .sheet(isPresented: $showGameOver) {
                            // Show SheetView on showGameOver flag
                            SheetView(score: $score, onButtonPress: resetGame)
                        }
                } // End of VStack (Main game container)
                .padding()
                
                Spacer() // Push the main game to the top so we can see Dany's face in the background
                Spacer()
            } // End of VStack
        } // End of ZStack
        .onAppear {
            // setup Main Theme song
            let themeSong = Bundle.main.path(forResource: "theme-song", ofType: "mp3")
            
            // Initialize song to AvPlayer - DO NOT initialize again or app will crash
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: themeSong!))
            self.audioPlayer.numberOfLoops = -1 // loop forever
            self.audioPlayer.play() // begin playing music as soon as screen appears
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
