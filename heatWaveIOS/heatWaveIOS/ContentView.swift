// ContentView.swift
// heatWaveIOS
//
// Root view. Owns the top-level ProcessingState and wires the
// DocumentPicker → (future) processing pipeline → result display.
//
// Phase 1: UI shell only. No processing logic is connected yet.
// Phase 2+ will bind PDFExtractor / SeedingEngine / PDFGenerator here.

import SwiftUI
import PDFKit

// MARK: - ProcessingState

/// Represents every state the processing pipeline can be in.
/// Used to drive conditional UI rendering throughout the app.
enum ProcessingState: Equatable {
    /// No file selected; app is at rest.
    case idle

    /// User has picked a file; waiting to start.
    case fileSelected(url: URL)

    /// PDF text extraction is running.
    case extracting

    /// Seeding engine is computing heat/lane assignments.
    case seeding

    /// PDF generation is running.
    case generating

    /// Pipeline succeeded. `outputURL` points to the file in .documentDirectory.
    case success(outputURL: URL)

    /// A recoverable error occurred. `message` is shown in an Alert.
    case error(message: String)

    // Equatable conformance for URL-associated cases
    static func == (lhs: ProcessingState, rhs: ProcessingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.extracting, .extracting),
             (.seeding, .seeding),
             (.generating, .generating):
            return true
        case (.fileSelected(let a), .fileSelected(let b)):
            return a == b
        case (.success(let a), .success(let b)):
            return a == b
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - ContentView

struct ContentView: View {

    // The single source of truth for what stage the pipeline is in.
    @State private var state: ProcessingState = .idle

    // Controls whether the document picker sheet is presented.
    @State private var isPickerPresented: Bool = false

    // Controls whether the error alert is showing.
    @State private var isErrorAlertPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {

                Spacer()

                // App logo / title area
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.orange)

                    Text("heatWave")
                        .font(.largeTitle.bold())

                    Text("Psych Sheet → Heat Sheet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Central action area — changes based on state
                Group {
                    switch state {

                    case .idle:
                        idleView

                    case .fileSelected(let url):
                        fileSelectedView(url: url)

                    case .extracting:
                        progressView(label: "Reading PDF…")

                    case .seeding:
                        progressView(label: "Seeding heats…")

                    case .generating:
                        progressView(label: "Generating heat sheet…")

                    case .success(let outputURL):
                        successView(outputURL: outputURL)

                    case .error:
                        // Error is shown via Alert; fall back to idle-style UI
                        idleView
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            // Document picker sheet
            .sheet(isPresented: $isPickerPresented) {
                DocumentPicker(allowedTypes: ["com.adobe.pdf"]) { url in
                    state = .fileSelected(url: url)
                }
            }
            // Error alert
            .alert("Processing Error", isPresented: $isErrorAlertPresented) {
                Button("OK") { state = .idle }
            } message: {
                if case .error(let msg) = state {
                    Text(msg)
                }
            }
            // Surface the alert when state transitions to .error
            .onChange(of: state) { _, newState in
                if case .error = newState {
                    isErrorAlertPresented = true
                }
            }
        }
    }

    // MARK: - Sub-views

    private var idleView: some View {
        Button {
            isPickerPresented = true
        } label: {
            Label("Import Psych Sheet PDF", systemImage: "doc.badge.plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func fileSelectedView(url: URL) -> some View {
        VStack(spacing: 16) {
            Label(url.lastPathComponent, systemImage: "doc.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Button {
                // Phase 3 will replace this comment with:
                //   Task { await processFile(at: url) }
                // which calls PDFExtractor → RegexParser → SeedingEngine → PDFGenerator
            } label: {
                Label("Generate Heat Sheet", systemImage: "bolt.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button("Choose a Different File") {
                state = .idle
                isPickerPresented = true
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private func progressView(label: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text(label)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private func successView(outputURL: URL) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("Heat Sheet Ready")
                .font(.title2.bold())

            ShareLink(item: outputURL) {
                Label("Share / Save PDF", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button("Start Over") {
                state = .idle
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
