namespace Deckbuild.Dsl.Test

import System
import Deckbuild.Dsl
import NUnit.Framework

[TestFixture]
class ActionFactorTest:
	[Test]
	def SingleIdentifierVariableTest():
		parsed = Parser.parseText(Parser.actionFactor, "simple")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Simple")))
	
	[Test]
	def MultiIdentifierVariableTest():
		parsed = Parser.parseText(Parser.actionFactor, "an apple")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("AnApple")))

	[Test]
	def MonadicFunctionCallTest():
		parsed = Parser.parseText(Parser.actionFactor, "func[arg]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func","Arg")))
	
	[Test]
	def SingleIntegerVariableTest():
		parsed = Parser.parseText(Parser.actionFactor, "func[50]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func", cast(Ast.IActionParameter, AstFactory.IntegralLiteral(50)))))
	
	[Test]
	def DiadicFunctionCallTest():
		parsed = Parser.parseText(Parser.actionFactor, "func[arg1][arg2]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func","Arg1", "Arg2")))
	
	[Test]
	def SeparatedFunctionIdTest():
		parsed = Parser.parseText(Parser.actionFactor, "leave[a]for[b]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("LeaveFor","A", "B")))
	
	[Test]
	def NestedFunctionIdTest():
		parsed = Parser.parseText(Parser.actionFactor, "f[g[arg]]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("F", AstFactory.FunctionCall("G", "Arg"))))
