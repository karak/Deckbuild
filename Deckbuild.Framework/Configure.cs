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
		SemanticBinder<CardT> _semantics;
		GlossaryBinder<GameT> _glossary;
		
		public Configure(Func<object> createContext)
		{
			_semantics  = new SemanticBinder<CardT>(createContext);
			_glossary = new GlossaryBinder<GameT>();
		}
		
		public ISemanticBinder<CardT> Semantics
		{
			get { return _semantics; }
		}
		
		public IGlossaryBinder<GameT> Glossary
		{
			get { return _glossary; }
		}
		
		public IEngine<CardT> Build(GameT gameFacade, string cardDefFileName)
		{
			var cardDefs = Parser.parseFile(cardDefFileName);
			
			var glossary = _glossary.Build();

			var transform = _semantics.GetTransformer(gameFacade, glossary);
			
			var cards = new List<CardT>();
			foreach (var c in cardDefs)
				cards.Add(transform(c));
			
			return new Engine<CardT>(cards);
		}
	}
}
