namespace Deckbuild.Dsl.Ast

import System
import Deckbuild.Dsl.Utility

[MemberwiseEquatable]
[PrettyPrintable]
class Identifier:
	[Getter(Name)]
	final _name as string
	
	def constructor(name as string):
		_name = name
		
interface RValue:
	def Accept(visitor as RValueVisitor):
		pass

[MemberwiseEquatable]
[PrettyPrintable]
class IntegralLiteral(RValue):
	[Getter(Value)]
	final _value as int
	
	def constructor(value as int):
		_value = value
	
	def RValue.Accept(visitor as RValueVisitor):
		visitor.Visit(self)
	
[MemberwiseEquatable]
[PrettyPrintable]
class Suite:
	[Getter(Id)]
	final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id

	
[MemberwiseEquatable]
[PrettyPrintable]
class CardDefinitionHeader:
	[Getter(Id)]
	final _id as Identifier
	
	[Getter(Suite)]
	final _suite as Suite
	
	def constructor(id as Identifier, suite as Suite):
		_id = id
		_suite = suite

[MemberwiseEquatable]
[PrettyPrintable]
class PropertyDefinition:
	[Getter(Id)]
	_id as Identifier
	[Getter(Value)]
	_value as RValue
	
	def constructor(id as Identifier, value as RValue):
		_id = id
		_value = value
	
[MemberwiseEquatable]
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

	//TODO: integration list format to PrettyPrintableAttribute
	override def ToString():
		return "[(Properties [${Format(_properties)}]) (Behaviors [${Format(_behaviors)}])]"
	
	private static def Format[of T](objs as T*):
		return String.Join(' ', array(string, map(objs, {x|x.ToString()})))


[MemberwiseEquatable]
[PrettyPrintable]
class CardDefinition:
	[Getter(Header)]
	_header as CardDefinitionHeader
	
	[Getter(Body)]
	_body as CardDefinitionBody
	
	def constructor(header as CardDefinitionHeader, body as CardDefinitionBody):
		_header = header
		_body = body
