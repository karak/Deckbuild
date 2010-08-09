namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class BehaviorDefinitionTest:
	private static final myTrigger = AstFactory.Trigger("trigger")
	private static final myMethodInvoke = AstFactory.MethodInvocationExpr("var", "method")
	public static final Source = "trigger=>var~method"
	public static final Target = AstFactory.BehaviorDefinition(myTrigger, myMethodInvoke)
	
	[Test]
	def MethodApplyTest():
		parsed = Parser.parseText(Parser.behaviorDefinition, Source)
		Assert.That(parsed, Is.EqualTo(Target))
	
	[Test]
	def MethodApplyThenMethodApplyTest():
		parsed = Parser.parseText(Parser.behaviorDefinition, "trigger=>var~method;var~method")
		expected = AstFactory.BehaviorDefinition(myTrigger, myMethodInvoke, myMethodInvoke)
		Assert.That(parsed, Is.EqualTo(expected))
		Assert.That(parsed, Is.Not.EqualTo(Target))

    

