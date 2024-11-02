//
//  UniversalOverlay.swift
//  AppWideOverlays
//
//  Created by Riley Brookins on 10/29/24.
//

import SwiftUI

/// Extensions
extension View {
    @ViewBuilder
    func universalOverlay<Content: View>(animation: Animation = .snappy, show: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .modifier(UniversalOverlayModifier(animation: animation, show: show, viewContent: content))
    }
}

// Root view wrapper
struct RootView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        print("INITING")
        self.content = content()
    }
    var properties = UniversalOverlayProperties()
    var body: some View {
        content
            .environment(properties)
            .onAppear {
                if let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene), properties.window == nil {
                    let window = PassThroughWindow(windowScene: windowScene)
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    // Setting up SwiftUI based rootview controller
                    let rootViewController = UIHostingController(rootView: UniversalOverlayViews().environment(properties))
                    rootViewController.view.backgroundColor = .clear
                    window.rootViewController = rootViewController
                    
                    properties.window = window
                }
            }
    }
}

// Shared Universal Overlay properties
@Observable
class UniversalOverlayProperties {
    var window: UIWindow?
    var views: [OverlayView] = []
    
    struct OverlayView: Identifiable {
        var id: String = UUID().uuidString
        var view: AnyView
    }
}


fileprivate struct UniversalOverlayModifier<ViewContent: View>: ViewModifier {
    var animation: Animation
    @Binding var show: Bool
    @ViewBuilder var viewContent: ViewContent
    // Local view properties
    @Environment(UniversalOverlayProperties.self) private var properties
    @State private var viewId: String?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: show) { oldValue, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
            .onChange(of: properties.views.count) {
                print("PROPERTIES \(properties.views.count)")
            }
    }
    
    private func addView() {
        if properties.window != nil && viewId == nil {
            viewId = UUID().uuidString
            guard let viewId else { return }
            
            withAnimation(animation) {
                properties.views.append(.init(id: viewId, view: .init(viewContent)))
            }
        }
    }
    
    private func removeView() {
        if let viewId {
            withAnimation(animation) {
                properties.views.removeAll(where: { $0.id == viewId })
            }
            
            self.viewId = nil
        }
    }
}



fileprivate struct UniversalOverlayViews: View {
    @Environment(UniversalOverlayProperties.self) private var properties
    var body: some View {
        ZStack {
            ForEach(properties.views) {
                $0.view
            }
        }
    }
}

fileprivate class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event), let rootView = rootViewController?.view
        else { return nil }
        
        if #available(iOS 18, *) {
            for subview in rootView.subviews.reversed() {
                let pointInSubView = subview.convert(point, from: rootView)
                if subview.hitTest(pointInSubView, with: event) == subview {
                    return hitView
                }
            }
        }
        
        return hitView == rootView ? nil : hitView
    }
}

#Preview {
    RootView {
        ContentView()
    }
}
