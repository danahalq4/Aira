//
//  SymptomsListView.swift
//  Aira
//

import SwiftUI

struct SymptomsListView: View {
    let symptoms: [Symptom]
    let deleteAction: (Symptom) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(symptoms) { symptom in
                SwipeDeleteRow {
                    SymptomCardView(symptom: symptom)
                } onDelete: {
                    deleteAction(symptom)
                }
            }
        }
    }
}

struct SwipeDeleteRow<Content: View>: View {

    let content: Content
    let onDelete: () -> Void

    @State private var offsetX: CGFloat = 0

    private let deleteWidth: CGFloat = 86

    init(
        @ViewBuilder content: () -> Content,
        onDelete: @escaping () -> Void
    ) {
        self.content = content()
        self.onDelete = onDelete
    }

    var body: some View {

        ZStack(alignment: .trailing) {

            Button {
                withAnimation {
                    onDelete()
                }
            } label: {

                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: deleteWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }

            content
                .offset(x: offsetX)

                .simultaneousGesture(

                    DragGesture()

                        .onChanged { value in

                            // إذا الحركة عمودية نخلي السكرول يشتغل
                            guard abs(value.translation.width)
                                    > abs(value.translation.height)
                            else {
                                return
                            }

                            if value.translation.width < 0 {

                                offsetX = max(
                                    value.translation.width,
                                    -deleteWidth
                                )
                            }
                        }

                        .onEnded { value in

                            guard abs(value.translation.width)
                                    > abs(value.translation.height)
                            else {

                                withAnimation(.spring()) {
                                    offsetX = 0
                                }

                                return
                            }

                            withAnimation(.spring()) {

                                if value.translation.width < -40 {

                                    offsetX = -deleteWidth

                                } else {

                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
    }
}

struct SymptomCardView: View {

    let symptom: Symptom

    var body: some View {

        HStack(spacing: 12) {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(symptom.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("text"))

                HStack(spacing: 8) {

                    Text(timeString(symptom.time))
                        .font(.system(size: 13))
                        .foregroundColor(Color("small text"))

                    Circle()
                        .fill(
                            Color(symptom.severity.colorAssetName)
                        )
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(

            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
            .fill(Color("card"))
        )
    }

    private func timeString(
        _ date: Date
    ) -> String {

        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: date)
    }
}
