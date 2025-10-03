//
//  NotesView.swift
//  FinanceApp
//
//  Created by Tina  on 12.03.25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct NotesView: View {
    @State private var notes: [String] = []
    @State private var newNote: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    var userID: String? {
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Title
                Text("My Notes")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                } else {
                    // Notes List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(notes, id: \.self) { note in
                                NoteCard(note: note)
                            }
                            .onDelete(perform: deleteNote)
                        }
                        .padding(.horizontal)
                    }
                }

                // Input Field & Add Button
                HStack {
                    TextField("Enter new note...", text: $newNote)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .foregroundColor(.black)

                    Button(action: addNote) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]),
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .disabled(newNote.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
            }
            .padding()
        }
        .onAppear(perform: fetchNotes)
    }

    // Fetch notes from Firestore
    private func fetchNotes() {
        guard let userID = userID else { return }
        isLoading = true
        errorMessage = nil

        db.collection("users").document(userID).collection("notes")
            .order(by: "timestamp", descending: true)
            .getDocuments { (snapshot, error) in
                isLoading = false
                if let error = error {
                    errorMessage = "Failed to fetch notes: \(error.localizedDescription)"
                    return
                }

                if let documents = snapshot?.documents {
                    self.notes = documents.compactMap { $0["content"] as? String }
                }
            }
    }

    // Add new note to Firestore
    private func addNote() {
        guard let userID = userID, !newNote.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let noteData: [String: Any] = ["content": newNote, "timestamp": Timestamp()]
        
        db.collection("users").document(userID).collection("notes").addDocument(data: noteData) { error in
            if let error = error {
                errorMessage = "Failed to add note: \(error.localizedDescription)"
            } else {
                self.notes.insert(newNote, at: 0)
                self.newNote = "" // Clear input field
            }
        }
    }

    // Delete note from Firestore
    private func deleteNote(at offsets: IndexSet) {
        guard let userID = userID else { return }

        let notesToDelete = offsets.map { notes[$0] }
        
        db.collection("users").document(userID).collection("notes")
            .whereField("content", in: notesToDelete)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Error deleting note: \(error.localizedDescription)"
                    return
                }

                snapshot?.documents.forEach { document in
                    self.db.collection("users").document(userID).collection("notes").document(document.documentID).delete { error in
                        if let error = error {
                            errorMessage = "Error deleting note: \(error.localizedDescription)"
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.notes.remove(atOffsets: offsets)
                }
            }
    }
}

// MARK: - Note Card View
struct NoteCard: View {
    let note: String

    var body: some View {
        HStack {
            Text(note)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding()
            
            Spacer()
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .padding(.vertical, 5)
    }
}


