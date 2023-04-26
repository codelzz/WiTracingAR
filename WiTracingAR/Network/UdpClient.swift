//
//  UDP.swift
//  WiTracingAR
//
//  Created by x on 24/11/2022.
//

import Foundation
import Network

class UdpClient {
    var connection: NWConnection?
    var host:NWEndpoint.Host?
    var port:NWEndpoint.Port?
    
    func connect(host: String, port:Int) {
        let host = NWEndpoint.Host(host)
        if let port = NWEndpoint.Port("\(port)") {
            self.connect(host: host, port: port)
        }
    }
    
    func connect(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        self.connection = NWConnection(host: host, port: port, using: .udp)
        self.connection?.stateUpdateHandler = { state in
        switch (state) {
            case .preparing, .ready, .setup, .cancelled:
                break
            case .failed:
                print("[INF] UdpClient failed")
            default:
                break
            }
        }
        self.connection?.start(queue: .global())
        self.host = host
        self.port = port
    }
    
    func reconnect() {
        if let host = self.host, let port = self.port {
            self.connect(host: host, port: port)
        }
    }
    
    func send(msg: String) {
        self.connection?.send(content: msg.data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ error in
            if let error = error {
                print("[ERR] \(self) - \(error)")
                self.reconnect()
            } else {
                self.recv()
            }
        })))
    }

    func recv() {
        self.connection?.receiveMessage { (data, context, isComplete, error) in
            if let error = error {
                print("[ERR] \(self) - \(error)")
            }
            guard let data = data else {
                return
            }
            if let json = UdpClient.decodeJSON(data: data) {
//                print("[INF] \(self) received \(json)")
            }
//            self.connection?.cancel()
        }
    }
    
    static func decodeJSON(data: Data) -> [String : Any]? {
        var json : [String : Any]?
        do{
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        }
        catch
        {
            print("[ERR] \(error)")
        }
        return json
    }
}
