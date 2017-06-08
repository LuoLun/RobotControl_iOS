//
//  Compiler.swift
//  RobotControl_iOS
//
//  Created by luolun on 2017/6/7.
//  Copyright © 2017年 Aaron. All rights reserved.
//

import UIKit

class Compiler: NSObject {
    
    var _statementGenerators = [String: StatementGenerator]()
    
    init(json: [String: Any]) throws {
        super.init()
        
        for blockCompileJson in json {
            let name = blockCompileJson.key
            guard let generators = blockCompileJson.value as? Array<[String: String]> else {
                throw CompileDefError.FormatError
            }
            
            let statementGenerator = StatementGenerator()
            for generator in generators {
                var codeGenerator: CodeGenerator?
                if let text = generator["text"] {
                    codeGenerator = TextCodeGenerator(text: text, compiler: self)
                }
                
                if let field = generator["field"] {
                    codeGenerator = FieldCodeGenerator(fieldName: field, compiler: self)
                }
                
                if let blockInput = generator["block_input"] {
                    codeGenerator = BlockInputCodeGenerator(inputName: blockInput, compiler: self)
                }
                
                guard let theCodeGenerator = codeGenerator else {
                    throw CompileDefError.ContentWrongError
                }
                
                statementGenerator._codeGenrators.append(theCodeGenerator)
            }
            
            _statementGenerators[name] = statementGenerator
        }
    }
    
    func compile(workspace: Workspace) throws -> String {
        let rootBlocks = workspace.rootBlocks()
        
        var codeString = ""
        for rootBlock in rootBlocks {
            codeString += try compile(block: rootBlock)
        }
        
        return codeString
    }
    
    func compile(block: Block) throws -> String {
        
        var block = block
        var codeString = ""
        
        // 如果block有自己的命名空间，则生成变量定义语句
        // !!!: (#7)暂时所有的变量都用float来存放
        if let variables = block._variableManager?.variables {
            for variable in variables {
                codeString += "float " + variable.codeNameWithNamespace() + " = 0;"
            }
        }
        
        while true {
            let name = block.name
            let statementGenerator = _statementGenerators[name]
            
            do {
                codeString += try statementGenerator!.generateCode(with: block)
            }
            
            if let nextBlock = block.nextConnection?.targetBlock {
                block = nextBlock
            } else {
                break
            }
        }
        
        return codeString
    }
}

class StatementGenerator: NSObject {
    var _codeGenrators = [CodeGenerator]()
    
    func generateCode(with block: Block) throws -> String {
        var codeString = ""
        for codeGenerator in _codeGenrators {
            codeString += try codeGenerator.generateCode(with: block)
        }
        return codeString
    }
}

class CodeGenerator: NSObject {
    
    weak var compiler: Compiler?
    
    init(compiler: Compiler) {
        self.compiler = compiler
        super.init()
    }
    
    // MARK: - Subclass
    func generateCode(with block: Block) throws -> String {
        fatalError()
    }
}

class TextCodeGenerator: CodeGenerator {
    let text: String
    
    init(text: String, compiler: Compiler) {
        self.text = text
        super.init(compiler: compiler)
    }
    
    override func generateCode(with block: Block) throws -> String {
        return text
    }
}

class FieldCodeGenerator: CodeGenerator {
    let fieldName: String
    
    init(fieldName: String, compiler: Compiler) {
        self.fieldName = fieldName
        super.init(compiler: compiler)
    }
    
    override func generateCode(with block: Block) throws -> String {
        let field = block.firstFieldWith(name: fieldName)
        
        guard let codeValue = try field!.codeValue() else {
            throw CompileDefError.wrongFieldTypeError(field: field!)
        }
        
        return codeValue
    }
}

class BlockInputCodeGenerator: CodeGenerator {
    let inputName: String
    
    init(inputName: String, compiler: Compiler) {
        self.inputName = inputName
        super.init(compiler: compiler)
    }
    
    override func generateCode(with block: Block) throws -> String {
        guard let blockInput = block.firstInputWith(name: inputName) as? BlockInput else {
            throw CompileTimeError.error("Cannot find block input name `\(inputName)`")
        }
        
        guard let targetBlock = blockInput.connection.targetBlock else {
            throw CompileTimeError.error("There is empty child-connection, please connect it before compiling.")
        }
        
        return try compiler!.compile(block: targetBlock)
    }
}

class CompileDefError: NSError {
    public let Domain = "CompileDefError"
    
    public static let FormatError = CompileDefError("Code generator definition format error.", code: 1)
    public static let ContentWrongError = CompileDefError("Generator must be one of `text`, `field`, `block_input`.", code: 2)
    
    class func wrongFieldTypeError(field: Field) -> CompileDefError  {
        return CompileDefError("Field type \(type(of: field)) cannot be used for generate code.", code: 3)
    }
    
    init(_ description: String, code: Int) {
        super.init(domain: Domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CompileTimeError: RobotControlError {
    public static let InputNotFound = CompileTimeError.init("Cannot find correspond input.", code: 2, domain: "CompileTimeError")
    
    public class func error(_ description: String) -> CompileTimeError {
        return CompileTimeError(description, code: 1, domain: "CompileTimeError")
    }
}

class CompileError: NSError {
    
    public static let VariableNotSelected = CompileError("Variable field has not been selectd.", code: 1)
    
    init(_ description: String, code: Int) {
        super.init(domain: "CompileError", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RobotControlError: NSError {
    init(_ description: String, code: Int , domain: String) {
        super.init(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    init(_ description: String, code: Int) {
        super.init(domain: String(describing: type(of: self)), code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
