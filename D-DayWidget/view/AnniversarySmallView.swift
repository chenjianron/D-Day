//
//  AnniversarySmallView.swift
//  D-Day
//
//  Created by GC on 2021/11/16.
//

import SwiftUI

@available(iOS 13.0, *)
struct AnniversarySmallView: View {
    
    var title: String
    var date: Date
    
    var body: some View{
            ZStack{
                Image(uiImage: #imageLiteral(resourceName: "Anniversary-SmallComponent-Small"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                VStack {
                    Text(LocalizedStringKey(title))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                    HStack {
                        if Date().numberOfDays(to: date) == 0 {
                            Text(LocalizedStringKey("今天"))
                                .font(.system(size: 40, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        } else if Date().numberOfDays(to: date) < 0 {
                            Text(LocalizedStringKey("已过"))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                            Text(abs(Date().numberOfDays(to: date)).description)
                                .font(.system(size: 46, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            Text(LocalizedStringKey("天"))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                        } else {
                            Text(Date().numberOfDays(to: date).description)
                                .font(.system(size: 46, weight: .bold, design: .default))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            Text(LocalizedStringKey("天"))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                        }
                    }
                }
                .padding(EdgeInsets(top: 42, leading: 24, bottom: 41, trailing: 24))
//                .frame(height:78)
//                .clipped()
            }
    }
}
