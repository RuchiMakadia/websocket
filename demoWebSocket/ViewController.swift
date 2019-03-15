//
//  ViewController.swift
//  demoWebSocket
//
//  Created by eHeuristic on 30/11/18.
//  Copyright © 2018 eHeuristic. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController {

    var socket: WebSocket?
    @IBOutlet weak var txtURL: UITextField!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var lblResponse: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func connectToWebSocket() {
//        socket = WebSocket(url: URL(string: "ws://www.pingpongapp.eu:80")!)
//        socket = WebSocket(url: URL(string: "wss://www.pingpongapp.eu:443")!)
//        if let url = URL(string: txtURL.text ?? "wss://pingpongapp.eu:9001") {
        if let url = URL(string: txtURL.text ?? "wss://echo.websocket.org") {
            socket = WebSocket(url: url)
            //        socket.delegate = self
            if let socket = socket {
                //websocketDidConnect
                socket.onConnect = {
                    print("websocket is connected")
                    self.btnConnect.isSelected = true
                    self.txtMessage.isHidden = false
                    self.txtURL.isEnabled = false
                }
                //websocketDidDisconnect
                socket.onDisconnect = { (error: Error?) in
                    print("websocket is disconnected: \(error?.localizedDescription ?? "Something went wrong")")
                    self.btnConnect.isSelected = false
                    self.txtMessage.isHidden = true
                    self.txtURL.isEnabled = true
                }
                //websocketDidReceiveMessage
                socket.onText = { (text: String) in
                    print("got some text: \(text)")
                    if let oldAttrStr = self.lblResponse.attributedText {
                        let newAttrStr = NSMutableAttributedString(attributedString: oldAttrStr)
                        let newText = NSMutableAttributedString(string: "\n" + text + "\n")
                        newText.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], range: NSRange(location: 0, length: newText.length))
                        newAttrStr.append(newText)
                        self.lblResponse.attributedText = newAttrStr
                    }
                }
                //websocketDidReceiveData
                socket.onData = { (data: Data) in
                    print("got some data: \(data.count)")
                }
                socket.connect()
            }
        }
    }
    
    @IBAction func btnConnectDisconnectSelected(_ sender: UIButton) {
        if socket?.isConnected ?? false {
            socket?.disconnect()
        }
        else {
            connectToWebSocket()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if socket?.isConnected ?? false, textField == txtMessage {
            socket!.write(string: textField.text ?? "")
            print("Message write: \(textField.text!)")
            if let oldAttrStr = lblResponse.attributedText {
                let newAttrStr = NSMutableAttributedString(attributedString: oldAttrStr)
                let newText = NSMutableAttributedString(string: "\n" + (textField.text ?? ""))
                newText.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.lightGray], range: NSRange(location: 0, length: newText.length))
                newAttrStr.append(newText)
                lblResponse.attributedText = newAttrStr
            }
            else {
                let newText = NSMutableAttributedString(string: "\n" + (textField.text ?? ""))
                newText.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.lightGray], range: NSRange(location: 0, length: newText.length))
                lblResponse.attributedText = newText
            }
            textField.text = ""
        }
        else if textField == txtURL {
            connectToWebSocket()
        }
        textField.resignFirstResponder()
        return true
    }
}
