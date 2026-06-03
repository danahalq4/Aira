//
//  ALERT
//  AIRA
//
//  Created by Lujain Alrugabi on 10/05/2026.
//

import SwiftUI

// MARK: - Model

struct Trigger: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let displayValue: String
}

// MARK: - Screen

struct ALERT: View {
    
    // MARK: - Text Sizes (مطابقة لأسلوب Overview)
    private let riskTitleSize: CGFloat = 28
    private let dateTextSize: CGFloat = 16
    private let messageTextSize: CGFloat = 14
    
    private let sectionTitleSize: CGFloat = 16
    private let aqiNumberSize: CGFloat = 34
    private let aqiStatusSize: CGFloat = 15
    
    private let triggerNameSize: CGFloat = 15
    private let triggerValueSize: CGFloat = 13
    
    private let buttonTextSize: CGFloat = 17
    
    // MARK: - Icon Sizes
    private let backIconSize: CGFloat = 22
    private let headerIconSize: CGFloat = 28
    private let rowIconWidth: CGFloat = 22
    
    // MARK: - Layout
    private let backButtonTopPadding: CGFloat = 16
    private let verticalSpacing: CGFloat = 16
    
    // MARK: - Data
    let riskLevel = "High Risk"
    let date = "Today, May 15"
    let message = "Poor air quality and high triggers may increase your asthma symptoms."
    
    // AQI المطلوب
    let aqi = 280
    let airQuality = "Very Unhealthy"
    
    // التريغرز: إزالة Temperature، وجعل Wind Speed كقيمة km/h
    let triggers: [Trigger] = [
        Trigger(name: "Air Quality", icon: "aqi.medium", color: Color("ColorR"), displayValue: "280 (Very Unhealthy)"),
        Trigger(name: "Humidity", icon: "drop.fill", color: Color.blue, displayValue: "40%"),
        Trigger(name: "Wind Speed", icon: "wind", color: Color("ColorY"), displayValue: "45 km/h") // عدّل الرقم كما ترغب
    ]
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (مطابق لنهج Overview)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: backIconSize, weight: .medium))
                            .foregroundColor(Color("text"))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, backButtonTopPadding)
                .padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: verticalSpacing) {
                        
                        // Risk Header
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: headerIconSize))
                                .foregroundColor(Color("ColorO"))
                            
                            Text(riskLevel)
                                .font(.system(size: riskTitleSize, weight: .bold))
                                .foregroundColor(Color("ColorO"))
                            
                            Text(date)
                                .font(.system(size: dateTextSize, weight: .regular))
                                .foregroundColor(Color("small text"))
                            
                            Text(message)
                                .font(.system(size: messageTextSize))
                                .foregroundColor(Color("small text"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 4)
                        
                        // AQI Card (مطابق لأسلوب بطاقات Overview)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Air Quality (AQI)")
                                .font(.system(size: sectionTitleSize, weight: .semibold))
                                .foregroundColor(Color("text"))
                            
                            HStack(spacing: 12) {
                                Text("\(aqi)")
                                    .font(.system(size: aqiNumberSize, weight: .bold))
                                    .foregroundColor(Color("ColorR"))
                                
                                Divider()
                                    .background(Color("small text").opacity(0.2))
                                    .frame(height: 24)
                                
                                Text(airQuality)
                                    .font(.system(size: aqiStatusSize, weight: .medium))
                                    .foregroundColor(Color("ColorR"))
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("card"))
                        )
                        
                        // Triggers Card (مطابقة لطريقة TriggerRowView في Overview)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Today's Triggers")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("text"))
                            
                            ForEach(triggers) { trigger in
                                HStack(spacing: 12) {
                                    Image(systemName: trigger.icon)
                                        .foregroundColor(trigger.color)
                                        .frame(width: rowIconWidth, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(trigger.name)
                                            .font(.system(size: triggerNameSize))
                                            .foregroundColor(Color("text"))
                                        
                                        Text(trigger.displayValue)
                                            .font(.system(size: triggerValueSize))
                                            .foregroundColor(Color("small text"))
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("card"))
                        )
                        
                        // Recommendation Card (مطابقة للأسلوب)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommendations")
                                .font(.system(size: sectionTitleSize, weight: .semibold))
                                .foregroundColor(Color("text"))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "inhaler")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color("ColorB"))
                                    .frame(width: 32, alignment: .leading)
                                
                                Text("Use your inhaler as prescribed")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color("text"))
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("card"))
                        )
                        
                        Button(action: {}) {
                            HStack {
                                Text("I Understand")
                                    .font(.system(size: buttonTextSize, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color("ColorO"), Color("ColorR")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ALERT()
            .background(Color("background"))
    }
}
