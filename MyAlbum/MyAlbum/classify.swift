//
//  classify.swift
//  MyAlbum
//
//  Created by kw9w on 12/21/21.
//

import Foundation
import UIKit
import CoreML
import CoreMedia
import Vision


class ClassifyKindsOfPic {
    
    
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let classifier = try KindsOfSnacksClassifier(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request,error in
                self?.processObservations(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to create request")
        }
    }()
}

