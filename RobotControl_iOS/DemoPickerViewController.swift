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
        //"可视化编程 Demo",
        //"可视化编程 Demo (加上语句块工厂)",
        //"可视化编程 Demo (加上工具箱)",
        //"可视化编程 Demo (加上编译器)",
        "可视化编程 Demo (语句工厂+工具箱+持久化)",
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
        
        //设置sdk的log等级，log保存在下面设置的工作路径中
        IFlySetting.setLogFile(LOG_LEVEL.LVL_DETAIL)
        
        //打开输出在console的log开关
        IFlySetting.showLogcat(true)
        
        //设置sdk的工作路径
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachePath = paths[0]
        IFlySetting.setLogFilePath(cachePath)
        
        //创建语音配置,appid必须要传入，仅执行一次则可
        //所有服务启动前，需要确保执行createUtility
        IFlySpeechUtility.createUtility("appid=59397a38")

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
//        case 0:
//            viewController = BlocklyViewController()
//            break
//        case 1:
//            viewController = BlockFactoryViewController()
//        case 2:
//            viewController = BlockToolboxViewController()
//        case 3:
//            viewController = BlocklyCompilerViewController()
        case 0:
            viewController = BlockSerializerViewController()
        case 1:
            viewController = RemoteControlViewController()
        case 2:
            viewController = VoiceControlViewController()
        case 3:
            viewController = RoutePlanViewController()
        default:
            viewController = UIViewController()
            break
        }
        self.navigationController?.pushViewController(viewController!, animated: true)
    }
    
}
