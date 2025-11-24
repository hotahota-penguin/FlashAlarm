import SwiftUI

struct FlashAnzanView: View {
    let settings: FlashAnzanSettings
    let soundName: String
    let maxAttempts: Int
    var onComplete: (Bool) -> Void
    
    @State private var currentNumber: Int? = nil
    @State private var numbers: [Int] = []
    @State private var currentIndex = 0
    @State private var userAnswer = ""
    @State private var gameState: GameState = .ready
    @State private var attemptCount = 0
    @State private var audioManager = AudioManager()
    
    enum GameState {
        case ready
        case playing
        case input
        case success
        case failure
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Show attempts remaining
            if gameState == .input || gameState == .failure {
                Text("残り試行回数: \(max(0, maxAttempts - attemptCount))")
                    .font(.headline)
                    .foregroundColor(attemptCount >= maxAttempts ? .red : .secondary)
                    .padding(.bottom)
            }
            
            if gameState == .ready {
                Text("Ready?")
                    .font(.largeTitle)
                    .onAppear {
                        startGame()
                    }
            } else if gameState == .playing {
                if let number = currentNumber {
                    Text("\(number)")
                        .font(.system(size: 100, weight: .bold, design: .monospaced))
                        .transition(.opacity)
                        .id("number-\(currentIndex)")
                }
            } else if gameState == .input {
                VStack(spacing: 20) {
                    Text("答えは？")
                        .font(.title)
                    
                    Text(userAnswer.isEmpty ? " " : userAnswer)
                        .font(.largeTitle)
                        .frame(minWidth: 100, minHeight: 50)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                        ForEach(1...9, id: \.self) { num in
                            NumberButton(number: num) {
                                userAnswer += "\(num)"
                            }
                        }
                        NumberButton(number: 0) {
                            userAnswer += "0"
                        }
                        .gridCellColumns(2)
                        
                        Button(action: {
                            if !userAnswer.isEmpty {
                                userAnswer.removeLast()
                            }
                        }) {
                            Image(systemName: "delete.left")
                                .font(.title)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Button("決定") {
                        checkAnswer()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            } else if gameState == .success {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    Text("正解！")
                        .font(.largeTitle)
                }
                .onAppear {
                    audioManager.stopAlarmSound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onComplete(true)
                    }
                }
            } else if gameState == .failure {
                VStack(spacing: 20) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    Text("不正解...")
                        .font(.largeTitle)
                    
                    if attemptCount >= maxAttempts {
                        Text("試行回数の上限に達しました")
                            .font(.headline)
                            .foregroundColor(.red)
                        Button("アラームを止める") {
                            audioManager.stopAlarmSound()
                            onComplete(false)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    } else {
                        Text("もう一度挑戦してください")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("再挑戦") {
                            startGame()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            audioManager.playAlarmSound(soundName)
        }
        .onDisappear {
            audioManager.stopAlarmSound()
        }
    }
    
    private func startGame() {
        numbers = (0..<settings.numberCount).map { _ in
            Int.random(in: Int(pow(10.0, Double(settings.digitCount - 1)))..<Int(pow(10.0, Double(settings.digitCount))))
        }
        
        currentIndex = 0
        userAnswer = ""
        gameState = .playing
        showNextNumber()
    }
    
    private func showNextNumber() {
        guard currentIndex < numbers.count else {
            gameState = .input
            return
        }
        
        currentNumber = numbers[currentIndex]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + settings.speed) {
            currentNumber = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentIndex += 1
                showNextNumber()
            }
        }
    }
    
    private func checkAnswer() {
        let sum = numbers.reduce(0, +)
        attemptCount += 1
        
        if let input = Int(userAnswer), input == sum {
            gameState = .success
        } else {
            gameState = .failure
        }
    }
}

struct NumberButton: View {
    let number: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

#Preview {
    FlashAnzanView(settings: FlashAnzanSettings(digitCount: 1, numberCount: 3, speed: 1.0), soundName: "default", maxAttempts: 3) { _ in }
}
