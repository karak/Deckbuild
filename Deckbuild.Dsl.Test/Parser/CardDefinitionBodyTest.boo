namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class CardDefinitionBodyTest:
	[Test]
	def SinglePropertyIsOk():
		actual = Parser.parseText(Parser.cardDefinitionBody, "key=45\n")
		Assert.That(actual, Is.EqualTo(AstFactory.CardDefinitionBody(AstFactory.PropertyDefinition("Key", 45))))
	
	[Test]
	def SingleBehaviorIsOk():
		actual = Parser.parseText(Parser.cardDefinitionBody, "${BehaviorDefinitionTest.Source}\n")
		Assert.That(actual, Is.EqualTo(AstFactory.CardDefinitionBody(BehaviorDefinitionTest.Target)))

	[Test]
	def PropertyAndBehaviorIsOk():
		actual = Parser.parseText(Parser.cardDefinitionBody, "key=45\n${BehaviorDefinitionTest.Source}\n")
		expected = AstFactory.CardDefinitionBody((AstFactory.PropertyDefinition("Key", 45), ), (BehaviorDefinitionTest.Target, ))
		Assert.That(actual, Is.EqualTo(expected))
	