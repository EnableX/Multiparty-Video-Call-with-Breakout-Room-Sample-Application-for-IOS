//
//  EnxConfrenceViewController.swift
//  QuickApp_iOS
//
//  Created by Daljeet Singh on 04/12/18.
//  Copyright © 2018 Daljeet Singh. All rights reserved.
//

import Foundation

import UIKit
import EnxRTCiOS
import SVProgressHUD
class EnxConfrenceViewController: UIViewController {
    @IBOutlet weak var sendLogBtn: UIButton!
     @IBOutlet weak var cameraBTN: UIButton!
    @IBOutlet weak var speakerBTN: UIButton!
    
    @IBOutlet weak var publisherNameLBL: UILabel!
    @IBOutlet weak var subscriberNameLBL: UILabel!
    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var localPlayerView: EnxPlayerView!
    @IBOutlet weak var mainPlayerView: EnxPlayerView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var optionsContainerView: UIView!
    @IBOutlet weak var optionViewButtonlayout: NSLayoutConstraint!
    @IBOutlet weak var joinBreakOutRoom: UIButton!
    @IBOutlet weak var inviteBreakoutRoom: UIButton!
    
    @IBOutlet weak var breakoutViewView: UIView!
    @IBOutlet weak var breakoutViewViewHeight: NSLayoutConstraint!
    @IBOutlet weak var invitedUserName: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var breakoutDisconnect: UIButton!
    
    @IBOutlet weak var btnAudioMute: UIButton!
    @IBOutlet weak var btnVideoMute: UIButton!
    
