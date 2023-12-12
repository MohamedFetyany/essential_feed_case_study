//
//  XCTestCase+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 12/12/2023.
//

import XCTest

extension XCTestCase {
    
    func assert(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(for: snapshot,file: file,line: line)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the 'record' method to store a snapshot before asserting.",file: file,line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(),isDirectory: true)
                .appending(path: snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL),Stored snapshot URL: \(snapshotURL)",file: file,line: line)
        }
    }
    
    func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(for: snapshot,file: file,line: line)
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error \(error)",file: file,line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String,file: StaticString) -> URL {
        URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appending(path: "snapshots")
            .appending(path: "\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage,file: StaticString = #filePath,line: UInt = #line) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot",file: file,line: line)
            return nil
        }
        return data
    }
}
