//
//  CustomRefreshView.swift
//  Fetch 3.0
//
//  Created by Demetrius Hollins on 2/25/25.
//


import SwiftUI
import WebKit
import Combine

struct CustomRefreshViewContent<Content: View>: View {
    @Binding var isRefreshing: Bool
    @State private var rotation: Double = 0
    @State private var showProgressView: Bool = false
    @StateObject private var scrollDelegate = ScrollViewModel()
    
    var showsIndicator: Bool
    var onRefresh: () async -> Void
    var content: () -> Content

    init(isRefreshing: Binding<Bool>, showsIndicator: Bool = false, onRefresh: @escaping () async -> Void, @ViewBuilder content: @escaping () -> Content) {
        self._isRefreshing = isRefreshing
        self.showsIndicator = showsIndicator
        self.onRefresh = onRefresh
        self.content = content
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicator) {
            VStack(spacing: 0) {
                refreshHeader
                content()  // This line ensures the content is displayed
            }
            .offset(coordinateSpace: "scroll") { offset in
                scrollDelegate.updateScrollOffset(offset)
                
                if scrollDelegate.isEligible && !isRefreshing {
                    rotation = min(180, max(0, offset / 50 * 180))
                }
                
                if scrollDelegate.isEligible && offset > 50 && !isRefreshing {
                    isRefreshing = true
                    showProgressView = true
                    rotation = 180
                    
                    Task {
                        await onRefresh()
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isRefreshing = false
                                showProgressView = false
                                rotation = 0
                            }
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "scroll")
    }
    
    private var refreshHeader: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 50)
            .overlay {
                VStack(spacing: 12) {
                    if showProgressView {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    } else {
                        Image(systemName: "arrow.down")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(rotation))
                            .animation(.linear, value: rotation)
                    }
                    
                    Text(showProgressView ? "Refreshing..." : "Pull to refresh")
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                }
            }
    }
}

class ScrollViewModel: ObservableObject {
    @Published var isEligible: Bool = false
    @Published var scrollOffset: CGFloat = 0

    func updateScrollOffset(_ offset: CGFloat) {
        scrollOffset = offset
        isEligible = scrollOffset > 0
    }
}

extension View {
    func offset(coordinateSpace: String, offset: @escaping (CGFloat) -> ()) -> some View {
        self.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: OffsetKey.self, value: proxy.frame(in: .named(coordinateSpace)).minY)
                    .onPreferenceChange(OffsetKey.self) { value in
                        offset(value)
                    }
            }
        }
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

