namespace TinyDominion.Test

import System
import NUnit.Framework
import Rhino.Mocks
import TinyDominion


[TestFixture]
class CardTest:
	_mocks as MockRepository
	_game as IGameFacade
	_predFactory as IPredicateFactory
	_turnOwner as IPlayer
	_trash as ICardSink
	_hand as ICardBag
	_discard as ICardSink
	_actionPoint as IIncreasible
	_buyPoint as IIncreasible
	_coinPoint as IIncreasible
	_factory as DslFactory
	
	[SetUp]
	def SetUp():
		_mocks = MockRepository()
		_game = _mocks.StrictMock[of IGameFacade]()
		_predFactory = _mocks.StrictMock[of IPredicateFactory]()
		_turnOwner = _mocks.StrictMock[of IPlayer]()
		_trash = _mocks.StrictMock[of ICardSink]()
		_hand = _mocks.StrictMock[of ICardBag]()
		_discard = _mocks.StrictMock[of ICardSink]()
		_actionPoint = _mocks.StrictMock[of IIncreasible]()
		_buyPoint = _mocks.StrictMock[of IIncreasible]()
		_coinPoint = _mocks.StrictMock[of IIncreasible]()
		SetupResult.For(_game.Trash).Return(_trash)
		SetupResult.For(_game.TurnOwner).Return(_turnOwner)
		SetupResult.For(_game.ActionPoint).Return(_actionPoint)
		SetupResult.For(_game.BuyPoint).Return(_buyPoint)
		SetupResult.For(_game.CoinPoint).Return(_coinPoint)
		SetupResult.For(_turnOwner.Hand).Return(_hand)
		SetupResult.For(_turnOwner.Discard).Return(_discard)
		_factory = DslFactory(_game, _predFactory)
	
	[Test]
	def CopperTest():
		DoTreasureCardTest "copper.dbc", 0, 1
	
	[Test]
	def SilverTest():
		DoTreasureCardTest "silver.dbc", 3, 2
	
	[Test]
	def GoldTest():
		DoTreasureCardTest "gold.dbc", 6, 3
	
	private def DoTreasureCardTest(filePath as string, cost as int, coin as int):
		card = Load(filePath) as TreasureCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		Assert.That(card.Coin, Is.EqualTo(coin))
		
	
	[Test]
	def EstateTest():
		DoVictoryCardTest "estate.dbc", 2, 1
		
	[Test]
	def DuchyTest():
		DoVictoryCardTest "duchy.dbc", 5, 3
		
	[Test]
	def ProvinceTest():
		DoVictoryCardTest "province.dbc", 8, 6
	
	[Test]
	def CurseTest():
		DoCurseCardTest "curse.dbc", 0, -1
		
	private def DoVictoryCardTest(filePath as string, cost as int, victoryPoint as int):
		card = Load(filePath) as VictoryCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		Assert.That(card.VictoryPoint, Is.EqualTo(victoryPoint))
	
	private def DoCurseCardTest(filePath as string, cost as int, victoryPoint as int):
		card = Load(filePath) as CurseCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		Assert.That(card.VictoryPoint, Is.EqualTo(victoryPoint))
		
	
	[Test]
	def CellarTest():
		numberToDiscard = 3
		mockCard = _mocks.StrictMock[of IFloatingCard]()
		discarded = (mockCard, mockCard, mockCard)
		DoActionCardTest "cellar.dbc", 2:
			using _mocks.Ordered():
				Expect.Call({_actionPoint.Increase(1)})
				Expect.Call(_turnOwner.SelectMany(_hand)).Return(discarded)
				Expect.Call({ mockCard.MoveTo(_discard) }).Repeat.Times(3, 3)
				Expect.Call(_turnOwner.Draw(numberToDiscard)).Return(numberToDiscard)
	
	[Test]
	def WoodCutterTest():
		DoActionCardTest "woodcutter.dbc", 3:
			Expect.Call({ _coinPoint.Increase(2) })
			Expect.Call({ _buyPoint.Increase(1) })
	
	[Test]
	def VillageTest():
		DoActionCardTest "village.dbc", 3:
			Expect.Call({_actionPoint.Increase(2)})
			Expect.Call(_turnOwner.Draw(1)).Return(1)
	
	[Test]
	def WorkshopTest():
		DoActionCardTest "workshop.dbc", 3:
			using _mocks.Ordered():
				Expect.Call(_predFactory.CostIsAtMost(4))
				Expect.Call(_turnOwner.GainOne(null)).IgnoreArguments().Return(null)
		
	[Test]
	def SmithyTest():
		DoActionCardTest "smithy.dbc", 4:
			Expect.Call(_turnOwner.Draw(3)).Return(3)

	[Test]
	def RemodelTest():
		cost = 0
		selected = _mocks.StrictMock[of IFloatingCard]()
		gained = _mocks.StrictMock[of IFloatingCard]()
		DoActionCardTest "remodel.dbc", 4:
			using _mocks.Ordered():
				//select hand
				Expect.Call(_turnOwner.SelectOne(_hand)).Return(selected)
				//trash 
				Expect.Call({ selected.MoveTo(_trash) })
				//gain
				SetupResult.For(selected.Card.Cost).Return(cost)
				Expect.Call(_predFactory.CostIsAtMost(cost + 2))
				Expect.Call(_turnOwner.GainOne(null)).IgnoreArguments().Return(gained)
	
	[Test]
	def MarketTest():
		DoActionCardTest("market.dbc", 5):
			Expect.Call(_turnOwner.Draw(1)).Return(1)
			Expect.Call({ _actionPoint.Increase(1) })
			Expect.Call({ _buyPoint.Increase(1) })
			Expect.Call({ _coinPoint.Increase(1) })
	
	[Test]
	def MineTest():
		cost = 3
		selected = _mocks.StrictMock[of IFloatingCard]()
		gained = _mocks.StrictMock[of IFloatingCard]()
		DoActionCardTest("mine.dbc", 5):
			using _mocks.Ordered():
				//select hand
				Expect.Call(_turnOwner.SelectOneTreasure(_hand)).Return(selected)
				//trash
				Expect.Call({ selected.MoveTo(_trash) })
				//gain
				SetupResult.For(selected.Card.Cost).Return(cost)
				Expect.Call(_predFactory.CostIsAtMost(cost + 3))
				Expect.Call(_turnOwner.GainOneTreasure(null)).IgnoreArguments().Return(gained)
		
	private def DoActionCardTest(filePath as string, cost as int, onPlayed as Action):
		card = Load(filePath) as ActionCard
		Assert.That(card, Is.Not.Null)
		Assert.That(card.Cost, Is.EqualTo(cost))
		using _mocks.Record():
			onPlayed()
		using _mocks.Playback():
			card.Play()
	
	private def Load(fileName as string) as ICard:
		cards = array[of ICard](_factory.Load("../../../TinyDominion/scripts/${fileName}"))
		assert cards.Length == 1
		return cards[0]
		
