namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class BehaviorDefinitionTest:
	private static final myTrigger = AstFactory.Trigger("Trigger")
	public static final Source = "trigger=>func1.func2"
	public static final Target = AstFactory.BehaviorDefinition(
		myTrigger,
		AstFactory.FunctionCallSequence("Func1", "Func2")
	)
	
	[Test]
	def functionCallSequenceTest():
		parsed = Parser.parseText(Parser.behaviorDefinition, Source)
		Assert.That(parsed, Is.EqualTo(Target))

