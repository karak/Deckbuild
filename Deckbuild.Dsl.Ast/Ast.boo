namespace Deckbuild.Dsl.Ast

import System

//TODO: implement Equalilty by AstMacro
//TODO: implement Getters by AstMacro

class Identifier:
    [Getter(Name)]
    final _name as string
    
    def constructor(name as string):
        _name = name
    
    override def ToString():
        return "\"${_name}\""

    override def Equals(obj):
        casted = obj as Identifier
        if casted is not null:
            return op_Equality(self, casted) // avoid infinite loop when type "if self == casted".  why?
        else:
            return false
            
    override def GetHashCode():
        return _name.GetHashCode()
        
	static def op_Equality(lhs as Identifier, rhs as Identifier) as bool:
	    return lhs.Name == rhs.Name
	
class Suite:
    [Getter(Id)]
    final _id as Identifier
    
    def constructor(id as Identifier):
        _id = id

    override def ToString():
        return "(Suite ${_id})"
    
    override def Equals(obj):
        casted = obj as Suite
        if casted is not null:
            return op_Equality(self, casted)
        else:
            return false
            
    override def GetHashCode():
        return _id.GetHashCode()
        
	static def op_Equality(lhs as Suite, rhs as Suite):
	    return lhs.Id == rhs.Id

class CardDefinitionHeader:
    [Getter(Id)]
    final _id as Identifier
    
    [Getter(Suite)]
    final _suite as Suite
    
    def constructor(id as Identifier, suite as Suite):
        _id = id
        _suite = suite

    override def ToString():
        return "(CardDef ${_id} ${_suite})"
       
    override def Equals(obj):
        casted = obj as CardDefinitionHeader
        if casted is not null:
            return op_Equality(self, casted)
        else:
            return false
            
    override def GetHashCode():
        return _id.GetHashCode() ^ _suite.GetHashCode()
        
	static def op_Equality(lhs as CardDefinitionHeader, rhs as CardDefinitionHeader):
	    return lhs.Id == rhs.Id and lhs.Suite == rhs.Suite
