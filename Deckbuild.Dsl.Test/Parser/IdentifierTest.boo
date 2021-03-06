namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class IdentifierTest:
    [Test]
    def AlphabetIsOk():
        ShouldSuccess("boo")
    
    [Test]
    def StartWithDigitIsNg():
        ShouldFail("1boo")
    
    [Test]
    def DigitPartIsOk():
        ShouldSuccess("boo123")
        
    [Test]
    def StartWithMinusIsNg():
        ShouldFail("-")
    
    [Test]
    def IncludingMinusIsNg():
        ShouldSuccessIncompletely("a-b", 1)
        
    [Test]
    def HiraganaIsOk():
        ShouldSuccess("あかずきん")

    [Test]
    def KatakanaIsOk():
        ShouldSuccess("モビルスーツ")
    
    [Test]
    def CjkKanjiIsOk():
        ShouldSuccess("神様")
    
    [Test]
    def StartWithKansujiIsOk():
        ShouldSuccess("一")
    
    [Test]
    def MixedJapaneseLettersIsOk():
        ShouldSuccess("このテストはNUnitで2010年に記述されました")
    
    private def ShouldSuccess(sourceId as string):
        id = Parser.parseText(Parser.identifier, sourceId)
        Assert.That(id, Is.EqualTo(Ast.Identifier(sourceId)))
    
    private def ShouldSuccessIncompletely(text as string, firstFailurePosition as int):
        id = Parser.parseText(Parser.identifier, text)
        Assert.That(id, Is.EqualTo(Ast.Identifier(text.Substring(0, firstFailurePosition))))
    
    private def ShouldFail(text as string):
        parse = cast(System.Action, { Parser.parseText(Parser.identifier, text) })
        Assert.That(parse, Throws.TypeOf(Parser.InvalidAst))
    
        