//
//  GNDDocument.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation
import SGLMath

struct GNDLightmap {

    var per_cell: Int32 = 0
    var count: UInt32 = 0
    var data = Data()
}

struct GNDTile {

    var u1: Float
    var u2: Float
    var u3: Float
    var u4: Float
    var v1: Float
    var v2: Float
    var v3: Float
    var v4: Float
    var texture: UInt16
    var light: UInt16
    var color: Vector4<UInt8>
}

struct GNDSurface {

    var height: Vector4<Float>
    var tile_up: Int32
    var tile_front: Int32
    var tile_right: Int32
}

class GNDDocument: Document {

    private var reader: BinaryReader!

    private(set) var header = ""
    private(set) var version = ""
    private(set) var width: UInt32 = 0
    private(set) var height: UInt32 = 0
    private(set) var zoom: Float = 0

    private(set) var textures: [String] = []
    private(set) var textureIndexes: [UInt16] = []

    private(set) var lightmap = GNDLightmap()

    private(set) var tiles: [GNDTile] = []
    private(set) var surfaces: [GNDSurface] = []

    override func load(from contents: Data) throws {
        let stream = DataStream(data: contents)
        reader = BinaryReader(stream: stream)

        header = try reader.readString(count: 4)
        guard header == "GRGN" else {
            throw DocumentError.invalidContents
        }

        let major = try reader.readUInt8()
        let minor = try reader.readUInt8()
        version = "\(major).\(minor)"

        width = try reader.readUInt32()
        height = try reader.readUInt32()
        zoom = try reader.readFloat32()

        try parseTextures()
        try parseLightmaps()

        tiles = try parseTiles()
        surfaces = try parseSurfaces()

        reader = nil
    }

    private func parseTextures() throws {
        let count = try reader.readUInt32()
        let length = try reader.readUInt32()

        var indexes: [UInt16] = []
        var textures: [String] = []

        for _ in 0..<count {
            let texture = try reader.readString(count: Int(length))
            var pos = textures.firstIndex(of: texture) ?? -1

            if pos == -1 {
                textures.append(texture)
                pos = textures.count - 1
            }

            indexes.append(UInt16(pos))
        }

        self.textures = textures
        self.textureIndexes = indexes
    }

    private func parseLightmaps() throws {
        let count = try reader.readUInt32()
        let per_cell_x = try reader.readInt32()
        let per_cell_y = try reader.readInt32()
        let size_cell = try reader.readInt32()
        let per_cell = per_cell_x * per_cell_y * size_cell

        self.lightmap = try GNDLightmap(
            per_cell: per_cell,
            count: count,
            data: reader.readData(count: Int(count) * Int(per_cell) * 4)
        )
    }

    private func parseTiles() throws -> [GNDTile] {
        let count = try reader.readUInt32()
        var tiles: [GNDTile] = []

        for _ in 0..<count {
            var tile = try GNDTile(
                u1: reader.readFloat32(),
                u2: reader.readFloat32(),
                u3: reader.readFloat32(),
                u4: reader.readFloat32(),
                v1: reader.readFloat32(),
                v2: reader.readFloat32(),
                v3: reader.readFloat32(),
                v4: reader.readFloat32(),
                texture: reader.readUInt16(),
                light: reader.readUInt16(),
                color: [reader.readUInt8(), reader.readUInt8(), reader.readUInt8(), reader.readUInt8()]
            )
            tile.texture = textureIndexes[Int(tile.texture)]
            ATLAS_GENERATE(tile: &tile)
            tiles.append(tile)
        }

        return tiles
    }

    private func parseSurfaces() throws -> [GNDSurface] {
        let count = width * height
        var surfaces: [GNDSurface] = []

        for _ in 0..<count {
            let surface = try GNDSurface(
                height: [reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5, reader.readFloat32() / 5],
                tile_up: reader.readInt32(),
                tile_front: reader.readInt32(),
                tile_right: reader.readInt32()
            )
            surfaces.append(surface)
        }

        return surfaces
    }

    private func ATLAS_GENERATE(tile: inout GNDTile) {
        let ATLAS_COLS         = roundf(sqrtf(Float(self.textures.count)))
        let ATLAS_ROWS         = ceilf(sqrtf(Float(self.textures.count)))
        let ATLAS_WIDTH        = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
        let ATLAS_HEIGHT       = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))
        let ATLAS_FACTOR_U     = (ATLAS_COLS * 258) / ATLAS_WIDTH
        let ATLAS_FACTOR_V     = (ATLAS_ROWS * 258) / ATLAS_HEIGHT
        let ATLAS_PX_U         = Float(1) / Float(258)
        let ATLAS_PX_V         = Float(1) / Float(258)

        let u   = Float(Int(tile.texture) % Int(ATLAS_COLS))
        let v   = floorf(Float(tile.texture) / ATLAS_COLS)
        tile.u1 = (u + tile.u1 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
        tile.u2 = (u + tile.u2 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
        tile.u3 = (u + tile.u3 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
        tile.u4 = (u + tile.u4 * (1 - ATLAS_PX_U * 2) + ATLAS_PX_U) * ATLAS_FACTOR_U / ATLAS_COLS
        tile.v1 = (v + tile.v1 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
        tile.v2 = (v + tile.v2 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
        tile.v3 = (v + tile.v3 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
        tile.v4 = (v + tile.v4 * (1 - ATLAS_PX_V * 2) + ATLAS_PX_V) * ATLAS_FACTOR_V / ATLAS_ROWS
    }
}
