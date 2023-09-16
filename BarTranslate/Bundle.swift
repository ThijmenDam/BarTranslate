//
//  Bundle.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 01/08/2023.
//
//  Implementation credits: https://stackoverflow.com/a/68912269/8011179

import Foundation

extension Bundle {
    public var copyright: String         { getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }
    public var appVersionLong: String    { getInfo("CFBundleShortVersionString") }
    //public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }
}
