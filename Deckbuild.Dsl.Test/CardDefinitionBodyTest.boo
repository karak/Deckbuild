namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class CardDefinitionBodyTest:
	[Test]
	def SinglePropertyIsOk():
		actual = Parser.parseText(Parser.cardDefinitionBody, "key=45\n")
		Assert.That(actual, Is.EqualTo(AstFactory.CardDefinitionBody(AstFactory.PropertyDefinition("key", 45))))
		


