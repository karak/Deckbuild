namespace Deckbuild.Dsl.Test

import System
import Deckbuild.Dsl
import NUnit.Framework

[TestFixture]
class FunctionCallTest:
	[Test]
	def SingleIdentifierVariableTest():
		parsed = Parser.parseText(Parser.functionCall, "simple")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Simple")))
	
	[Test]
	def MultiIdentifierVariableTest():
		parsed = Parser.parseText(Parser.functionCall, "an apple")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("AnApple")))

	[Test]
	def MonadicFunctionCallTest():
		parsed = Parser.parseText(Parser.functionCall, "func[arg]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func","Arg")))
	
	[Test]
	def SingleIntegerVariableTest():
		parsed = Parser.parseText(Parser.functionCall, "func[50]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func", cast(Ast.IActionParameter, AstFactory.IntegralLiteral(50)))))
	
	[Test]
	def DiadicFunctionCallTest():
		parsed = Parser.parseText(Parser.functionCall, "func[arg1][arg2]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("Func","Arg1", "Arg2")))
	
	[Test]
	def SeparatedFunctionIdTest():
		parsed = Parser.parseText(Parser.functionCall, "leave[a]for[b]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("LeaveFor","A", "B")))
	
	[Test]
	def NestedFunctionIdTest():
		parsed = Parser.parseText(Parser.functionCall, "f[g[arg]]")
		Assert.That(parsed, Is.EqualTo(AstFactory.FunctionCall("F", AstFactory.FunctionCall("G", "Arg"))))


[TestFixture]
class FunctionCallSequenceTest:
	[Test]
	def SingleTest():
		parsed = Parser.parseText(Parser.functionCallSeq, "simple")
		CollectionAssert.AreEqual(parsed, FCs("Simple"))
	
	[Test]
	def DoubleTest():
		parsed = Parser.parseText(Parser.functionCallSeq, "s1. s2")
		CollectionAssert.AreEqual(parsed, FCs("S1", "S2"))
	
	[Test]
	def TripleTest():
		parsed = Parser.parseText(Parser.functionCallSeq, "s1. s2. s3")
		CollectionAssert.AreEqual(parsed, FCs("S1", "S2", "S3"))

	private static def FCs(*functionIds as (string)):
		return array[of Ast.FunctionCall](FC(x) for x in functionIds)
	
	private static def FC(functionId as string):
		return AstFactory.FunctionCall(functionId)
