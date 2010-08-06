using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{
	class StubGlossary : Glossary
	{
		object Glossary.Object(string id)
		{
			return null;
		}
		
		Action<object> Glossary.Method(string id)
		{
			return DoNothing;
		}
		
		private void DoNothing(object o)
		{
		}
	}
	
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

			Glossary glossary = new StubGlossary();	//TODO: impl
			var transform = _semantics.GetTransformer(glossary);
			
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
