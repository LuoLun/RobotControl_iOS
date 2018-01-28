//
//  ProjectManager.swift
//  BlocklySample
//
//  Created by luolun on 2017/2/9.
//  Copyright © 2017年 Google Inc. All rights reserved.
//

import UIKit
import AEXML

/// Project manager to save, load, and delete projects in xml.
@objc(RCProjectManager)
public class ProjectManager: NSObject {
    
    
    /// NSFileManager singleton object.
    static let fileManager = FileManager.default
    
    /// The document path url of this app.
    static var documentPathUrl : URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true);
        let documentDirectory = paths[0]
        return URL(fileURLWithPath: documentDirectory)
    }
    
    // MARK: - Internal
    
    internal static let challengeDirectoryName = "Chanllenge"
    internal static let projectDirectoryName = "Project"
    
    // MARK: - Basic
    
    
    /// Save an xml project with name and category.
    ///
    /// - Parameters:
    ///   - document: The xml document object.
    ///   - name: The projects name;
    ///   - category: The given category.
    public class func saveProject(document: AEXMLDocument, name: String, category: Category) throws {
        
        // Data representation of document.
        let data = document.xml.data(using: .utf8)
        
        // If the project directory of category doesn't exist, create the directory.
        let directoryUrl = category.projectDirectoryUrl
        if !fileManager.fileExists(atPath: directoryUrl.absoluteString) {
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Write the project as a file with project name as file name.
        let pathUrl = category.projectDirectoryUrl.appendingPathComponent(name)
        try data?.write(to: pathUrl)
        
        
    }
    
    
    /// Load a project with its name and category.
    ///
    /// - Parameters:
    ///   - name: The given name.
    ///   - category: The given category.
    /// - Returns: The loaded project object. If there if no such a project, returns an empty project.
    public class func loadProjectNamed(_ name: String, category: Category) throws -> Project {
        
        // Generate the full path for project file.
        let fullPathUrl = category.projectDirectoryUrl.appendingPathComponent(name)
        
        // Try to load the file contents as string.
        var string = ""
        do {
            string = try String.init(contentsOf: fullPathUrl)
        }
        catch let error {
            print("Error occurs when reading project file:\(fullPathUrl), \nerror:\(error)")
        }
        
        // Try to parse the loaded string as xml document.
        let document = try AEXMLDocument.init(xml: string)
        
        return Project(name: name, document: document)
    }
    
    
    /// Returns the project file url of the project with specified name and category.
    ///
    /// - Parameters:
    ///   - name: The given project name.
    ///   - category: The given category.
    /// - Returns: The target project directory url. Nil if cannot find the project with given name and category.
    public class func projectFileUrlFor(name: String, category: Category) -> URL? {
        if projectNameList(category: category).contains(name) == false {
            return nil
        }
        
        return category.projectDirectoryUrl.appendingPathComponent(name)
    }
    
    /// Delete a project with its name and category.
    ///
    /// - Parameters:
    ///   - name: The given name.
    ///   - category: The given category.
    public class func deleteProjectNamed(_ name: String, category: Category) {
        
        let fullPath = category.projectDirectoryUrl.appendingPathComponent(name)
        
        do {
            try fileManager.removeItem(at: fullPath)
        }
        catch let error {
            print("Fail to delete file, error: \(error)")
        }
        
    }
    
    /// Get all exist project names in a category.
    ///
    /// - Parameter category: The given category.
    /// - Returns: All names of projects in the
    /// given category. If error occurs while
    /// reading contents of directory, an exception
    /// would be thrown.
    public class func projectNameList(category: Category) -> [String] {
        
        var list = [String]()
        do {
            let pathUrl = category.projectDirectoryUrl
            list = try fileManager.contentsOfDirectory(atPath: pathUrl.relativePath)
        }
        catch let error {
            print("Error occurs when reading the contents of directory, error:\(error)")
        }
        
        return list
    }
    
    public class func generateProjectName(category: Category) -> String {
        
        let baseProjectName = "新项目"
        var number = 0
        
        let projectList = projectNameList(category: category)
        
        var currentProjectName = ""
        
        while true {
            if (number != 0) {
                currentProjectName = baseProjectName.appendingFormat("%d", number)
            }
            else {
                currentProjectName = baseProjectName
            }
            
            if projectList.contains(currentProjectName) == false {
                break
            }
            else {
                number += 1
            }
        }
        
        return currentProjectName
    }
    
    // MARK: Blockly
    
    /*public class func loadBlocklyProjectNamed(_ name: String, to workspace: Blockly.Workspace, with factory: BlockFactory) throws {
        
        let document = try loadProjectNamed(name, category: .Blockly).document
        
        do {
            let element: AEXMLElement = AEXMLElement(name: "")
            for child in document["xml"].children {
                if child.name == "block" {
                    element.addChild(child)
                }
            }
            
            // Before loading a project, clean all exists blocks.
            workspace.topLevelBlocks().forEach({ (block: Block) in
                do {
                    try workspace.removeBlockTree(block)
                }
                catch _ {
                    assert(false, "Unknown error. Possible try to remove block that can't be removed while loading blockly project file.")
                }
            })
            
            // Load blocks from xml.
            try workspace.loadBlocks(fromXML: element, factory: factory)
        }
        catch let error {
            print("Error occurs when loading document into workspace, error: \(error)")
        }
        
    }
    
    public class func saveBlocklyProject(name: String, workspace: Blockly.Workspace) throws {
        
        let document = try AEXMLDocument(xml: workspace.toXML())
        saveProject(document: document, name: name, category: .Blockly)
        
    }
 */
    
}

// MARK: - Class : Project

extension ProjectManager {
    
    @objc(RCProject)
    public class Project : NSObject {
        
        var name: String
        var document: AEXMLDocument
        
        init(name: String, document: AEXMLDocument) {
            self.name = name
            self.document = document
        }
        
    }
    
}

// MARK: - Enum : Category

extension ProjectManager {
    
    /// Represent the five types of projects in this app.
    @objc(RCProjectCategory)
    public enum Category: Int {
        case Blockly
        case Wonder
        case Go
        case Path
        case Xylo
        
        
        /// String represents different types of projects.
        ///
        /// - Returns: String represents specified type of project.
        func toString() -> String {
            switch self {
            case .Blockly:
                return "Blockly"
            case .Wonder:
                return "Wonder"
            case .Go:
                return "Go"
            case .Path:
                return "Path"
            case .Xylo:
                return "Xylo"
            }
        }
        
        
        /// The stored path of specified type of project.
        var projectDirectoryUrl: URL {
            return documentPathUrl.appendingPathComponent(projectDirectoryName).appendingPathComponent(self.toString())
        }
        
        var challengeDirectoryUrl: URL {
            return documentPathUrl.appendingPathComponent(challengeDirectoryName).appendingPathComponent(self.toString())
        }
        
    }
    
}
