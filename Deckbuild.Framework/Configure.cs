using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{	
	/// <summary>
	/// frontend to configure your engine.
	/// </summary>
	public class Configure<CardT>
	{
		SemanticBinder<CardT> _semantics;
		IOperatorRepository _operatorRepository;
		
		public Configure(Func<object> createContext)
		{
			_operatorRepository = new OperatorRepository();
			_semantics  = new SemanticBinder<CardT>(createContext);
		}
		
		public ISemanticBinder<CardT> Semantics
		{
			get { return _semantics; }
		}
		
		public IOperatorRepository Operators
		{
			get { return _operatorRepository; }
		}
		
		public IEngine<CardT> Build(string cardDefFileName)
		{
			var cardDefs = Parser.parseFile(cardDefFileName);
			
			var transform = _semantics.GetTransformer(_operatorRepository);
			
			var cards = new List<CardT>();
			foreach (var c in cardDefs)
				cards.Add(transform(c));
			
			return new Engine<CardT>(cards);
		}
	}
}
