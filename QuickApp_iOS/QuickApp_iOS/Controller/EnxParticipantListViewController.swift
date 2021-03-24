//
//  EnxParticipantListViewController.swift
//  QuickApp_iOS
//
//  Created by VCX-LP-11 on 23/03/21.
//  Copyright © 2021 Daljeet Singh. All rights reserved.
//

import UIKit

protocol inviteTapEvent {
    func inviteUser(roomID: String, clientId : String)
}

class EnxParticipantListViewController: UIViewController {
    @IBOutlet weak var perticipantList: UITableView!
    var participantInRoom : [EnxParticipantModel] = []
    var delegate : inviteTapEvent!
    var roomID : String!
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
    @objc func clickToSelect(_ sender : UIButton){
        if(!sender.isSelected){
            let participantList = participantInRoom[sender.tag - 1];
            delegate.inviteUser(roomID: roomID, clientId: participantList.clientId)
        }
        sender.isSelected = !sender.isSelected
    }
}
extension EnxParticipantListViewController  : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = self.perticipantList.dequeueReusableCell(withIdentifier: "participantList", for: indexPath) as! EnxParticioantListCell
        
        let participantList = participantInRoom[indexPath.row];
        cell.nameOfParticipant.text = participantList.name
        cell.inviteButton.isUserInteractionEnabled = !participantList.hasJoin
        cell.inviteButton.isEnabled = !participantList.hasJoin
        cell.inviteButton.tag = indexPath.row + 1
        cell.inviteButton.addTarget(self, action: #selector(self.clickToSelect(_ :)), for: .touchDown)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
}
