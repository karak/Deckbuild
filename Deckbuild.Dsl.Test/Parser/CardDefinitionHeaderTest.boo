namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class CardDefinitionHeaderTest:
    [Test]
    def MinimumTextIsOk():
        actual = Parser.parseText(Parser.cardDefinitionHeader, "*Id:Suite")
        Assert.That(actual, Is.EqualTo(AstFactory.CardDefinitionHeader("Id", "Suite")))
