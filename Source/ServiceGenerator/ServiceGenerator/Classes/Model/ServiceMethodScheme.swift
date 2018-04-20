//
//  ServiceMethodScheme.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 22/03/2017.
//  Copyright © 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


struct ServiceMethodScheme {

    let httpVerb:        HTTPVerb
    let endpoint:        String
    let queryParameters: [Parameter]
    let headers:         [Parameter]
    let jsonParameters:  [Parameter]
    let plistParameters: [Parameter]

    let requestInterceptors:  [String]
    let responseInterceptors:  [String]
    
    let method: Method

    let autoLogin: Bool

    let parserName:        String
    let returnsCollection: Bool

    let returnedTypeName:            String
    let returnedModelObjectTypeName: String

    enum HTTPVerb: String {
        case delete
        case get
        case head
        case options
        case patch
        case post
        case put
    }

    struct Parameter {
        let placeholderName:     String
        let argumentName:        String
        let argumentDeclaration: SourceCodeLine
        let type:                Typê
    }

}


extension ServiceMethodScheme {
    
    var containsHeaders: Bool {
        return !headers.isEmpty
    }
    
    var containsRequestParameters: Bool {
        return !queryParameters.isEmpty ||
               !jsonParameters.isEmpty ||
               !plistParameters.isEmpty
    }
    
    var containsRequestInterceptors: Bool {
        return !requestInterceptors.isEmpty
    }
    
    var containsResponseInterceptors: Bool {
        return !responseInterceptors.isEmpty
    }
}
