namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class PropertyDefinitionTest:
    [Test]
    def IntegralPropertyTest():
        propertyDef = Parser.parseText(Parser.propertyDefinition, "key=23")
        Assert.That(propertyDef, Is.EqualTo(AstFactory.PropertyDefinition("key", 23)))
    