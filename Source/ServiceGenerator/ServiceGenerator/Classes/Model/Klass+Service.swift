//
//  Klass+Service.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//


import Foundation


extension Klass {

    func isModel() -> Bool {
        return self.annotations.contains(annotationName: "model")
    }

    func isService() -> Bool {
        return self.annotations.contains(annotationName: "service")
    }

}
