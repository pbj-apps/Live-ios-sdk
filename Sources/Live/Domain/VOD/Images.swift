//
//  Images.swift
//  
//
//  Created by Pierre-Antoine Fagniez on 24/06/2022.
//

import Foundation

public struct Images: Equatable, Hashable {
    public let fullsize: URL?
    public let medium: URL?
    public let small: URL?
    public init(
        fullsize: String,
        medium: String,
        small: String
    ) {
        self.small = URL(string: small)
        self.medium = URL(string: medium)
        self.fullsize = URL(string: fullsize)
    }
}
