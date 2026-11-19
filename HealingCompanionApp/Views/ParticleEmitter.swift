import SwiftUI

struct EmitterParticle: Identifiable {
    let id = UUID()
    let content: String
    let color: Color
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let startRotation: Double
    let endRotation: Double
    let size: CGFloat
    let duration: Double
    let startScale: CGFloat
    let endScale: CGFloat
}

struct ParticleItemView: View {
    let particle: EmitterParticle
    let onDone: () -> Void

    @State private var animate = false

    var body: some View {
        Text(particle.content)
            .font(.system(size: particle.size))
            .foregroundStyle(particle.color)
            .rotationEffect(.degrees(animate ? particle.endRotation : particle.startRotation))
            .scaleEffect(animate ? particle.endScale : particle.startScale)
            .offset(
                x: animate ? particle.endX : particle.startX,
                y: animate ? particle.endY : particle.startY
            )
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: particle.duration)) {
                    animate = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + particle.duration) {
                    onDone()
                }
            }
    }
}

struct ParticleEmitter: View {
    let style: ParticleStyle

    @State private var particles: [EmitterParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    ParticleItemView(particle: p) {
                        particles.removeAll { $0.id == p.id }
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear {
                primeInitial(in: geo.size)
                startLoop(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func primeInitial(in size: CGSize) {
        guard style != .none else { return }
        let count = initialCount
        for i in 0..<count {
            let delay = Double(i) * 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                particles.append(makeParticle(in: size))
            }
        }
    }

    private func startLoop(in size: CGSize) {
        guard style != .none else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + emissionInterval) {
            particles.append(makeParticle(in: size))
            startLoop(in: size)
        }
    }

    private var initialCount: Int {
        switch style {
        case .sharpBurst: return 12
        case .softDots: return 6
        case .zzz: return 3
        case .softBubbles: return 5
        case .none: return 0
        }
    }

    private var emissionInterval: Double {
        switch style {
        case .sharpBurst: return 0.25
        case .softDots: return 0.35
        case .zzz: return 0.9
        case .softBubbles: return 0.45
        case .none: return 1
        }
    }

    private func makeParticle(in size: CGSize) -> EmitterParticle {
        let w = size.width
        let h = size.height
        switch style {
        case .softDots:
            return EmitterParticle(
                content: "·",
                color: .white.opacity(0.9),
                startX: CGFloat.random(in: -w/2...w/2),
                startY: -h/2 - 20,
                endX: CGFloat.random(in: -w/2...w/2),
                endY: h/2 + 20,
                startRotation: 0,
                endRotation: 0,
                size: CGFloat.random(in: 22...36),
                duration: Double.random(in: 2.4...3.6),
                startScale: 1.0,
                endScale: 0.8
            )
        case .zzz:
            return EmitterParticle(
                content: "z",
                color: .white.opacity(0.85),
                startX: CGFloat.random(in: -40...40),
                startY: 10,
                endX: CGFloat.random(in: -10...40),
                endY: -h/2 - 20,
                startRotation: 0,
                endRotation: Double.random(in: -20...20),
                size: CGFloat.random(in: 18...28),
                duration: Double.random(in: 2.2...3.0),
                startScale: 0.8,
                endScale: 1.4
            )
        case .sharpBurst:
            let angle = Double.random(in: 0..<360)
            let distance = CGFloat.random(in: 120...240)
            return EmitterParticle(
                content: ["✦", "✸", "✳︎", "✚"].randomElement() ?? "✦",
                color: Color(red: 1.0, green: 0.85, blue: 0.4).opacity(0.95),
                startX: 0,
                startY: 0,
                endX: CGFloat(cos(angle * .pi / 180)) * distance,
                endY: CGFloat(sin(angle * .pi / 180)) * distance,
                startRotation: 0,
                endRotation: Double.random(in: -180...180),
                size: CGFloat.random(in: 16...28),
                duration: Double.random(in: 0.6...1.0),
                startScale: 0.4,
                endScale: 1.1
            )
        case .softBubbles:
            return EmitterParticle(
                content: ["○", "◌", "◯"].randomElement() ?? "○",
                color: .white.opacity(0.85),
                startX: CGFloat.random(in: -60...60),
                startY: 40,
                endX: CGFloat.random(in: -80...80),
                endY: -h/2 + 20,
                startRotation: 0,
                endRotation: 0,
                size: CGFloat.random(in: 12...22),
                duration: Double.random(in: 2.2...3.2),
                startScale: 0.6,
                endScale: 1.2
            )
        case .none:
            return EmitterParticle(
                content: "",
                color: .clear,
                startX: 0, startY: 0, endX: 0, endY: 0,
                startRotation: 0, endRotation: 0,
                size: 0, duration: 0.1,
                startScale: 1, endScale: 1
            )
        }
    }
}
