//
//  SpritePreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class SpritePreviewViewController: UIViewController {

    let document: SPRDocument

    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(document: SPRDocument) {
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

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        document.open { result in
            switch result {
            case .success(let contents):
                let images = contents.images()
                let image = images[0]
                self.imageView.image = UIImage(cgImage: image)
                self.imageView.frame = CGRect(x: 0, y: 0, width: image.width, height: image.height)

                self.scrollView.contentSize = CGSize(width: image.width, height: image.height)

                self.updateZoomScale(image: image)
                self.centerScrollViewContents()
            case .failure(let error):
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

            self.document.close()
        }
    }

    private func updateZoomScale(image: CGImage) {
        let scrollViewFrame = scrollView.bounds

        let scaleWidth = scrollViewFrame.size.width / CGFloat(image.width)
        let scaleHeight = scrollViewFrame.size.height / CGFloat(image.height)
        let minScale = min(scaleWidth, scaleHeight)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 3

        scrollView.zoomScale = minScale
    }

    private func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
        }

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension SpritePreviewViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
