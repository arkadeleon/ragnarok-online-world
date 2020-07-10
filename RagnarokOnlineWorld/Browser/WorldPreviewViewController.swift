//
//  WorldPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import MetalKit
import SGLMath

class WorldPreviewViewController: UIViewController {

    let source: DocumentSource
    private var ground: Ground?

    private var mtkView: MTKView!
    private var renderer: Renderer!
    private var camera = Camera()

    init(source: DocumentSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        mtkView = MTKView()
        view = mtkView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = source.name
        edgesForExtendedLayout = []

        view.backgroundColor = .systemBackground

        renderer = Renderer(vertexFunctionName: "groundVertexShader", fragmentFunctionName: "groundFragmentShader", render: render)
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.delegate = renderer

        mtkView.addGestureRecognizer(camera.panGestureRecognizer)
        mtkView.addGestureRecognizer(camera.pinchGestureRecognizer)

        loadSource()
    }

    private func loadSource() {
        DispatchQueue.global().async {
            guard case .entry(let url, let grf, _) = self.source else {
                return
            }

            guard let stream = try? FileStream(url: url) else {
                return
            }

            guard let data = try? self.source.data() else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(GNDDocument.self, from: data) else {
                return
            }

            let state = document.compile(WATER_LEVEL: 1, WATER_HEIGHT: 1)

            let textures = document.textures

            let ATLAS_COLS         = roundf(sqrtf(Float(textures.count)))
            let ATLAS_ROWS         = ceilf(sqrtf(Float(textures.count)))
            let ATLAS_WIDTH        = powf(2, ceilf(logf(ATLAS_COLS * 258) / logf(2)))
            let ATLAS_HEIGHT       = powf(2, ceilf(logf(ATLAS_ROWS * 258) / logf(2)))

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue

            guard let context = CGContext(
                data: nil,
                width: Int(ATLAS_WIDTH),
                height: Int(ATLAS_HEIGHT),
                bitsPerComponent: 8,
                bytesPerRow: Int(ATLAS_WIDTH) * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return
            }

            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(Int(ATLAS_HEIGHT)))
            context.concatenate(flipVertical)

            for (i, name) in textures.enumerated() {
                guard let entry = grf.entry(forName: "data\\texture\\" + name.lowercased()) else {
                    continue
                }
                let data = try! grf.contents(of: entry, from: stream)
                let image = UIImage(data: data)?.cgImage?.decoded

                let x = (i % Int(ATLAS_WIDTH)) * 258
                let y = (i / Int(ATLAS_WIDTH)) * 258
                context.draw(image!, in: CGRect(x: x, y: y, width: 258, height: 258))
                context.draw(image!, in: CGRect(x: x + 0, y: y + 0, width: 256, height: 256))
            }

            let jpeg = UIImage(cgImage: context.makeImage()!).jpegData(compressionQuality: 1.0)!

            let textureLoader = MTKTextureLoader(device: self.renderer.device)
            let texture = try? textureLoader.newTexture(cgImage: UIImage(data: jpeg)!.cgImage!, options: nil)

            DispatchQueue.main.async {
                self.ground = Ground(vertices: state.mesh, texture: texture)
            }
        }
    }

    private func render(encoder: MTLRenderCommandEncoder) {
        guard let ground = ground else {
            return
        }

        var modelviewMatrix = Matrix4x4<Float>()
        modelviewMatrix = SGLMath.translateZ(modelviewMatrix, -400)
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, radians(15), [1, 0, 0])
        modelviewMatrix = SGLMath.rotate(modelviewMatrix, Float(radians(435595.22182600008 * 360 / 8)), [0, 1, 0])
        modelviewMatrix = SGLMath.translate(modelviewMatrix, [100, -40, 60])

        let projectionMatrix = SGLMath.perspective(radians(camera.zoom), Float(mtkView.bounds.width / mtkView.bounds.height), 1, 1000)

        let normalMatrix = Matrix3x3(modelviewMatrix).inverse.transpose

        let fog = Fog(
            use: false,
            exist: true,
            far: 30,
            near: 80,
            factor: 1,
            color: [1, 1, 1]
        )

        let light = Light(
            opacity: 1,
            ambient: [1, 1, 1],
            diffuse: [0, 0, 0],
            direction: [0, 1, 0]
        )

        ground.render(
            encoder: encoder,
            modelviewMatrix: modelviewMatrix,
            projectionMatrix: projectionMatrix,
            normalMatrix: normalMatrix,
            fog: fog,
            light: light
        )
    }
}