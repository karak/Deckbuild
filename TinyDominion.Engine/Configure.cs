using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{
	/// <summary>
	/// frontend to configure your engine.
	/// </summary>
	public class Configure<CardT> where CardT : class
	{
		SemanticBinderImpl<CardT> _semantics = new SemanticBinderImpl<CardT>();
			
		public SemanticBinder<CardT> Semantics
		{
			get { return _semantics; }
		}
		
		public Engine<CardT> Build(string CardDefFileName)
		{
			var cardDefs = Parser.parseFile(CardDefFileName);
			var cards = new List<CardT>();
			foreach (var c in cardDefs)
				cards.Add(_semantics.Translate(c));
			
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
