namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl


[TestFixture]
class ActionOperatorTest:
	[Test]
	def SingleLetter():
		ShouldSuccess("+")
	
	[Test]
	def DoubleLetters():
		ShouldSuccess(">>")
	
	[Test]
	def MixedLetters():
		ShouldSuccess("|-|")
		ShouldSuccess("<^^>")
	
	[Test]
	def LongLetters():
		ShouldSuccess("/^+%-&&&-%+^/")
	
	private def ShouldSuccess(text as string):
		parsed = Parser.parseText(Parser.actionOp, text)
		Assert.That(parsed, Is.EqualTo(AstFactory.ActionOp(text)))
