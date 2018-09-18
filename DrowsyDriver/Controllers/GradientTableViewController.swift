//
//  GradientTableViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/17/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit

class GradientTableViewController: UITableViewController {
    
    var allCells: [UITableViewCell] {
        return []
    }
    
    // MARK: Background Gradient
    private var backgroundGradientLayer: CAGradientLayer! {
        didSet {
            let backgroundView = UIView(frame: self.tableView.bounds)
            backgroundView.layer.insertSublayer(backgroundGradientLayer, at: 0)
            tableView.backgroundView = backgroundView
        }
    }
    
    var backgroundGradient = Colors.Background.Main {
        didSet {
            setTableViewBackgroundGradient(to: backgroundGradient)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI() {
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.separatorColor = Colors.TableViewCellSelected
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Colors.DisplayText, .font: Fonts.NavigationTitle]
        let barButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        barButtonItem.setTitleTextAttributes([.font: Fonts.NavigationButton], for: .normal)
        navigationItem.backBarButtonItem = barButtonItem
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        view.backgroundColor = .clear
        setTableViewBackgroundGradient(to: Colors.Background.Main)
        
        // Set cell appearance
        for cell in allCells {
            updateCellAppearance(for: cell)
        }
    }
    
    func updateCellAppearance(for cell: UITableViewCell) {
        let selectionColorView = UIView()
        selectionColorView.backgroundColor = Colors.TableViewCellSelected
        cell.selectedBackgroundView = selectionColorView
        cell.backgroundColor = Colors.TableViewCellNormal
        cell.tintColor = .white
        for label in [cell.textLabel, cell.detailTextLabel] {
            label?.font = Fonts.TableViewCell
            label?.textColor = .white
            label?.backgroundColor = .clear
        }
        
        if cell.accessoryType == .disclosureIndicator {
            let accessoryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
            accessoryLabel.text = "›"
            accessoryLabel.textColor = .white
            accessoryLabel.textAlignment = .center
            accessoryLabel.baselineAdjustment = .alignCenters
            accessoryLabel.sizeToFit()
            accessoryLabel.font = Fonts.TableViewAccessory
            cell.accessoryView = accessoryLabel
        }
    }
    
    // Background Gradient
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setTableViewBackgroundGradient(to: backgroundGradient, frame: CGRect(origin: .zero, size: size))
    }
    
    private func setTableViewBackgroundGradient(to colors: [UIColor], frame: CGRect? = nil) {
        let newLayer = CAGradientLayer()
        newLayer.colors = colors.map { $0.cgColor }
        newLayer.locations = [0.0, 1.0]
        newLayer.frame = frame ?? tableView.bounds
        backgroundGradientLayer = newLayer
    }
    
}
