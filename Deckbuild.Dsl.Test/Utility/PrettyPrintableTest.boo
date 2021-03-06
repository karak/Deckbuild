namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl.Utility

[PrettyPrintable]
class EmptyField:
	pass

[PrettyPrintable]
class IntWrapper:
	_value as int
	
	def constructor(value as int):
		_value = value

[PrettyPrintable]
class StringWrapper:
	_value as string
	
	def constructor(value as string):
		_value = value

[PrettyPrintable]
class Pair:
	_first as int
	_second as string
	
	def constructor(first as int, second as string):
		_first = first
		_second = second

[TestFixture]
class PrettyPrintableTest:
	[Test]
	def EmptyFieldIsEmptyParend():
		Assert.That(EmptyField().ToString(), Is.EqualTo("()"))
		
	[Test]
	def SingleIntegerFieldIsIdentical():
		Assert.That(IntWrapper(1).ToString(), Is.EqualTo("1"))
	
	[Test]
	def SingleStringFieldIsQuoted():
		Assert.That(StringWrapper("hello").ToString(), Is.EqualTo('"hello"'))
	
	[Test]
	def MultiFieldIsParendListSepBySemicolon():
		Assert.That(Pair(1, "second").ToString(), Is.EqualTo('(Pair| 1; "second")'))
		