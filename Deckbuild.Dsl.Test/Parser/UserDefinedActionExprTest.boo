namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl


[TestFixture]
class UserDefinedActionExprTest:
	[Test]
	def IdentifierPlusIntegralValue():
		ShouldSuccess("point", "+", "10", 10)
		
	private def ShouldSuccess(lhs as string, op as string, rhs as string, rvalue as int):
		text = "${lhs}${op}${rhs}"
		expr = AstFactory.UserDefinedActionExpr(lhs, op, rvalue)
		parsed = Parser.parseText(Parser.actionExpr, text)
		Assert.That(parsed, Is.EqualTo(expr))
