//
//  SocketBasicPacketTest.swift
//  Socket.IO-Client-Swift
//
//  Created by Erik Little on 10/7/15.
//
//

import XCTest
@testable import SocketIO

class SocketBasicPacketTest: XCTestCase {
    let data = "test".data(using: String.Encoding.utf8)!
    let data2 = "test2".data(using: String.Encoding.utf8)!
    
    func testEmpyEmit() {
        let expectedSendString = "2[\"test\"]"
        let sendData = ["test"]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)

        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testNullEmit() {
        let expectedSendString = "2[\"test\",null]"
		let sendData: [Any] = ["test", NSNull()]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testStringEmit() {
        let expectedSendString = "2[\"test\",\"foo bar\"]"
        let sendData = ["test", "foo bar"]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testStringEmitWithQuotes() {
        let expectedSendString = "2[\"test\",\"\\\"he\\\"llo world\\\"\"]"
        let sendData = ["test", "\"he\"llo world\""]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testJSONEmit() {
        let expectedSendString = "2[\"test\",{\"foobar\":true,\"hello\":1,\"null\":null,\"test\":\"hello\"}]"
        let sendData: [Any] = ["test", ["foobar": true, "hello": 1, "test": "hello", "null": NSNull()]]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testArrayEmit() {
        let expectedSendString = "2[\"test\",[\"hello\",1,{\"test\":\"test\"}]]"
        let sendData: [Any] = ["test", ["hello", 1, ["test": "test"]]]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testBinaryEmit() {
        let expectedSendString = "51-[\"test\",{\"_placeholder\":true,\"num\":0}]"
        let sendData: [Any] = ["test", data]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
        XCTAssertEqual(packet.binary, [data])
    }
    
    func testMultipleBinaryEmit() {
        let sendData: [Any] = ["test", ["data1": data, "data2": data2] as NSDictionary]
        let packet = SocketPacket.packetFromEmit(sendData, id: -1, nsp: "/", ack: false)

        let binaryObj = packet.data[1] as! [String: Any]
        let data1Loc = (binaryObj["data1"] as! [String: Any])["num"] as! Int
        let data2Loc = (binaryObj["data2"] as! [String: Any])["num"] as! Int

        XCTAssertEqual(packet.type, .binaryEvent)
        XCTAssertEqual(packet.binary[data1Loc], data)
        XCTAssertEqual(packet.binary[data2Loc], data2)
    }
    
    func testEmitWithAck() {
        let expectedSendString = "20[\"test\"]"
        let sendData = ["test"]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: false)
        
        XCTAssertEqual(packet.packetString,
                       
                       expectedSendString)
    }
    
    func testEmitDataWithAck() {
        let expectedSendString = "51-0[\"test\",{\"_placeholder\":true,\"num\":0}]"
        let sendData: [Any] = ["test", data]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: false)

        XCTAssertEqual(packet.packetString, expectedSendString)
        XCTAssertEqual(packet.binary, [data])
    }
    
    // Acks
    func testEmptyAck() {
        let expectedSendString = "30[]"
        let packet = SocketPacket.packetFromEmit([], id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testNullAck() {
        let expectedSendString = "30[null]"
        let sendData = [NSNull()]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testStringAck() {
        let expectedSendString = "30[\"test\"]"
        let sendData = ["test"]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testJSONAck() {
        let expectedSendString = "30[{\"foobar\":true,\"hello\":1,\"null\":null,\"test\":\"hello\"}]"
        let sendData = [["foobar": true, "hello": 1, "test": "hello", "null": NSNull()]]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
    }
    
    func testBinaryAck() {
        let expectedSendString = "61-0[{\"_placeholder\":true,\"num\":0}]"
        let sendData = [data]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
        XCTAssertEqual(packet.binary, [data])
    }
    
    func testMultipleBinaryAck() {
        let expectedSendString = "62-0[{\"data1\":{\"_placeholder\":true,\"num\":1},\"data2\":{\"_placeholder\":true,\"num\":0}}]"
        let sendData = [["data1": data, "data2": data2]]
        let packet = SocketPacket.packetFromEmit(sendData, id: 0, nsp: "/", ack: true)
        
        XCTAssertEqual(packet.packetString, expectedSendString)
        XCTAssertEqual(packet.binary, [data2, data])
    }
    
    func testBinaryStringPlaceholderInMessage() {
        let engineString = "52-[\"test\",\"~~0\",{\"num\":0,\"_placeholder\":true},{\"_placeholder\":true,\"num\":1}]"
        let socket = SocketIOClient(socketURL: URL(string: "http://localhost/")!)
        socket.setTestable()
        
        if case let .right(packet) = socket.parseString(engineString) {
            var packet = packet
            XCTAssertEqual(packet.event, "test")
            _ = packet.addData(data)
            _ = packet.addData(data2)
            XCTAssertEqual(packet.args[0] as? String, "~~0")
        } else {
            XCTFail()
        }
    }
}
