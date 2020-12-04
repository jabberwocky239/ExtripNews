//
//  SwiftyParser.swift
//  Extrip News
//
//  Created by Maxim Gaysin on 02.12.2020.
//  Copyright © 2020 Ekstrip, OOO. All rights reserved.
//
import Foundation

/// available Type in XML.Accessor subscript
public protocol XMLSubscriptType {}
extension Int: XMLSubscriptType {}
extension String: XMLSubscriptType {}

infix operator ?= // Failable Assignment
/**
 assign value if rhs is not optonal. When rhs is optional, nothing to do.
*/
public func ?=<T>(lhs: inout T, rhs: T?) {
    if let unwrappedRhs = rhs {
        lhs = unwrappedRhs
    }
}

infix operator ?<< // Failable Push
/**
 push value to array if rhs is not optonal. When rhs is optional, nothing to do.
*/
public func ?<< <T>(lhs: inout [T], rhs: T?) {
    if let unwrappedRhs = rhs {
        lhs.append(unwrappedRhs)
    }
}


/**
 Director class to parse and access XML document.
 
 You can parse XML docuemnts with parse() method and get the accessor.
 
 ### Example
 ```
    let string = "<ResultSet><Result><Hit index="1"><Name>ほげ</Name></Hit><Hit index="2"><Name>ふが</Name></Hit></Result></ResultSet>"
    xml = XML.parse(string)
    let text = xml["ResultSet"]["Result"]["Hit"][0]["Name"].text {
        println("exsists path & text")
    }
    let text = xml["ResultSet", "Result", "Hit", 0, "Name"].text {
        println("exsists path & text")
    }
    let attributes = xml["ResultSet", "Result", "Hit", 0, "Name"].attributes {
        println("exsists path & attributes")
    }
    for hit in xml["ResultSet", "Result", "Hit"] {
        println("enumarate existing element")
    }
    switch xml["ResultSet", "Result", "TypoKey"] {
    case .Failure(let error):
        println(error)
    case .SingleElement(_), .Sequence(_):
        println("success parse")
    }
 ```
*/
open class XML {
    /**
    Interface to parse NSData
    
    - parameter data:NSData XML document
    - returns:Accessor object to access XML document
    */
    open class func parse(_ data: Data) -> Accessor {
        return Parser().parse(data)
    }
    
    /**
     Interface to parse String
     
     - Parameter str:String XML document
     - Returns:Accessor object to access XML document
     */
    open class func parse(_ str: String) throws -> Accessor {
        guard let data = str.data(using: String.Encoding.utf8) else {
            throw XMLError.failToEncodeString
        }
        
        return Parser().parse(data)
    }
    
    /**
     Interface to parse NSData
     
     - parameter data:NSData XML document
     - parameter manner:NSCharacterSet If you wannna trim Text, assign this arg
     - returns:Accessor object to access XML document
     */
    open class func parse(_ data: Data, trimming manner: CharacterSet) -> Accessor {
        return Parser(trimming: manner).parse(data)
    }
    
    /**
     Interface to parse String
     
     - Parameter str:String XML document
     - parameter manner:NSCharacterSet If you wannna trim Text, assign this arg
     - Returns:Accessor object to access XML document
     */
    open class func parse(_ str: String, trimming manner: CharacterSet) throws -> Accessor {
        guard let data = str.data(using: String.Encoding.utf8) else {
            throw XMLError.failToEncodeString
        }
        
        return Parser(trimming: manner).parse(data)
    }
    
    open class func document(_ accessor: Accessor) throws -> String {
        return try Converter(accessor).makeDocument()
    }
}

extension XML {
    
    /**
     Class for accessing XML Document as SequenceType.
     
     defined as enumeration which has three states
     - SingleElement
       - accesssed the specific XML Element from XML Path
     - Sequence
       - accessed multiple Elements from XML Path
     - Failure
       - wrong XML Path
     
     
    */
    @dynamicMemberLookup
    public enum Accessor: CustomStringConvertible, Swift.Sequence {
        case singleElement(Element)
        case sequence([Element])
        case failure(Error)
        
        public init(_ element: Element) {
            self = .singleElement(element)
        }
        
