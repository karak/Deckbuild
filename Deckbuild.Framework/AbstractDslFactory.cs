using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{	
	/// <summary>
	/// frontend to configure your engine.
	/// </summary>
	public abstract class AbstractDslFactory<CardT>
	{
		private SemanticBinder<CardT> _semantics;
		private OperatorRepository _operatorRepository;
		
		protected AbstractDslFactory(Func<IFunctionContext> createContext)
		{
			_operatorRepository = new OperatorRepository();
			_semantics  = new SemanticBinder<CardT>(createContext);
			Configure(_semantics, _operatorRepository);
		}
		
		protected abstract void Configure(ISemanticBinder<CardT> semantics, IOperatorRepository operators);
		
		public IEnumerable<CardT> Load(string cardDefFileName)
		{
			var cardDefs = Parser.parseFile(cardDefFileName);
			
			var transform = _semantics.GetTransformer(_operatorRepository);
			
			foreach (var c in cardDefs)
				yield return transform(c);
		}
	}
}
