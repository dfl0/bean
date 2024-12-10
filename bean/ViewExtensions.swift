//
//  ViewExtensions.swift
//  bean
//
//  Created by dorin flocos on 12/9/24.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ hide: Bool, placeholder: Bool = false) -> some View {
        if (hide) {
            if (placeholder) {
                self.hidden()
            }
        } else {
            self
        }
    }
}
