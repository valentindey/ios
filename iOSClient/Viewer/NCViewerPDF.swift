//
//  NCViewerPDF.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 06/02/2020.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import PDFKit

@available(iOS 11, *)

@objc class NCViewerPDF: PDFView {
    
    private var thumbnailViewHeight: CGFloat = 48

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - thumbnailViewHeight))
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeTheming), name: NSNotification.Name(rawValue: "changeTheming"), object: nil)
    }
    
    @objc func changeTheming() {
        backgroundColor = NCBrandColor.sharedInstance.backgroundView
    }
    
    @objc func setupPdfView(filePath: URL, view: UIView) {
        
        guard let pdfDocument = PDFDocument(url: filePath) else {return}
        
        document = pdfDocument
        backgroundColor = NCBrandColor.sharedInstance.backgroundView
        displayMode = .singlePageContinuous
        autoScales = true
        displayDirection = .horizontal
        autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin]
        usePageViewController(true, withViewOptions: nil)
        
        view.addSubview(self)
        
        let pdfThumbnailView = PDFThumbnailView()
        pdfThumbnailView.translatesAutoresizingMaskIntoConstraints = false
        pdfThumbnailView.pdfView = self
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.thumbnailSize = CGSize(width: 40, height: thumbnailViewHeight - 2)
        //pdfThumbnailView.layer.shadowOffset.height = -5
        //pdfThumbnailView.layer.shadowOpacity = 0.25
        
        view.addSubview(pdfThumbnailView)
        
        pdfThumbnailView.heightAnchor.constraint(equalToConstant: thumbnailViewHeight).isActive = true
        pdfThumbnailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfThumbnailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfThumbnailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}
