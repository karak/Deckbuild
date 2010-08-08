namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class BehaviorDefinitionTest:
	public static final Source = "trigger=>var~method"
	public static final Target = AstFactory.BehaviorDefinition(
    	AstFactory.Trigger("trigger"),
    	AstFactory.MethodInvocationExpr("var", "method")
    )
	
	[Test]
	def MethodApplyTest():
		parsed = Parser.parseText(Parser.behaviorDefinition, Source)
		Assert.That(parsed, Is.EqualTo(Target))
	

    

