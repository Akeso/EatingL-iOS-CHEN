//
//  EATNetworkError.swift
//  PhotoK-iOS
//
//  Created by star on 2024/3/14.
//

enum EATNetworkError: Error {

    case request(EATAPIRequest)
    case response(EATAPIResponse)
    case network(EATAPINetwork)
}

enum EATAPIRequest: String {
    case path
    case encrypt
}

enum EATAPIResponse: String {
    case decode
    case decrypt
}

enum EATAPINetwork: String {
    case error
    case cancelled
}
