namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl


[TestFixture]
class UserDefinedActionExprTest:
	[Test]
	def IdentifierPlusIntegralValue():
		ShouldSuccess("+ 10 print", "+", "Print", 10)
		
	private def ShouldSuccess(text as string, op as string, lhs as string, rvalue as int):
		expr = AstFactory.UserDefinedActionExpr(lhs, op, rvalue)
		parsed = Parser.parseText(Parser.actionExpr, text)
		Assert.That(parsed, Is.EqualTo(expr))
