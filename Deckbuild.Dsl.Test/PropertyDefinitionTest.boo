namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class PropertyDefinitionTest:
    [Test]
    def IntegralPropertyTest():
        propertyDef = Parser.parseText(Parser.propertyDefinition, "key=23")
        Assert.That(propertyDef, Is.EqualTo(CreatePropertyDefinition("key", 23)))
    
    private static def CreatePropertyDefinition(id as string, value as int):
        return Ast.PropertyDefinition(Ast.Identifier(id), Ast.IntegralLiteral(value))
