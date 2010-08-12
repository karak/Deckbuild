namespace TinyDominion.Test

import System
import System.Collections.Generic
import NUnit.Framework
import Rhino.Mocks
import TinyDominion


[TestFixture]
class CardTest:
	_mocks as MockRepository
	_game as IGameFacade
	_predFactory as IPredicateFactory
	_turnOwner as IPlayer
	_cardMap as IDictionary[of string, ICard]
	_trash as ICardSink
	_hand as ICardBag
	
	[SetUp]
	def LoadAllCards():
		_mocks = MockRepository()
		_game = _mocks.StrictMock[of IGameFacade]()
		_predFactory = _mocks.StrictMock[of IPredicateFactory]()
		_turnOwner = _mocks.StrictMock[of IPlayer]()
		_trash = _mocks.StrictMock[of ICardSink]()
		_hand = _mocks.StrictMock[of ICardBag]()
		engine = ProgramModule.Build(_game, _predFactory, "../../../TinyDominion/scripts/all.dbc")
		_cardMap = Dictionary[of string, ICard]()
		for c in engine.Cards:
			_cardMap[c.Id] = c
	
	[Test]
	def CopperTest():
		DoTreasureCardTest "Copper", 0, 1
	
	private def DoTreasureCardTest(cardId as string, cost as int, coin as int):
		card = _cardMap[cardId] as TreasureCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		Assert.That(card.Coin, Is.EqualTo(coin))
		
	
	[Test]
	def EstateTest():
		DoVictoryCardTest "Estate", 2, 1
		
	private def DoVictoryCardTest(cardId as string, cost as int, victoryPoint as int):
		card = _cardMap[cardId] as VictoryCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		Assert.That(card.VictoryPoint, Is.EqualTo(victoryPoint))
		
	[Test]
	def VillageTest():
		DoActionCardTest "Village", 3:
			Expect.Call({_game.ActionPoint.Increase(2)})
			SetupResult.For(_game.TurnOwner).Return(_turnOwner)
			Expect.Call(_turnOwner.Draw(1)).Return(1)

	[Test]
	def SmithyTest():
		DoActionCardTest "Smithy", 4:
			SetupResult.For(_game.TurnOwner).Return(_turnOwner)
			Expect.Call(_turnOwner.Draw(3)).Return(3)

	[Test]
	def RemodelTest():
		cost = 0
		selected = _mocks.StrictMock[of IFloatingCard]()
		gained = _mocks.StrictMock[of IFloatingCard]()
		DoActionCardTest "Remodel", 4:
			using _mocks.Ordered():
				//select hand
				SetupResult.For(_game.TurnOwner).Return(_turnOwner)
				SetupResult.For(_turnOwner.Hand).Return(_hand)
				Expect.Call(_turnOwner.SelectOne(_hand)).Return(selected)
				//trash 
				SetupResult.For(_game.Trash).Return(_trash)
				selected.MoveTo(_trash)
				//gain
				SetupResult.For(selected.Card.Cost).Return(cost)
				Expect.Call(_predFactory.CostIsAtMost(cost + 2))
				Expect.Call(_turnOwner.GainOne(null)).IgnoreArguments().Return(gained)
			
	private def DoActionCardTest(cardId as string, cost as int, onPlayed as Action):
		card = _cardMap[cardId] as ActionCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		using _mocks.Record():
			onPlayed()
		using _mocks.Playback():
			card.Play()
		
