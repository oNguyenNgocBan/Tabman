//
//  TabViewController.swift
//  Tabman-Example
//
//  Created by Merrick Sapsford on 04/01/2017.
//  Copyright © 2018 UI At Six. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class TabViewController: TabmanViewController, PageboyViewControllerDataSource {

    // MARK: Outlets

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var offsetLabel: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var settingsButton: CircularButton!
    @IBOutlet weak var gradientView: GradientView!

    // MARK: Properties

    var previousBarButton: UIBarButtonItem?
    var nextBarButton: UIBarButtonItem?

    private var viewControllers = [UIViewController]()

    let colors = [UIColor.green, UIColor.cyan, UIColor.red, UIColor.blue, UIColor.purple]

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addBarButtons()
        setUpGradientView()

        dataSource = self

        // bar customisation
        bar.location = .top
        //        bar.style = .custom(type: CustomTabmanBar.self) // uncomment to use CustomTabmanBar as style.
        bar.style = .scrollingButtonBar
        //bar.appearance = PresetAppearanceConfigs.forStyle(self.bar.style, currentAppearance: self.bar.appearance)

        bar.appearance = TabmanBar.Appearance({ appearance in
            appearance.indicator.bounces = false
            appearance.indicator.compresses = false
            appearance.style.background = .solid(color: UIColor.white)

            appearance.state.color = UIColor.lightGray
            appearance.state.selectedColor = self.colors.first ?? UIColor.white
            appearance.indicator.color = UIColor.lightGray

            appearance.layout.itemVerticalPadding = 0
            appearance.indicator.bounces = true
            appearance.indicator.lineWeight = .normal
            appearance.layout.edgeInset = 0
            appearance.layout.interItemSpacing = 0
            appearance.style.showEdgeFade = true

            appearance.text.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)

            appearance.layout.height = TabmanBar.Height.explicit(value: 70)
        })

        // updating
        //updateAppearance(pagePosition: currentPosition?.x ?? 0.0)
        updateStatusLabels()
        updateBarButtonStates(index: currentIndex ?? 0)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        segue.destination.transitioningDelegate = self

        if let navigationController = segue.destination as? SettingsNavigationController,
            let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            settingsViewController.tabViewController = self
        }

        // use current gradient as tint
        if let navigationController = segue.destination as? UINavigationController,
            let navigationBar = navigationController.navigationBar as? TransparentNavigationBar {
            let gradient = self.gradients[self.currentIndex ?? 0]
            navigationBar.tintColor = gradient.midColor
        }
    }

    // MARK: Actions

    @objc func firstPage(_ sender: UIBarButtonItem) {
        scrollToPage(.first, animated: true)
    }

    @objc func lastPage(_ sender: UIBarButtonItem) {
        scrollToPage(.last, animated: true)
    }

    // MARK: PageboyViewControllerDataSource

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        var count = 0
        switch bar.style {
        case .blockTabBar, .buttonBar:
            count = 3
        default:
            count = 5
        }

        initializeViewControllers(count: count)
        return count
    }

    private func initializeViewControllers(count: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()

        for index in 0 ..< count {
            let viewController = storyboard.instantiateViewController(withIdentifier: "ChildViewController") as! ChildViewController
            viewController.index = index + 1
            barItems.append(Item(title: "Page No. \(index + 1)", image: #imageLiteral(resourceName: "image"), context: colors[index]))
            viewControllers.append(viewController)
        }

        bar.items = barItems
        self.viewControllers = viewControllers
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

    // MARK: PageboyViewControllerDelegate

    private var targetIndex: Int?

    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        willScrollToPageAt index: Int,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    willScrollToPageAt: index,
                                    direction: direction,
                                    animated: animated)

        targetIndex = index
    }

    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        didScrollTo position: CGPoint,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    didScrollTo: position,
                                    direction: direction,
                                    animated: animated)

        // updateAppearance(pagePosition: position.x)
        updateStatusLabels()
    }

    override func pageboyViewController(_ pageboyViewController: PageboyViewController,
                                        didScrollToPageAt index: Int,
                                        direction: PageboyViewController.NavigationDirection,
                                        animated: Bool) {
        super.pageboyViewController(pageboyViewController,
                                    didScrollToPageAt: index,
                                    direction: direction,
                                    animated: animated)

        // updateAppearance(pagePosition: CGFloat(index))
        updateStatusLabels()
        updateBarButtonStates(index: index)

        targetIndex = nil
    }
}
