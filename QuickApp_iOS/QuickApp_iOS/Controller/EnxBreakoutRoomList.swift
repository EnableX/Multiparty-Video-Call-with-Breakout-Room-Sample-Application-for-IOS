//
//  EnxBreakoutRoomList.swift
//  QuickApp_iOS
//
//  Created by VCX-LP-11 on 23/03/21.
//  Copyright © 2021 Daljeet Singh. All rights reserved.
//

import UIKit
//Call Back Events
protocol breakOutRoomTapEvent {
    func getSelectedRoomId(roomID: String, actionType : String)
}


class EnxBreakoutRoomList: UIViewController {
    @IBOutlet weak var breakOutList: UITableView!
    var breakOutRoomList = [String]()
    var actionType : String!
    var delegate : breakOutRoomTapEvent!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension EnxBreakoutRoomList  : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breakOutRoomList.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = self.breakOutList.dequeueReusableCell(withIdentifier: "BreakOutCell", for: indexPath) as! EnxBreakOutRoomListCell
        cell.breakOutRoomIds.text = breakOutRoomList[indexPath.row];
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.getSelectedRoomId(roomID: breakOutRoomList[indexPath.row] , actionType: actionType)
    }
    
}
