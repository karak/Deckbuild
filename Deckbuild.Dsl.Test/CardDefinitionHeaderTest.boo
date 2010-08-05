namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class CardDefinitionHeaderTest:
    [Test]
    def MinimumTextIsOk():
        actual = Parser.parseText(Parser.cardDefinitionHeader, "*Id:Suite")
        Assert.That(actual, Is.EqualTo(CreateHeader("Id", "Suite")))

    static private def CreateHeader(id as string, suite as string):
        return Ast.CardDefinitionHeader(Ast.Identifier(id), Ast.Suite(Ast.Identifier(suite)))
