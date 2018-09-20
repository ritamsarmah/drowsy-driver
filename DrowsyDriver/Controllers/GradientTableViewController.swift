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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTableViewBackgroundGradient(to: backgroundGradient)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setTableViewBackgroundGradient(to: backgroundGradient, frame: CGRect(origin: .zero, size: size))
    }
    
    func updateUI() {
        tableView = UITableView(frame: tableView.frame, style: .grouped)
        tableView.separatorColor = Colors.TableViewCellSelected
        tableView.keyboardDismissMode = .onDrag
        
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
        if let textLabel = cell.textLabel { updateLabelAppearance(for: textLabel) }
        if let detailTextLabel = cell.detailTextLabel { updateLabelAppearance(for: detailTextLabel, isDetail: true) }
        
        if cell.accessoryType == .disclosureIndicator {
            let accessoryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 8, height: 20))
            cell.accessoryView = UIView()
            accessoryLabel.text = "›"
            accessoryLabel.textColor = .white
            accessoryLabel.textAlignment = .center
            accessoryLabel.baselineAdjustment = .alignCenters
            accessoryLabel.sizeToFit()
            accessoryLabel.font = Fonts.TableViewAccessory
            cell.accessoryView = accessoryLabel
            
            cell.addSubview(accessoryLabel)
            accessoryLabel.translatesAutoresizingMaskIntoConstraints = false
            accessoryLabel.widthAnchor.constraint(equalToConstant: 8).isActive = true
            accessoryLabel.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -14).isActive = true
            accessoryLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: -3).isActive = true
        }
    }
    
    func updateLabelAppearance(for label: UILabel, isDetail: Bool = false) {
        label.font = isDetail ? Fonts.TableViewCellDetail : Fonts.TableViewCell
        label.textColor = .white
        label.backgroundColor = .clear
    }
    
    func updateTextFieldAppearance(for textField: UITextField) {
        textField.autocapitalizationType = .words
        textField.font = Fonts.TableViewCellDetail
        textField.textColor = .white
        textField.backgroundColor = .clear
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.font = Fonts.TableViewFooter
        footer.textLabel?.textColor = .white
    }
    
    // Background Gradient
    
    private func setTableViewBackgroundGradient(to colors: [UIColor], frame: CGRect? = nil) {
        let newLayer = CAGradientLayer()
        newLayer.colors = colors.map { $0.cgColor }
        newLayer.locations = [0.0, 1.0]
        newLayer.frame = frame ?? view.frame
        newLayer.frame = newLayer.frame.applying(CGAffineTransform(scaleX: 2, y: 2))
        backgroundGradientLayer = newLayer
    }
    
}
