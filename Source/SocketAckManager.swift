//
//  SocketAckManager.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 4/3/15.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Dispatch
import Foundation

/// The status of an ack.
public enum SocketAckStatusLegacy : String {
    /// The ack timed out.
    case noAck = "NO ACK"
}

private struct SocketAckLegacy : Hashable {
    let ack: Int
    var callback: AckCallbackLegacy!
    var hashValue: Int {
        return ack.hashValue
    }

    init(ack: Int) {
        self.ack = ack
    }

    init(ack: Int, callback: @escaping AckCallbackLegacy) {
        self.ack = ack
        self.callback = callback
    }

    fileprivate static func <(lhs: SocketAckLegacy, rhs: SocketAckLegacy) -> Bool {
        return lhs.ack < rhs.ack
    }

    fileprivate static func ==(lhs: SocketAckLegacy, rhs: SocketAckLegacy) -> Bool {
        return lhs.ack == rhs.ack
    }
}

struct SocketAckManagerLegacy {
    private var acks = Set<SocketAckLegacy>(minimumCapacity: 1)
    private let ackSemaphore = DispatchSemaphore(value: 1)

    mutating func addAck(_ ack: Int, callback: @escaping AckCallbackLegacy) {
        acks.insert(SocketAckLegacy(ack: ack, callback: callback))
    }

    /// Should be called on handle queue
    mutating func executeAck(_ ack: Int, with items: [Any], onQueue: DispatchQueue) {
        ackSemaphore.wait()
        defer { ackSemaphore.signal() }
        let ack = acks.remove(SocketAckLegacy(ack: ack))

        onQueue.async() { ack?.callback(items) }
    }

    /// Should be called on handle queue
    mutating func timeoutAck(_ ack: Int, onQueue: DispatchQueue) {
        ackSemaphore.wait()
        defer { ackSemaphore.signal() }
        let ack = acks.remove(SocketAckLegacy(ack: ack))

        onQueue.async() {
            ack?.callback?([SocketAckStatusLegacy.noAck.rawValue])
        }
    }
}
