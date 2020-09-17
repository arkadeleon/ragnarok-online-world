//
//  TextPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import HighlightedTextView

class TextPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var textView: HighlightedTextView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = previewItem.title

        view.backgroundColor = .systemBackground

        textView = HighlightedTextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard var data = try? self.previewItem.data() else {
                return
            }

            switch self.previewItem.fileType {
            case .lub:
                let decompiler = LuaDecompiler()
                data = decompiler.decompileData(data)
            default:
                break
            }

            DispatchQueue.main.async {
                guard var text = String(data: data, encoding: .ascii) else {
                    return
                }

                if self.previewItem.fileType == .xml {
                    text = text.replacingOccurrences(of: "<", with: "&lt;")
                    text = text.replacingOccurrences(of: ">", with: "&gt;")
                }

                self.textView.text = text
            }
        }
    }
}