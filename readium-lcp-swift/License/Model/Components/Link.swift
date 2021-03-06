//
//  Link.swift
//  readium-lcp-swift
//
//  Created by Alexandre Camilleri on 9/8/17.
//
//  Copyright 2018 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation

/// A Link to a resource.
public struct Link {
    
    /// The link destination.
    public let href: String
    /// Indicates the relationship between the resource and its containing collection.
    public let rel: [String]
    /// Title for the Link.
    public let title: String?
    /// Expected MIME media type value for the external resources.
    public let type: String?
    /// Indicates that the linked resource is a URI template.
    public let templated: Bool
    /// Expected profile used to identify the external resource. (URI)
    public let profile: String?
    /// Content length in octets.
    public let length: Int?
    /// SHA-256 hash of the resource.
    public let hash: String?

    init(json: [String : Any]) throws {
        guard let href = json["href"] as? String else{
            throw ParsingError.link
        }
        
        if let rel = json["rel"] as? String {
            self.rel = [rel]
        } else if let rel = json["rel"] as? [String], !rel.isEmpty {
            self.rel = rel
        } else {
            throw ParsingError.link
        }
        
        self.href = href
        self.title = json["title"] as? String
        self.type = json["type"] as? String
        self.templated = (json["templated"] as? Bool) ?? false
        self.profile = json["profile"] as? String
        self.length = json["length"] as? Int
        self.hash = json["hash"] as? String
    }
    
    /// Gets the valid URL if possible, applying the given template context as query parameters if the link is templated.
    /// eg. http://url{?id,name} + [id: x, name: y] -> http://url?id=x&name=y
    func url(with parameters: [String: CustomStringConvertible]) -> URL? {
        if !templated {
            return URL(string: href)
        }
        
        let urlString = href.replacingOccurrences(of: "\\{\\?.+?\\}", with: "", options: [.regularExpression])
        
        guard var urlBuilder = URLComponents(string: urlString) else {
            return nil
        }
        
        // Add the template context as query parameters
        urlBuilder.queryItems = parameters.map { param in
            URLQueryItem(name: param.key, value: param.value.description)
        }
        
        return urlBuilder.url
    }
    
    /// Expands the href without any template context.
    var url: URL? {
        return url(with: [:])
    }

}
