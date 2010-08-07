using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{	
	/// <summary>
	/// frontend to configure your engine.
	/// </summary>
	public class Configure<GameT, CardT>
	{
		SemanticBinderImpl<CardT> _semantics = new SemanticBinderImpl<CardT>();
		GlossaryBinderImpl<GameT> _glossary = new GlossaryBinderImpl<GameT>();
		
		public SemanticBinder<CardT> Semantics
		{
			get { return _semantics; }
		}
		
		public GlossaryBinder<GameT> Glossary
		{
			get { return _glossary; }
		}
		
		public Engine<CardT> Build(GameT gameFacade, string CardDefFileName)
		{
			var cardDefs = Parser.parseFile(CardDefFileName);
			
			var glossary = _glossary.Build();

			var transform = _semantics.GetTransformer(gameFacade, glossary);
			
			var cards = new List<CardT>();
			foreach (var c in cardDefs)
				cards.Add(transform(c));
			
			return new EngineImpl<CardT>(cards);
		}
	}

	public interface Engine<CardT>
	{
		IEnumerable<CardT> Cards { get; }
	}
	
	internal class EngineImpl<CardT> :  Engine<CardT>
	{
		IList<CardT> _cards;
		
		public EngineImpl(IEnumerable<CardT> cards)
		{
			_cards = new List<CardT>(cards);
		}
		
		IEnumerable<CardT> Engine<CardT>.Cards
		{
			get { return _cards; }
		}
	}
}
