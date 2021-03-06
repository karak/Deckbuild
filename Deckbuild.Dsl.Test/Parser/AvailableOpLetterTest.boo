namespace Deckbuild.Dsl.Test

import System
import NUnit.Framework
import Deckbuild.Dsl

[TestFixture]
class AvailableOpLetterTest:
	[Test]
	def PlusIsAvailable():
		AssertAvailableLetter('+')
	
	[Test]
	def MinusIsAvailable():
		AssertAvailableLetter('-')
	
	[Test]
	def SlashIsAvailable():
		AssertAvailableLetter('/')
	
	[Test]
	def PercentIsAvailable():
		AssertAvailableLetter('%')
	
	[Test]
	def AmpersandIsAvailable():
		AssertAvailableLetter('&')
	
	[Test]
	def BarIsAvailable():
		AssertAvailableLetter('|')
	
	[Test]
	def CircumflexIsAvailable():
		AssertAvailableLetter('^')
	
	[Test]
	def LessThanIsAvailable():
		AssertAvailableLetter('<')
	
	[Test]
	def GreaterThanIsAvailable():
		AssertAvailableLetter('>')
	
	private def AssertAvailableLetter(c as string):
		parsed = Parser.parseText(Parser.availableOpLetter, c)
		Assert.That(parsed, Is.EqualTo(c[0]))
		Assert.That(cast(System.Action, { Parser.parseText(Parser.identifierStartChar, c) }), Throws.TypeOf(Parser.InvalidAst))
		Assert.That(cast(System.Action, { Parser.parseText(Parser.identifierPartChar, c) }), Throws.TypeOf(Parser.InvalidAst))
	
	[Test]
	def EqualIsUnavailable():
		AssertUnavailableLetter('=')
	
	[Test]
	def AsteriskIsUnavailable():
		AssertUnavailableLetter('*')
	
	[Test]
	def ExclamationIsUnavailable():
		AssertUnavailableLetter('!')
	
	[Test]
	def QuestionIsUnavailable():
		AssertUnavailableLetter('?')
	
	[Test]
	def ColonIsUnavailable():
		AssertUnavailableLetter(':')
	
	[Test]
	def SemiclonIsUnavailable():
		AssertUnavailableLetter(';')
	
	[Test]
	def TildaIsUnavailable():
		AssertUnavailableLetter('~')
	
	private def AssertUnavailableLetter(c as string):
		Assert.That(cast(System.Action, { Parser.parseText(Parser.availableOpLetter, c) }), Throws.TypeOf(Parser.InvalidAst))
