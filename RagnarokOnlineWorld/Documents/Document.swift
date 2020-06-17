//
//  Document.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/8.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum DocumentSource {

    case url(URL)

    case entryInArchive(GRFArchive, String)

    fileprivate var name: String {
        switch self {
        case .url(let url):
            return url.lastPathComponent
        case .entryInArchive(_, let entryName):
            let lastPathComponent = entryName.split(separator: "\\").last
            return String(lastPathComponent ?? "")
        }
    }

    fileprivate var fileType: String {
        switch self {
        case .url(let url):
            return url.pathExtension
        case .entryInArchive(_, let entryName):
            let pathExtension = entryName.split(separator: "\\").last?.split(separator: ".").last
            return String(pathExtension ?? "")
        }
    }

    fileprivate func data() throws -> Data {
        switch self {
        case .url(let url):
            return try Data(contentsOf: url)
        case .entryInArchive(let archive, let entryName):
            guard let entry = archive.entry(forName: entryName) else {
                return Data()
            }
            return try archive.contents(of: entry)
        }
    }
}

class Document: NSObject {

    let source: DocumentSource
    let name: String
    let fileType: String

    init(source: DocumentSource) {
        self.source = source
        self.name = source.name
        self.fileType = source.fileType
        super.init()
    }

    func open(completionHandler: ((Bool) -> Void)? = nil) {
        DispatchQueue.global().async {
            do {
                let contents = try self.source.data()
                try self.load(from: contents)
                DispatchQueue.main.async {
                    completionHandler?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler?(false)
                }
            }
        }
    }

    func load(from contents: Data) throws {

    }

    func close(completionHandler: ((Bool) -> Void)? = nil) {

    }
}
