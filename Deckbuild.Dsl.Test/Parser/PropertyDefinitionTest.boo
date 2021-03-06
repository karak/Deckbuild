namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class PropertyDefinitionTest:
    [Test]
    def IntegralPropertyTest():
        propertyDef = Parser.parseText(Parser.propertyDefinition, "key=23")
        Assert.That(propertyDef, Is.EqualTo(AstFactory.PropertyDefinition("Key", 23)))
    
    [Test]
    def MultiWordPropertyTest():
        propertyDef = Parser.parseText(Parser.propertyDefinition, "long long key=23")
        Assert.That(propertyDef, Is.EqualTo(AstFactory.PropertyDefinition("LongLongKey", 23)))
    