    var roomInfo : EnxRoomInfoModel!
    var param : [String : Any] = [:]
    var remoteRoom : EnxRoom!
    var objectJoin : EnxRtc!
    var localStream : EnxStream!
    var listOfParticipantInRoom : [EnxParticipantModel] = []
    var streamArray = [Any]()
    var breakOutRoomList = [String]()
    var breakOutpopoverViewController : EnxBreakoutRoomList!
    var participantpopoverViewController : EnxParticipantListViewController!
    var breakOutRoomInfo : [String : Any]!
    var breakOUtRoom : EnxRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beautifyBreakoutRoomUI()
        localPlayerView.layer.cornerRadius = 8.0
        localPlayerView.layer.borderWidth = 2.0
        localPlayerView.layer.borderColor = UIColor.blue.cgColor
        localPlayerView.layer.masksToBounds = true
        optionsView.layer.cornerRadius = 8.0
        // Adding Pan Gesture for localPlayerView
        let localViewGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didChangePosition))
        localPlayerView.addGestureRecognizer(localViewGestureRecognizer)
        
        objectJoin = EnxRtc()
        self.createToken()
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: - didChangePosition
    /**
     This method will change the position of localPlayerView
     Input parameter :- UIPanGestureRecognizer
     **/
    @objc func didChangePosition(sender: UIPanGestureRecognizer) {
        let location = sender.location(in: view)
        if sender.state == .began {
        } else if sender.state == .changed {
            if(location.x <= (UIScreen.main.bounds.width - (self.localPlayerView.bounds.width/2)) && location.x >= self.localPlayerView.bounds.width/2) {
                self.localPlayerView.frame.origin.x = location.x
                localPlayerView.center.x = location.x
            }
            if(location.y <= (UIScreen.main.bounds.height - (self.localPlayerView.bounds.height + 40)) && location.y >= (self.localPlayerView.bounds.height/2)+20){
                self.localPlayerView.frame.origin.y = location.y
                localPlayerView.center.y = location.y
            }
            
        } else if sender.state == .ended {
            print("Gesture ended")
        }
    }
    
    // MARK: - createTokrn
    /**
     input parameter - Nil
     Return  - Nil
     This method will initiate the Room for stream
     **/
    private func createToken(){
        guard EnxNetworkManager.isReachable() else {
            self.showAleartView(message:"Kindly check your Network Connection", andTitles: "OK",willnavigate: true)
            return
        }
        let inputParam : [String : String] = ["name" :roomInfo.participantName , "role" :  roomInfo.role ,"roomId" : roomInfo.room_id, "user_ref" : "2236"]
        SVProgressHUD.show()
        EnxServicesClass.featchToken(requestParam: inputParam, completion:{tokenModel  in
            DispatchQueue.main.async {
                //  Success Response from server
                if let token = tokenModel.token {
                    
                    let videoSize : [String : Any] =  ["minWidth" : 320 , "minHeight" : 180 , "maxWidth" : 1280, "maxHeight" :720]
                    
                    let localStreamInfo : [String : Any] = ["video" : self.param["video"]! ,"audio" : self.param["audio"]! ,"data" :self.param["chat"]! ,"name" :self.roomInfo.participantName!,"type" : "public","audio_only": false ,"maxVideoBW" : 120 ,"minVideoBW" : 80 , "videoSize" : videoSize]
                    
                    let playerConfiguration : [String : Any] = ["avatar":true,"audiomute":true, "videomute":true,"bandwidht":true, "screenshot":true,"iconColor" :"#0000FF","iconWidth":25,"iconHeight":25]
                    
                    let roomInfo : [String : Any]  = ["allow_reconnect" : true , "number_of_attempts" : 3, "timeout_interval" : 20,"playerConfiguration":playerConfiguration,"activeviews" : "view"]
                    
                    guard let stream = self.objectJoin.joinRoom(token, delegate: self, publishStreamInfo: localStreamInfo , roomInfo: roomInfo , advanceOptions: nil) else{
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    self.localStream = stream
                    self.localStream.delegate = self as EnxStreamDelegate
                }
                    //Handel if Room is full
                else if (tokenModel.token == nil && tokenModel.error == nil){
                    self.showAleartView(message:"Token Denied. Room is full.", andTitles: "OK",willnavigate: true)
                }
                    //Handeling server error
                else{
                    print(tokenModel.error)
                    self.showAleartView(message:tokenModel.error, andTitles: "OK",willnavigate: true)
                }
                SVProgressHUD.dismiss()
            }
        })
        
    }
    // MARK: - Show Alert
    /**
     Show Alert Based in requirement.
     Input parameter :- Message and Event name for Alert
     **/
    private func showAleartView(message : String, andTitles : String , willnavigate : Bool){
        let alert = UIAlertController(title: " ", message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: andTitles, style: .default) { (action:UIAlertAction) in
            if(willnavigate){
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    /*  // MARK: - View Tap Event
     /**
     Its method will hide/unhide option View
     **/
     @objc func handleSingleTap(sender : UITapGestureRecognizer){
     if optionViewButtonlayout.constant >= 0{
     UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
     self.optionViewButtonlayout.constant = -100
     }, completion: nil)
     }
     else{
     UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
     self.optionViewButtonlayout.constant = 10
     }, completion: nil)
     }
     }*/
    // MARK: - Mute/Unmute
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will Mute/Unmute sound and change Button Property.
     **/
    @IBAction func muteUnMuteEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if btnAudioMute.isSelected {
            localStream.muteSelfAudio(false)
            btnAudioMute.isSelected = false
        }
        else{
            localStream.muteSelfAudio(true)
            btnAudioMute.isSelected = true
        }
    }
    // MARK: - Camera On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Camera and change Button Property.
     **/
    @IBAction func cameraOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if btnVideoMute.isSelected {
            localStream.muteSelfVideo(false)
            btnVideoMute.isSelected = false
            cameraBTN.isEnabled = true
        }
        else{
            localStream.muteSelfVideo(true)
            btnVideoMute.isSelected = true
            cameraBTN.isEnabled = false
        }
    }
    // MARK: - Camera Angle
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will change Camera Angle and change Button Property.
     **/
    @IBAction func changeCameraAngle(_ sender: UIButton) {
        _ = localStream.switchCamera()
    }
    // MARK: - Speaker On/Off
    /**
     Input parameter : - Button Property
     OutPut : - Nil
     Its method will On/Off Speaker and change Button Property.
     **/
    @IBAction func speakerOnOffEvent(_ sender: UIButton) {
        guard remoteRoom != nil else {
            return
        }
        if sender.isSelected {
            remoteRoom.switchMediaDevice("EARPIECE")
            sender.isSelected = false
        }
        else{
            remoteRoom.switchMediaDevice("Speaker")
            sender.isSelected = true
        }
    }
    // MARK: - End Call
    /**
     Input parameter : - Any
     OutPut : - Nil
     Its method will Closed Call and exist from Room
     **/
    @IBAction func endCallEvent(_ sender: Any) {
        self.leaveRoom()
        
    }
    
    
    // MARK: - sendLogs
    /**
     Input parameter : - Any
     OutPut : - Nil
     Method to send EnxRTCiOS SDK.
     **/
    @IBAction func sendLogs(_ sender: Any) {
        remoteRoom.postClientLogs()
    }
    
    // MARK: - Leave Room
    /**
     Input parameter : - Nil
     OutPut : - Nil
     Its method will exist from Room
     **/
    private func leaveRoom(){
        UIApplication.shared.isIdleTimerDisabled = false
        remoteRoom?.disconnect()
        
    }
    // MARK: - Breakout Room
    func beautifyBreakoutRoomUI(){
        breakoutViewView.layer.cornerRadius = 12.0
        breakoutViewView.layer.borderWidth = 2.0
        breakoutViewView.layer.borderColor = UIColor.white.cgColor
    }
    func showAndHideBreakoutView(flag : Bool ,isConnected: Bool){
        if(isConnected && breakoutViewView.alpha != 0.0){
            acceptButton.isHidden = isConnected
            audioButton.isHidden = !isConnected
            audioButton.isSelected = !isConnected
            return;
        }
        UIView.animate(withDuration: 0.75, animations: { [self] in
            if(flag){
                acceptButton.isHidden = isConnected
                audioButton.isHidden = !isConnected
                audioButton.isSelected = !isConnected
                breakoutViewView.alpha = 1.0
            }
            else{
                breakoutViewView.alpha = 0.0
            }
        })
        
    }
    func featchNameofInviteUser(clientID : String){
        for model in listOfParticipantInRoom{
            if (model.clientId == clientID) {
                invitedUserName.text = "\(model.name ?? "unknow") has invited you for breakout room"
                break
            }
        }
    }
    @IBAction func acceptCall(_ sender: UIButton){
        if(breakOutRoomInfo != nil){
            acceptButton.isHidden = true;
            let joinDict : [String : String] = ["role" : "participant", "room_id" : (breakOutRoomInfo["room_id"] as! String)]
            let streamInfo : [String : Any] = ["audio" : true, "video" : false]
            remoteRoom.joinBreakOutRoom(joinDict, withStreamInfo: streamInfo)
        }
    }
    @IBAction func rejectOrDisconnectCall(_ sender: UIButton){
        if(breakOUtRoom != nil){
            breakOUtRoom.disconnect()
        }
        else{
            showAndHideBreakoutView(flag: false, isConnected: false)
        }
    }
    @IBAction func muteUnmuteBreakoutRoom(_ sender: UIButton){
        if(!audioButton.isSelected){
            if(breakOUtRoom != nil){
                breakOUtRoom.publishStream?.muteSelfVideo(true)
            }
        }
        else{
            if(breakOUtRoom != nil){
                breakOUtRoom.publishStream?.muteSelfVideo(false)
            }
        }
        audioButton.isSelected = !audioButton.isSelected
    }
    
    @IBAction func createBreakOutRoom(_ sender: Any) {
        let alertView = UIAlertController.init(title: "Create Breakout Room", message: "", preferredStyle: .alert)
        //Add text field
        alertView.addTextField { (textField) -> Void in
                textField.placeholder = "Number of Participants"
            textField.keyboardType = .numberPad
            textField.borderStyle = .roundedRect
            }
        alertView.addTextField { (textField) -> Void in
                textField.placeholder = "Number of BreakoutRooms"
            textField.keyboardType = .numberPad
            textField.borderStyle = .roundedRect
            }
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { alert -> Void in
                let firstTextField = alertView.textFields![0] as UITextField
                let secondTextField = alertView.textFields![1] as UITextField
                if(firstTextField.text != nil && secondTextField.text != nil){
                    let dict : [String : Any] = ["participants" : Int(firstTextField.text!)!  ,"audio": true,"video": false,"canvas":false,"share":false,"max_rooms":Int(secondTextField.text!)!]
                        self.remoteRoom.createBreakOutRoom(dict)
                }
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in })
        alertView.addAction(createAction)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
    @IBAction func joinBreakoutRoom(_ sender: Any) {
        self.performSegue(withIdentifier: "BreakOutPopOver", sender: "join")
    }
    @IBAction func inviteBreakoutRoom(_ sender: Any) {
        self.performSegue(withIdentifier: "BreakOutPopOver", sender: "Invite")
    }
    func joinBreakOutRoomID(roomId : String){
        invitedUserName.text = "Connecting with breakout room"
        let dict : [String : String] = ["role" : "participant", "room_id" : roomId]
        let streamInfoaudio : [String : Any] = ["audio" : true, "video" : false]
        remoteRoom.joinBreakOutRoom(dict, withStreamInfo: streamInfoaudio)
    }
    func updateUserforBreakoutRoom(isConnectd : Bool , withClientId clientId : String){
        if(isConnectd){
            for (index,model) in listOfParticipantInRoom.enumerated(){
                if(model.clientId == clientId){
                    model.hasJoin = true
                    listOfParticipantInRoom.remove(at: index)
                    listOfParticipantInRoom.insert(model, at: index)
                    break
                }
            }
        }
        else{
            for (index,model) in listOfParticipantInRoom.enumerated(){
                if(model.clientId == clientId){
                    model.hasJoin = false
                    listOfParticipantInRoom.remove(at: index)
                    listOfParticipantInRoom.insert(model, at: index)
                    break
                }
            }

        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - SegueEvent
    /**
     here getting refrence to next moving controll and passing requirade parameter
     Input parameter :- UIStoryboardSegue andAny
     Return parameter :- Nil
     **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BreakOutPopOver"){
            if(breakOutRoomList.count > 0){
                breakOutpopoverViewController = (segue.destination as! EnxBreakoutRoomList)
                breakOutpopoverViewController.delegate = self
                breakOutpopoverViewController.breakOutRoomList = breakOutRoomList
                breakOutpopoverViewController.actionType = (sender as! String)
                breakOutpopoverViewController.modalPresentationStyle = .popover
                breakOutpopoverViewController.presentationController?.delegate = self
                breakOutpopoverViewController.preferredContentSize = CGSize(width: 250, height:(breakOutRoomList.count * 65))
                if((sender as! String) == "Invite"){
                    breakOutpopoverViewController.popoverPresentationController?.sourceView = inviteBreakoutRoom
                }
                else{
                    breakOutpopoverViewController.popoverPresentationController?.sourceView = joinBreakOutRoom
                }
            }
            else{
                showAleartView(message: "No Breakout room found", andTitles: "Ok",willnavigate: false)
            }
        }
        else{
            if(listOfParticipantInRoom.count > 0){
                participantpopoverViewController = (segue.destination as! EnxParticipantListViewController)
                participantpopoverViewController.delegate = self
                participantpopoverViewController.participantInRoom = listOfParticipantInRoom
                participantpopoverViewController.roomID = (sender as! String)
                participantpopoverViewController.modalPresentationStyle = .popover
                participantpopoverViewController.presentationController?.delegate = self
                participantpopoverViewController.preferredContentSize = CGSize(width: 250, height:(listOfParticipantInRoom.count * 44))
            }
            else{
                showAleartView(message: "No participant available to invite", andTitles: "Ok",willnavigate: false)
            }
           
        }
    }
}
/*
 // MARK: - Extension
 Delegates Methods
 */
extension EnxConfrenceViewController : EnxRoomDelegate, EnxStreamDelegate {
    //Mark - EnxRoom Delegates
    /*
     This Delegate will notify to User Once he got succes full join Room
     */
    func room(_ room: EnxRoom?, didConnect roomMetadata: [String : Any]?) {
        remoteRoom = room
        remoteRoom.publish(localStream)
        remoteRoom.setTalkerCount(4)
        if remoteRoom.isRoomActiveTalker{
            if let name = remoteRoom.whoami()!["name"] {
                publisherNameLBL.text = (name as! String)
                localPlayerView.bringSubviewToFront(publisherNameLBL)
                
            }
            localStream.attachRenderer(localPlayerView)
            localPlayerView.contentMode = UIView.ContentMode.scaleAspectFill        }else{
            localStream.attachRenderer(mainPlayerView)
            mainPlayerView.contentMode = UIView.ContentMode.scaleAspectFill
        }
        if listOfParticipantInRoom.count >= 1 {
           listOfParticipantInRoom.removeAll()
        }
        let list = roomMetadata!["userList"] as! [Any]
        for index in 0..<list.count  {
        let item = list[index] as! [String : Any]
            if(item["clientId"] as! String != remoteRoom.clientId! as String){
            let partList = EnxParticipantModel()
            partList.clientId = (item["clientId"] as! String)
            partList.name = (item["name"] as! String)
            partList.role = (item["role"] as! String)
            partList.hasJoin = false
            listOfParticipantInRoom.append(partList)
        }
    }
    }
    /*
     This Delegate will notify to User Once he Getting error in joining room
     */
    func room(_ room: EnxRoom?, didError reason: [Any]?) {
        self.showAleartView(message:"Room error", andTitles: "OK",willnavigate: true)
    }

    /*
     This Delegate will notify to User Once he Getting error on performing any event.
     */
    func room(_ room: EnxRoom?, didEventError reason: [Any]?) {
        let resDict = reason![0] as! [String : Any]
        self.showAleartView(message:resDict["msg"] as! String, andTitles: "OK",willnavigate: false)
    }
    /*
     This Delegate will notify to  User Once he Publisg Stream
     */
    func room(_ room: EnxRoom?, didPublishStream stream: EnxStream?) {
        //To Do
        remoteRoom.switchMediaDevice("Speaker")
        speakerBTN.isSelected = true
    }
    /*
     This Delegate will notify to  User Once he Unpublisg Stream
     */
    func room(_ room: EnxRoom?, didUnpublishStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if any new person added to room
     */
    func room(_ room: EnxRoom?, didAddedStream stream: EnxStream?) {
        _ = room!.subscribe(stream!)
    }
    /*
     This Delegate will notify to User to subscribe other user stream
     */
    func room(_ room: EnxRoom?, didSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User to Unsubscribe other user stream
     */
    func room(_ room: EnxRoom?, didUnSubscribeStream stream: EnxStream?) {
        //To Do
    }
    /*
     This Delegate will notify to User if Room Got discunnected
     */
    func didRoomDisconnect(_ response: [Any]?) {
       self.navigationController?.popViewController(animated: true)
    }
    /*
     This Delegate will notify to User if any person join room
     */
    func room(_ room: EnxRoom?, userDidJoined Data: [Any]?) {
        let item = Data![0] as! [String : Any]
        let partList = EnxParticipantModel()
        partList.clientId = (item["clientId"] as! String)
        partList.name = (item["name"] as! String)
        partList.role = (item["role"] as! String)
        partList.hasJoin = false
        listOfParticipantInRoom.append(partList)
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, userDidDisconnected Data: [Any]?) {
        let items = Data![0] as! [String : Any]
          for (index, item) in listOfParticipantInRoom.enumerated(){
              if(item.clientId == (items["clientId"] as! String)){
                  listOfParticipantInRoom.remove(at: index)
                  break
              }
          }
    }
    /*
     This Delegate will notify to User if any person got discunnected
     */
    func room(_ room: EnxRoom?, didChangeStatus status: EnxRoomStatus) {
        //To Do
    }
        /*
     This Delegate will notify to User if any participant will send chat data
     */
    func room(_ room: EnxRoom, didMessageReceived data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to User if any participant will send message over custome signaling
    */
    func room(_ room: EnxRoom, didUserDataReceived data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to User if any participant will start sharing files
    */
    func room(_ room: EnxRoom, didFileUploadStarted data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if he/she will start sharing files
    */
    func room(_ room: EnxRoom, didInitFileUpload data: [Any]?) {
        //To Do
    }
    /*
    This Delegate will notify to self  if file sharing success
    */
    func room(_ room: EnxRoom, didFileUploaded data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to self  if file sharing failed
    */
    func room(_ room: EnxRoom, didFileUploadFailed data: [Any]?) {
        //To DO
    }
    /*
    This Delegate will notify to end user  if file available
    */
    func room(_ room: EnxRoom, didFileAvailable data: [Any]?) {
        //TO DO
    }
    /*
    This Delegate will notify to self  if file download failed
    */
    func room(_ room: EnxRoom, didFileDownloadFailed data: [Any]?) {
        //TO Do
    }
    /*
    This Delegate will notify to self  if file download success
    */
    func room(_ room: EnxRoom, didFileDownloaded data: String?) {
        //TO DO
    }
    /*
     This Delegate will notify to User to get updated attributes of particular Stream
     */
    func room(_ room: EnxRoom?, didUpdateAttributesOfStream stream: EnxStream?) {
        //To Do
    }
    
    /*
     This Delegate will notify when internet connection lost.
     */
    func room(_ room: EnxRoom?, didConnectionLost data: [Any]?) {
        
    }
    
    /*
     This Delegate will notify on connection interuption example switching from Wifi to 4g.
     */
    func room(_ room: EnxRoom?, didConnectionInterrupted data: [Any]?) {
        
    }
    
    /*
     This Delegate will notify reconnect success.
     */
    func room(_ room: EnxRoom?, didUserReconnectSuccess data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify to User if any new User Reconnect the room
     */
    func room(_ room:EnxRoom?, didReconnect reason: String?){
        
    }
       func room(_ room: EnxRoom?, didActiveTalkerView view: UIView?) {
        if(room != breakOUtRoom){
            self.view.addSubview(view!)
            self.view.bringSubviewToFront(localPlayerView)
            self.view.bringSubviewToFront(optionsContainerView)
            self.view.bringSubviewToFront(sendLogBtn)
             self.view.bringSubviewToFront(inviteBreakoutRoom)
         self.view.bringSubviewToFront(breakoutViewView)
        }
       }
    
    /* To Ack. moderator on switch user role.
     */
    func room(_ room: EnxRoom?, didSwitchUserRole data: [Any]?) {
        
    }
    
    /* To all participants that user role has chnaged.
     */
    func room(_ room: EnxRoom?, didUserRoleChanged data: [Any]?) {
        
    }
    
    /*
     This Delegate will Acknowledge setting advance options.
     */
    func room(_ room: EnxRoom?, didAcknowledgementAdvanceOption data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify battery updates.
     */
    func room(_ room: EnxRoom?, didBatteryUpdates data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify change on stream aspect ratio.
     */
    func room(_ room: EnxRoom?, didAspectRatioUpdates data: [String : Any]?) {
        
    }
    
    /*
     This Delegate will notify change video resolution.
     */
    func room(_ room: EnxRoom?, didVideoResolutionUpdates data: [Any]?) {
        
    }
    
    
    //Mark- EnxStreamDelegate Delegate
    /*
     This Delegate will notify to current User If any user has stoped There Video or current user Video
     */
    func didVideoEvents(_ data: [String : Any]?) {
        //To Do
    }
    /*
     This Delegate will notify to current User If any user has stoped There Audio or current user Video
     */
    func didAudioEvents(_ data: [String : Any]?) {
        //To Do
    }
    func didLogUpload(_ data: [Any]?) {
        let alert = UIAlertController(title: " ", message: "Upload loges success", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - BreakoutRoom
    func room(_ room: EnxRoom?, didAckInviteBreakOutRoom data: [Any]?) {
        print("invite other for breakout room ACK \(data![0])")
    }
    func room(_ room: EnxRoom?, didAckCreateBreakOutRoom data: [Any]?) {
        if(data != nil){
            if let resDict = data![0] as? [String : Any]{
                print(resDict)
                if((resDict["result"] as! Int) == 0){
                    inviteBreakoutRoom.isHidden = false
                    joinBreakOutRoom.isHidden = false
                    let msg = resDict["msg"] as! [String: Any]
                    let rooms = msg["rooms"] as! [String]
                    for roomId in rooms {
                        breakOutRoomList.append(roomId)
                    }
                }
            }
        }
    }
     func room(_ room: EnxRoom?, didConnectedBreakoutRoom data: [Any]?){
        breakOUtRoom = room
        invitedUserName.text = "Connected with breakout room"
        room?.publishStream?.delegate = self
        showAndHideBreakoutView(flag: true, isConnected: true)
        if(!btnAudioMute.isSelected){
            localStream.muteSelfAudio(true)
            btnAudioMute.isSelected = !btnAudioMute.isSelected
        }
        if(!btnVideoMute.isSelected){
           // localStream.muteSelfVideo(true)
            //btnVideoMute.isSelected = !btnVideoMute.isSelected
        }
        let muteInfo : [String : Any] = ["audio": true , "video" : false]
        remoteRoom.muteRoom(muteInfo)
    }
    func room(_ room: EnxRoom?, didInvitationForBreakoutRoom data: [Any]?) {
        breakOutRoomInfo = (data![0] as! [String : Any])
        let requesterDetails = breakOutRoomInfo["requestor"] as! [String : String]
        featchNameofInviteUser(clientID: requesterDetails["id"]!)
        showAndHideBreakoutView(flag: true, isConnected: false)
        //too
    }
    func room(_ room: EnxRoom?, didFailedJoinBreakOutRoom data: [Any]?) {
        showAndHideBreakoutView(flag: false, isConnected: false)
    }
    func room(_ room: EnxRoom?, didAckMuteRoom data: [Any]?) {
        print("mute room ack \(data![0])")
    }
    func room(_ room: EnxRoom?, didAckUnmuteRoom data: [Any]?) {
        print("unmute room ack \(data![0])")
    }
    func room(_ room: EnxRoom?, didDestroyedBreakoutRoom data: [Any]?) {
        let roomDict = data![0] as! [String : String]
        if(breakOutRoomList.count > 0){
            for (index,roomID) in breakOutRoomList.enumerated(){
                if(roomID == (roomDict["room_id"]!)){
                    breakOutRoomList.remove(at: index)
                    break
                }
            }
            if(breakOutRoomList.count == 0){
                inviteBreakoutRoom.isHidden = true
                joinBreakOutRoom.isHidden = true
            }
        }
    }
    func room(_ room: EnxRoom?, didAckPause data: [Any]?) {
        
        print("pause room ack \(data![0])")
    }
    func room(_ room: EnxRoom?, didAckResume data: [Any]?) {
        print("resume room ack \(data![0])")
    }
    func room(_ room: EnxRoom?, didUserJoinedBreakoutRoom data: [Any]?) {
        let dict = data![0] as! [String : Any]
        updateUserforBreakoutRoom(isConnectd: true, withClientId: (dict["client"] as! String))
    }
    func room(_ room: EnxRoom?, didUserDisconnectedFromBreakoutRoom data: [Any]?) {
        let userDict = data![0] as! [String : String]
        updateUserforBreakoutRoom(isConnectd: false, withClientId: userDict["clientId"]!)
    }
    func room(_ room: EnxRoom?, didDisconnectedBreakoutRoom respons: [Any]?) {
        if(btnAudioMute.isSelected){
            localStream.muteSelfAudio(false)
            btnAudioMute.isSelected = !btnAudioMute.isSelected
        }
        if(btnVideoMute.isSelected){
           // localStream.muteSelfVideo(false)
            btnVideoMute.isSelected = !btnVideoMute.isSelected
        }
        let unmuteInfo : [String : Any] = ["audio" : false, "video" : false]
        remoteRoom.unmuteRoom(unmuteInfo)
        showAndHideBreakoutView(flag: false, isConnected: false)
    }
}
// MARK: - UIPopover controller delegate methods
extension EnxConfrenceViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
extension EnxConfrenceViewController : breakOutRoomTapEvent,inviteTapEvent{
    func getSelectedRoomId(roomID: String, actionType: String) {
        breakOutpopoverViewController.dismiss(animated: true, completion: nil)
        print("Action Type \(actionType)")
        if(actionType == "Invite"){
            self.performSegue(withIdentifier: "participantPopOver", sender: roomID)
        }
        else{
            self.joinBreakOutRoomID(roomId: roomID)
        }
        print("Room Id Type \(roomID)")
    }
    func inviteUser(roomID: String, clientId : String){
        participantpopoverViewController.dismiss(animated: true, completion: nil)
        let inviteInfo : [String : Any] = ["clients" :[clientId] ,"room_id" : roomID]
        remoteRoom.invite(toBreakOutRoom: inviteInfo)
        
    }
    
}

