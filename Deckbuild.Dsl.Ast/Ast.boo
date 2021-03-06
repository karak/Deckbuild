namespace Deckbuild.Dsl.Ast

import System
import Deckbuild.Dsl.Utility

[MemberwiseEquatable]
[PrettyPrintable]
class Identifier:
	[Getter(Name)]
	private final _name as string
	
	def constructor(name as string):
		_name = name
		
interface IRValue:
	def Accept(visitor as IRValueVisitor):
		pass

[MemberwiseEquatable]
[PrettyPrintable]
final class IntegralLiteral(IRValue, IActionParameter):
	[Getter(Value)]
	private final _value as int
	
	def constructor(value as int):
		_value = value
	
	def IRValue.Accept(visitor as IRValueVisitor):
		visitor.Visit(self)
	
	def IActionParameter.Accept(visitor as IActionParameterVisitor):
		visitor.Visit(self)


[MemberwiseEquatable]
[PrettyPrintable]
class Suite:
	[Getter(Id)]
	private final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id

	
[MemberwiseEquatable]
[PrettyPrintable]
class CardDefinitionHeader:
	[Getter(Id)]
	private final _id as Identifier
	
	[Getter(Suite)]
	private final _suite as Suite
	
	def constructor(id as Identifier, suite as Suite):
		_id = id
		_suite = suite

[MemberwiseEquatable]
[PrettyPrintable]
class PropertyDefinition:
	[Getter(Id)]
	private _id as Identifier
	[Getter(Value)]
	private _value as IRValue
	
	def constructor(id as Identifier, value as IRValue):
		_id = id
		_value = value
	
[MemberwiseEquatable]
class CardDefinitionBody:
	private  final _properties = List[of PropertyDefinition]()
	private  final _behaviors = List[of BehaviorDefinition]()
	
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
	private  final _header as CardDefinitionHeader
	
	[Getter(Body)]
	private  final _body as CardDefinitionBody
	
	def constructor(header as CardDefinitionHeader, body as CardDefinitionBody):
		_header = header
		_body = body
