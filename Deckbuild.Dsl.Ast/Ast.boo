namespace Deckbuild.Dsl.Ast

import System

interface Node:
	pass

//TODO: implement Equalilty by AstMacro
//TODO: implement Getters by AstMacro

class Identifier(Node):
	[Getter(Name)]
	final _name as string
	
	def constructor(name as string):
		_name = name
	
	override def ToString():
		return "\"${_name}\""
		
	static def op_Equality(lhs as Identifier, rhs as Identifier) as bool:
		return lhs.Name == rhs.Name

	override def Equals(obj):
		casted = obj as Identifier
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _name.GetHashCode()
		
interface RValue(Node):
	pass

class IntegralLiteral(RValue):
	[Getter(Value)]
	final _value as int
	
	def constructor(value as int):
		_value = value
	
	override def ToString():
		return _value.ToString()

	static def op_Equality(lhs as IntegralLiteral, rhs as IntegralLiteral):
		return lhs.Value == rhs.Value
	
	override def Equals(obj):
		casted = obj as IntegralLiteral
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _value.GetHashCode()
		
	
class Suite(Node):
	[Getter(Id)]
	final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id

	override def ToString():
		return "(Suite ${_id})"
	
	static def op_Equality(lhs as Suite, rhs as Suite):
		return lhs.Id == rhs.Id

	override def Equals(obj):
		casted = obj as Suite
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _id.GetHashCode()
		
class CardDefinitionHeader(Node):
	[Getter(Id)]
	final _id as Identifier
	
	[Getter(Suite)]
	final _suite as Suite
	
	def constructor(id as Identifier, suite as Suite):
		_id = id
		_suite = suite

	override def ToString():
		return "(CardDef ${_id} ${_suite})"
	   
	static def op_Equality(lhs as CardDefinitionHeader, rhs as CardDefinitionHeader):
		return lhs.Id == rhs.Id and lhs.Suite == rhs.Suite
	
	override def Equals(obj):
		casted = obj as CardDefinitionHeader
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _id.GetHashCode() ^ _suite.GetHashCode()
		

class PropertyDefinition(Node):
	[Getter(Id)]
	_id as Identifier
	[Getter(Value)]
	_value as RValue
	
	def constructor(id as Identifier, value as RValue):
		_id = id
		_value = value

	override def ToString():
		return "(PropertyDef ${_id} ${_value})"
	
	static def op_Equality(lhs as PropertyDefinition, rhs as PropertyDefinition):
		return lhs.Id == rhs.Id and lhs.Value == rhs.Value
	
	override def Equals(obj):
		casted = obj as PropertyDefinition
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _id.GetHashCode() ^ _value.GetHashCode()
	
class CardDefinition(Node):
	[Getter(Header)]
	_header as CardDefinitionHeader
	[Getter(Properties)]
	_properties as PropertyDefinition*
	
	def constructor(header as CardDefinitionHeader, properties as PropertyDefinition*):
		_header = header
		_properties = properties

	override def ToString():
		formattedProperties = String.Join(' ', array(string, map(_properties, {x|x.ToString()})))
		return "(CardDef ${_header} (Properties ${formattedProperties}))"
		
	static def op_Equality(lhs as CardDefinition, rhs as CardDefinition):
		return lhs._header == rhs._header
		
	override def Equals(obj):
		casted = obj as CardDefinition
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _header.GetHashCode()
	