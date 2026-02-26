//
//  MomentEntryView.swift
//  GratefulMoments
//
//  Created by Siyanie on 26.02.2026.
//

import SwiftUI
import PhotosUI
import SwiftData


struct MomentEntryView: View {
    @State private var title = ""
    @State private var note = ""
    @State private var imageData: Data?
    @State private var newImage: PhotosPickerItem?
    @State private var isShowingCancelConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(DataContainer.self) private var dataContainer
    var body: some View {
        NavigationStack {
            ScrollView {
                contentStack
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Grateful For")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel", systemImage: "xmark") {
                                        if title.isEmpty, note.isEmpty, imageData == nil {
                                            dismiss()
                                        } else {
                                            isShowingCancelConfirmation = true
                                        }
                                    }
                                    .confirmationDialog("Discard Moment", isPresented: $isShowingCancelConfirmation) {
                                        Button("Discard Moment", role: .destructive) {
                                            dismiss()
                                        }
                                    }
                                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "Checkmark") {
                        let newMoment = Moment(
                                                    title: title,
                                                    note: note,
                                                    imageData: imageData,
                                                    timestamp: .now
                                                )
                        dataContainer.context.insert(newMoment)
                                               do {
                                                   try dataContainer.context.save()
                                                   dismiss()
                                               } catch {
                                                   // Don't dismiss
                                               }
                            
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private var photoPicker: some View {
            PhotosPicker(selection: $newImage) {
                // Внутри этой группы мы описываем внешний вид кнопки
                Group {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                    } else {
                        Image(systemName: "photo.badge.plus.fill")
                            .font(.largeTitle)
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .background(Color(white: 0.4, opacity: 0.32))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(Rectangle())
            }
            .onChange(of: newImage) { oldValue, newValue in
                guard let newValue else { return }
                Task {
                    do {
                        if let data = try await newValue.loadTransferable(type: Data.self) {
                            await MainActor.run {
                                self.imageData = data
                            }
                        }
                    } catch {
                        print("Ошибка загрузки данных: \(error)")
                    }
                }
            }
        }

    var contentStack: some View {
        VStack(alignment: .leading) {
            
            TextField(text:$title) {
                Text("Title (Required)")
            }
            .font(.title.bold())
                .padding(.top, 48)
            Divider()
            
            TextField("Log your small wins", text: $note, axis: .vertical)
                .multilineTextAlignment(.leading)
                .lineLimit(5...Int.max)
            photoPicker
        }
        .padding()
    }
}

#Preview {
    MomentEntryView()
        .environment(DataContainer())
}
