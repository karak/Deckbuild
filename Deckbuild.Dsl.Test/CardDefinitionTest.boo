namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class CardDefinitionTest:
	final _headerSource = "*Id:Suite\n"
	final _header = CreateCardDefinitionHeader("Id", "Suite")
	final _property1Source = "key1=3\n"
	final _property1 = CreatePropertyDefinition("key1",3)
	final _property2Source = "key2=-45\n"
	final _property2 = CreatePropertyDefinition("key2",-45)
	
	[Test]
	public def HeaderWithEmptyBody():
		card = Parse(_headerSource)
		Assert.That(card, Is.EqualTo(CreateCardDefinition(_header)))
	
	[Test]
	public def ForgetNewlineAfterHeader():
		Assert.That(cast(Action, { Parse("*Id:Suite") }), Throws.Exception.TypeOf(Parser.InvalidAst));
	
	[Test]
	public def HeaderWithSingleBody():
		card = Parse("${_headerSource}${_property1Source}")
		Assert.That(card, Is.EqualTo(CreateCardDefinition(_header, _property1)))
	
	[Test]
	public def HeaderWithMultiBody():
		card = Parse("${_headerSource}${_property1Source}${_property2Source}")
		Assert.That(card, Is.EqualTo(CreateCardDefinition(_header, _property1, _property2)))
	
	private static def Parse(text as string):
		return Parser.parseText(Parser.cardDefinition, text)
		
	private static def CreateCardDefinitionHeader(cardId as string, suiteId as string):
		return Ast.CardDefinitionHeader(Ast.Identifier(cardId), Ast.Suite(Ast.Identifier(suiteId)))
	
	private static def CreatePropertyDefinition(id as string, value as int):
		return Ast.PropertyDefinition(Ast.Identifier(id), Ast.IntegralLiteral(value))
	
	private static def CreateCardDefinition(header as Ast.CardDefinitionHeader, *properties as (Ast.PropertyDefinition)):
		return Ast.CardDefinition(header, properties)


