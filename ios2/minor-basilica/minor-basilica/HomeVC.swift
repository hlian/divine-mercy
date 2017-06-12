//
//  HomeVC.swift
//  minor-basilica
//
//  Created by hao on 6/12/17.
//
//

import Foundation
import UIKit

class HomeVC: UIViewController {
    var vm: HomeVM!
    override func loadView() {
        self.vm = HomeVM.make()
        self.view = vm.view
    }

    override func viewWillAppear(_ animated: Bool) {
        absorbStatusBarFrame(UIApplication.shared.statusBarFrame)
    }

    override func viewDidAppear(_ animated: Bool) {
        vm.view.flashScrollIndicators()
    }

    func absorbStatusBarFrame(_ frame: CGRect) {
        vm.view.contentInset = UIEdgeInsetsMake(frame.height, 0, 0, 0)
    }
}
