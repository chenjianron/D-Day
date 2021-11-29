//
//  EmptyHiniView.swift
//  D-Day
//
//  Created by GC on 2021/11/17.
//

import SwiftUI

@available(iOS 14.0, *)
struct EmptyHintView: View {
    
    @Environment(\.widgetFamily) var family
    
    var body: some View{
        
        let textSize: CGFloat = family == .systemSmall ? 15 : 20
        
        ZStack {
            Image(uiImage: #imageLiteral(resourceName: "Anniversary-SmallComponent-Large"))
                .resizable()
                .aspectRatio(contentMode: .fill)
            Text(LocalizedStringKey("未设置内容，请前往应用内添加吧"))
                .padding(6)
                .foregroundColor(.white)
                .font(.custom("PingFangSC-Medium", size: textSize))
        }
    }
    
}
