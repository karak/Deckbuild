namespace Deckbuild.Dsl.Ast

import System

//TODO: implement Equalilty by AstMacro MemberwiseEquatable: IEquatable<T>, op_Equality, Equals(T), Equals(object), GetHashCode

class Identifier:
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
		
interface RValue:
	def Accept(visitor as RValueVisitor):
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
		
	def RValue.Accept(visitor as RValueVisitor):
		visitor.Visit(self)
	
class Suite:
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
		
class PropertyDefinition:
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
	
class CardDefinitionBody:
	_properties = List[of PropertyDefinition]()
	_behaviors = List[of BehaviorDefinition]()
	
	Properties as PropertyDefinition*:
		get:
			return _properties
	
	Behaviors as BehaviorDefinition*:
		get:
			return _behaviors
	
	def AddProperty(property as PropertyDefinition):
		_properties.Add(property)
	
	def AddBehavior(behavior as BehaviorDefinition):
		_behaviors.Add(behavior)

	override def ToString():
		return "[(Properties [${Format(_properties)}]) (Behaviors [${Format(_behaviors)}])]"
		
	
	//NOTE: require ordering equality
	static def op_Equality(lhs as CardDefinitionBody, rhs as CardDefinitionBody):
		return lhs._properties.Equals(rhs._properties) and lhs._behaviors.Equals(rhs._behaviors)
	
	override def Equals(obj):
		casted = obj as CardDefinitionBody
		if casted is not null:
			return self == casted
		else:
			return false
			
	private static def GenerateHashCode[of T](list as List[of T]):
		count = list.Count
		code = 0
		limit = System.Math.Min(4, count)
		for i in range(0, limit):
			code ^= list[i].GetHashCode()
		return code
	
	private static def Format[of T](objs as T*):
		return String.Join(' ', array(string, map(objs, {x|x.ToString()})))
	
	override def GetHashCode():
		return GenerateHashCode(_properties) ^ GenerateHashCode(_behaviors)
		
		

class CardDefinition:
	[Getter(Header)]
	_header as CardDefinitionHeader
	
	[Getter(Body)]
	_body as CardDefinitionBody
	
	def constructor(header as CardDefinitionHeader, body as CardDefinitionBody):
		_header = header
		_body = body

	override def ToString():
		return "(CardDef ${_header} ${_body})"
		
	static def op_Equality(lhs as CardDefinition, rhs as CardDefinition):
		return lhs._header == rhs._header and lhs._body == rhs._body
		
	override def Equals(obj):
		casted = obj as CardDefinition
		if casted is not null:
			return self == casted
		else:
			return false
			
	override def GetHashCode():
		return _header.GetHashCode() ^ _body.GetHashCode()