        public init(_ sequence: [Element]) {
            self = .sequence(sequence)
        }
        
        public init(_ error: Error) {
            self = .failure(error)
        }
        
        
        public subscript(dynamicMember member: String) -> XML.Accessor {
            return self[member]
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         
         ```
         let hit = xml[1][2][3]
         ```
         
         
         The same as:
         ```
         let hit = xml[1, 2, 3]
         ```
         
         or :
         ```
         let path = [1, 2, 3]
         let hit = xml[path]
         ```
         
         */
        fileprivate subscript(index index: Int) -> Accessor {
            let accessor: Accessor
            switch self {
            case .sequence(let elements) where index < elements.count:
                accessor =  Accessor(elements[index])
            case .singleElement(let element) where index == 0:
                accessor = Accessor(element)
            case .failure(let error):
                accessor = Accessor(error)
                break
            default:
                let error = accessError("cannot access Index: \(index)")
                accessor = Accessor(error)
                break
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         
         ```
         let hit = xml["ResultSet"]["Result"]["Hit"]
         ```
         
         The same as:
         ```
         let hit = xml["ResultSet", "Result", "Hit"]
         ```
         
         or :
         ```
         let path = ["ResultSet", "Result", "Hit"]
         let hit = xml[path]
         ```
         
         */
        fileprivate subscript(key key: String) -> Accessor {
            let accessor: Accessor
            switch self {
            case .singleElement(let element):
                let filterdElements = element.childElements.filter { $0.name == key }
                if filterdElements.isEmpty {
                    let error = accessError("\(key) not found.")
                    accessor =  Accessor(error)
                } else if filterdElements.count == 1 {
                    accessor =  Accessor(filterdElements[0])
                } else {
                    accessor =  Accessor(filterdElements)
                }
            case .failure(let error):
                accessor =  Accessor(error)
            case .sequence(_):
                fallthrough
            default:
                let error = accessError("cannot access \(key), because of multiple elements")
                accessor =  Accessor(error)
                break
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         ```
         let path = ["ResultSet", "Result", "Hit", 0]
         let hit = xml[path]
         ```
         The same as:
         ```
         let hit = xml["ResultSet", "Result", "Hit", 0]
         ```
         or :
         
         ```
         let hit = xml["ResultSet"]["Result"]["Hit"][0]
         ```
         */
        public subscript(path: Array<XMLSubscriptType>) -> Accessor {
            var accessor = self
            for position in path {
                switch position {
                case let index as Int:
                    accessor = accessor[index]
                case let key as String:
                    accessor = accessor[key]
                default:
                    let error = accessError("cannot access \(position)")
                    accessor = Accessor(error)
                }
            }
            return accessor
        }
        
        /**
         If Accessor object has a correct XML path, return XML element, otherwith return error
         
         example:
         ```
         let hit = xml["ResultSet", "Result", "Hit", 0]
         ```
         
         
         The same as:
         
         ```
           let path = ["ResultSet", "Result", "Hit", 0]
           let hit = xml[path]
         ```
         or :
         
         ```
           let hit = xml["ResultSet"]["Result"]["Hit"][0]
         ```
         */
        public subscript(path: XMLSubscriptType...) -> Accessor {
            var accessor = self
            for position in path {
                switch position {
                case let index as Int:
                    accessor = accessor[index: index]
                case let key as String:
                    accessor = accessor[key: key]
                default:
                    let error = accessError("cannot access \(position)")
                    accessor = Accessor(error)
                }
            }
            return accessor
        }
        
        public var name: String? {
            let name: String?
            switch self {
            case .singleElement(let element):
                name = element.name
            case .failure(_), .sequence(_):
                fallthrough
            default:
                name = nil
                break
            }
            return name
        }
        
        public var text: String? {
            let text: String?
            switch self {
            case .singleElement(let element):
                text = element.text
            case .failure(_), .sequence(_):
                fallthrough
            default:
                text = nil
                break
            }
            return text
        }
        
        
        /// syntax sugar to access Bool Text
        public var bool: Bool? {
            return text.flatMap { $0 == "true" }
        }
        
        
        /// syntax sugar to access URL Text
        public var url: URL? {
            return text.flatMap({URL(string: $0)})
        }
        
        /// syntax sugar to access Int Text
        public var int: Int? {
            return text.flatMap({Int($0)})
        }
        
        /// syntax sugar to access Double Text
        public var double: Double? {
            return text.flatMap({Double($0)})
        }
        
        /// access to XML Attributes
        public var attributes: [String: String] {
            let attributes: [String: String]
            switch self {
            case .singleElement(let element):
                attributes = element.attributes
            case .failure(_), .sequence(_):
                fallthrough
            default:
                attributes = [String: String]()
                break
            }
            return attributes
        }
        
        /// access to child Elements
        public var all: [Element]? {
            switch self {
            case .singleElement(let element):
                return [element]
            case .sequence(let elements):
                return elements
            case .failure(_):
                return nil
            }
        }
        
        /// access to child Elemnet Tag Names
        public var names: [String]? {
            switch self {
            case .singleElement(let element):
                return [element.name]
            case .sequence(let elements):
                return elements.map { $0.name }
            case .failure(_):
                return nil
            }
        }
        
        /// if it has wrong XML path, return Error, otherwise return nil
        public var error: Error? {
            switch self {
            case .failure(let error):
                return error
            case .singleElement(_), .sequence(_):
                return nil
            }
        }
        
        
        /// if it has wrong XML path or multiple child elements, return nil, otherwise return Element
        public var element: Element? {
            switch self {
            case .singleElement(let element):
                return element
            case .failure(_), .sequence(_):
                return nil
            }
        }
        
        /// if it has wrong XML path or no child Element, return nil, otherwise return last Element
        public var last: Accessor {
            switch self {
            case .singleElement(let element):
                return Accessor(element)
            case .sequence(let elements):
                if let lastElement = elements.last {
                    return Accessor(lastElement)
                } else {
                    return Accessor(accessError("cannot access last element"))
                }
            case .failure(let error):
                return Accessor(error)
            }
        }
        
        /// if it has wrong XML path or no child Element, return nil, otherwise return first Element
        public var first: Accessor {
            switch self {
            case .singleElement(let element):
                return Accessor(element)
            case .sequence(let elements):
                if let firstElement = elements.first {
                    return Accessor(firstElement)
                } else {
                    return Accessor(accessError("cannot access first element"))
                }
            case .failure(let error):
                return Accessor(error)
            }
        }
        
        public func map<T>(_ transform: (Accessor) -> T) -> [T] {
            switch self {
            case .singleElement(let element):
                return [Accessor(element)].map(transform)
            case .sequence(let elements):
                return elements.map({ Accessor($0) }).map(transform)
            case .failure:
                return [Accessor]().map(transform)
            }
        }

        @available(*, renamed:"flatMap")
        public func mapWithSqueezeNil<T>(_ transform: (Accessor) -> T?) -> [T] {
            var accessors = [Accessor]()
            switch self {
            case .singleElement(let element):
                accessors = [Accessor(element)]
            case .sequence(let elements):
                accessors = elements.map({ Accessor($0) })
            case .failure:
                accessors = [Accessor]()
            }
            return accessors.reduce([T]()) {
                let transformed = transform($1)
                if let unwrappedTransform = transformed {
                    return $0 + [unwrappedTransform]
                } else {
                    return $0
                }
            }
        }

        // MARK: - SequenceType
        
        public func makeIterator() -> AnyIterator<Accessor> {
            let generator: [XML.Element]
            switch self {
            case .failure(_):
                generator = []
            case .singleElement(let element):
                generator = [element]
            case .sequence(let elements):
                generator = elements
            }
            var index = 0
            return AnyIterator {
                let nextAccessor: Accessor?
                if index < generator.count {
                    nextAccessor = Accessor(generator[index])
                    index += 1
                } else {
                    nextAccessor = nil
                }
                return nextAccessor
            }
        }
        
        
        // MARK: - CustomStringConvertible
        
        public var description: String {
            switch self {
            case .singleElement(let element):
                return "\"" + self.recursivePrintAncient(element) + "\""
            case .sequence(let elements):
                let descriptions = elements.map { self.recursivePrintAncient($0) }
                return "[ " + descriptions.joined(separator: ",\n ") + " ]"
            case .failure(let error):
                return "\(error)"
            }
        }
        
        fileprivate func recursivePrintAncient(_ element: Element) -> String {
            var description = element.name
            if let unwrappedParent = element.parentElement {
                description = recursivePrintAncient(unwrappedParent) + " > " + description
            }
            return description
        }
        
        fileprivate func accessError(_ description: String) -> Error {
            return XMLError.accessError(description: description)
        }
    }
}

extension XML {
    /// Conveter to make xml document from Accessor.
    public class Converter {
        let accessor: XML.Accessor

        public init(_ accessor: XML.Accessor) {
            self.accessor = accessor
        }
        
        /**
         If Accessor object has correct XML path, return the XML element, otherwith return error
         
         example:
         
         ```
         let xml = try! XML.parse("<?xml version="1.0" encoding="UTF-8"?><doc><name key="value">text</name></doc>")
         let elem = xml.doc
         
         print(Converter(elem).makeDocument())
         // => <?xml version="1.0" encoding="UTF-8"?><name key="value">text</name>
         ```
         
         */
        public func makeDocument() throws -> String {
            if case .failure(let err) = accessor {
                throw err
            }

            var doc: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            for hit in accessor {
                switch hit {
                case .singleElement(let element):
                    doc += traverse(element)
                case .sequence(let elements):
                    doc += elements.reduce("") { (sum, el) in sum + traverse(el) }
                case .failure(let error):
                    throw error
                }
            }

            return doc
        }

        private func traverse(_ element: Element) -> String {
            let name = element.name
            let text = element.text ?? ""
            let attrs = element.attributes.map { (k, v) in "\(k)=\"\(v)\""  }.joined(separator: " ")

            let childDocs = element.childElements.reduce("", { (result, element) in
                result + traverse(element)
            })

            if name == "XML.Parser.AbstructedDocumentRoot" {
                return childDocs
            } else {
                return "<\(name) \(attrs)>\(text)\(childDocs)</\(name)>"
            }
        }
    }
}

import Foundation
#if canImport(FoundationXML)
    import FoundationXML
#endif

extension XML {
    class Parser: NSObject, XMLParserDelegate {
        /// If it has value, Parser is interuppted by error. (e.g. using invalid character)
        /// So the result of parsing is missing.
        /// See https://developer.apple.com/documentation/foundation/xmlparser/errorcode
        private(set) var error: XMLError?
        
        func parse(_ data: Data) -> Accessor {
            stack = [Element]()
            stack.append(documentRoot)
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            if let error = error {
                return Accessor(error)
            } else {
                return Accessor(documentRoot)
            }
        }
        
        override init() {
            trimmingManner = nil
        }
        
        init(trimming manner: CharacterSet) {
            trimmingManner = manner
        }
        
        // MARK:- private
        fileprivate var documentRoot = Element(name: "XML.Parser.AbstructedDocumentRoot")
        fileprivate var stack = [Element]()
        fileprivate let trimmingManner: CharacterSet?
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
            let node = Element(name: elementName)
            if !attributeDict.isEmpty {
                node.attributes = attributeDict
            }
            
            let parentNode = stack.last
            
            node.parentElement = parentNode
            parentNode?.childElements.append(node)
            stack.append(node)
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            if let text = stack.last?.text {
                stack.last?.text = text + string
            } else {
                stack.last?.text = "" + string
            }
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if let trimmingManner = self.trimmingManner {
                stack.last?.text = stack.last?.text?.trimmingCharacters(in: trimmingManner)
            }
            stack.removeLast()
        }
        
        func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            error = .interruptedParseError(rawError: parseError)
        }
      
//      func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
//        print("FOUND CDATA")
//        let str = String(data: CDATABlock, encoding: String.Encoding.utf8)
//        print(str)
//      }
    }
}

public enum XMLError: Error {
    case failToEncodeString
    case interruptedParseError(rawError: Error)
    case accessError(description: String)
}

extension XML {
    open class Element {
        open var name: String
        open var text: String?
        open var attributes = [String: String]()
        open var childElements = [Element]()
        
        // for println
        open weak var parentElement: Element?
        
        public init(name: String) {
            self.name = name
        }
    }
}
