using System;
using Deckbuild.Core;


namespace Deckbuild.Dsl
{
	///repository to user-defined operator
	public interface IOperatorRepository
	{
		Func<object, object, object> this[string symbol] { get; set; }
	}
	
	internal class OperatorRepository : IOperatorRepository
	{
		private Repository<Func<object, object, object>> _operators = new Repository<Func<object, object, object>>("operator");
		
		public Func<object, object, object> this[string symbol]
		{
			get
			{
				return _operators[symbol];
			}
			set
			{
				//TODO: syntax test by Parser module
				_operators[symbol] = value;
			}
		}
	}
}
