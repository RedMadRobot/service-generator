//
//  ServiceSchema.swift
//  ServiceGenerator
//
//  Created by Jeorge Taflanidi on 22/03/2017.
//  Copyright © 2017 RedMadRobot LLC. All rights reserved.
//


import Foundation


struct ServiceScheme {

    let name:            String
    let parent:          String
    let baseURL:         String?
    let addCookies:      Bool
    let receiveCookies:  Bool
    let needsAuthorizer: Bool

    let methods: [ServiceMethodScheme]

}
