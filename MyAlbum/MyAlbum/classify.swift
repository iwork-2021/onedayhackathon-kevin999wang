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
    
    var identifier: String
    var confidence: String
    
    init() {
        self.identifier = ""
        self.confidence = ""
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let classifier = try snacks(configuration: MLModelConfiguration())
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
    
    func classify(image: UIImage) -> (String, String) {
        guard let newImage = image.cgImage else { return ("", "")}
        let handler = VNImageRequestHandler(cgImage: newImage)
        do {
            try handler.perform([self.classificationRequest])
        } catch {
            print("Failed to perform classification: \(error)")
        }
        return (self.identifier, self.confidence)
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNClassificationObservation] {
            if results.isEmpty {
                print("Nothing Found! Plase try again...")
            } else {
                let result = results[0].identifier
                let confidence = results[0].confidence
                self.confidence = String(format: "%.1f%%", confidence * 100)
                self.identifier = result
            }
        } else if let error = error {
            print("An error occured: \(error.localizedDescription)")
        } else {
            print("??? ")
        }
        
        
    }
    
}

