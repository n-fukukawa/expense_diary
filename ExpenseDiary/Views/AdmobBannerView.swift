//
//  AdmobBannerView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct AdmobBannerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: kGADAdSizeBanner)
        let viewController = UIViewController()
//        #if DEBUG
//        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        #else
        view.adUnitID = "ca-app-pub-8749873771528689/2888646003"
//        #endif
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: kGADAdSizeBanner.size)
        view.load(GADRequest())
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AdmobBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdmobBannerView()
    }
}
