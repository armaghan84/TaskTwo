//
//  TCPConnection.swift
//  Task2
//
//  Created by Armaghan  on 4/22/21.
//

import Foundation
import Network

protocol TCPConnectionDelegate
{
    func didRecievedImageData(imgData: Data?)
}

class TCPConnection:NSObject
{

    var delegate : TCPConnectionDelegate?
    var connection: NWConnection?
    
    func start(host:NWEndpoint.Host, port: NWEndpoint.Port)
    {
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection!.stateUpdateHandler = self.stateDidChange(to:)
        self.setupReceive(on: connection!)
        connection!.start(queue: .main)
    }
    func stateDidChange(to state: NWConnection.State) {
        let ipAddressWithPort = connection!.endpoint.debugDescription
        let ip = ipAddressWithPort.components(separatedBy: ":")
        switch state {
        case .setup:
            break
        case .waiting(let error):
            print("Error",error)
        case .preparing:
            break
        case .ready:
            print("IP ADDRESS",ip[0])
        case .failed(let error):
            print("Failed",error)
        case .cancelled:
            break
        @unknown default:
            break
        }
        
    }
    
    func setupReceive(on connection: NWConnection)
    {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, contentContext, isComplete, error) in
            if let data = data, !data.isEmpty
            {
                self.delegate?.didRecievedImageData(imgData: data)
            }
            if isComplete
            {
                self.connectionDidEnd()
            } else if let error = error
            {
                self.connectionDidFail(error: error)
            } else
            {
                self.setupReceive(on: connection)
            }
        }
    }
    var didStopCallback: ((Error?) -> Void)? = nil
    private func connectionDidFail(error: Error)
    {
        print("connection did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd()
    {
        print("connection  did end")
        stop(error: nil)
    }
    private func stop(error: Error?)
    {
        connection!.stateUpdateHandler = nil
        connection!.cancel()
        if let didStopCallback = didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
    
    func sendStreamOriented(connection: NWConnection, data: Data) {
        connection.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Error",error)
            }
        }))
        
    }
  
    func sendEndOfStream(connection: NWConnection) {
        connection.send(content: nil, contentContext: .defaultStream, isComplete: true, completion: .contentProcessed({ error in
            if let error = error {
                print("Error",error)
            }
        }))
    }
    
    func sendMessage(message: [String:Any])
    {
        let json = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        guard let jsnStr = String(data: json!, encoding: .utf8) else { return }
        let msg = jsnStr + "\r\n"
        let data: Data? = msg.data(using: .utf8)
        connection!.send(content: data, completion: .contentProcessed { (sendError) in
            if let sendError = sendError {
                print("\(sendError)")
            }
        })
        self.setupReceive(on: connection!)
    }
    
    func cancel()
    {
        connection!.cancel()
    }
    

}
