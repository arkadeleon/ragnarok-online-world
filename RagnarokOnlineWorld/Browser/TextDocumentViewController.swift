//
//  TextDocumentViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class TextDocumentViewController: UIViewController {

    let document: LUADocument

    private var textView: UITextView!

    init(document: LUADocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = document.name

        view.backgroundColor = .systemBackground

        textView = UITextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)

        document.open { _ in
            self.textView.text = self.document.text
            self.document.close()
        }
    }
}
