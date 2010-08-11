namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl


[TestFixture]
class UserDefinedActionExprTest:
	[Test]
	def IdentifierPlusIntegralValue():
		ShouldSuccess("+", "print", "10", 10)
		
	private def ShouldSuccess(op as string, lhs as string, rhs as string, rvalue as int):
		text = "${op}${rhs}${lhs}"
		expr = AstFactory.UserDefinedActionExpr(lhs, op, rvalue)
		parsed = Parser.parseText(Parser.actionExpr, text)
		Assert.That(parsed, Is.EqualTo(expr))
