//
//  FunctionPickerViewController.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/5/31.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class DemoPickerViewController: UIViewController {

    static let Options = [
        "可视化编程 Demo",
        "可视化编程 Demo (加上语句块工厂)",
        "可视化编程 Demo (加上工具箱)",
        "可视化编程 Demo (加上编译器)",
        "可视化编程 Demo (加上持久化)",
        "遥控器 Demo",
        "声控 Demo",
        "轨迹控制 Demo"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        tableView.makeConstraintsEqualTo(self.view)
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DemoPickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DemoPickerViewController.Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = DemoPickerViewController.Options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        switch indexPath.row {
        case 0:
            viewController = BlocklyViewController()
            break
        case 1:
            viewController = BlockFactoryViewController()
        case 2:
            viewController = BlockToolboxViewController()
        case 3:
            viewController = BlocklyCompilerViewController()
        case 4:
            viewController = BlockSerializerViewController()
        case 5:
            viewController = RemoteControlViewController()
        default:
            viewController = UIViewController()
            break
        }
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
}
