//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/08/2023.
//

import Foundation

extension HTTPURLResponse {
    
    private static var OK_200: Int { 200 }
    
    var isOK: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}
