using System;
using System.Collections.Generic;
using Deckbuild.Dsl;

namespace Deckbuild.Framework
{
	public interface IEngine<CardT>
	{
		IEnumerable<CardT> Cards { get; }
	}
	
	internal class Engine<CardT> :  IEngine<CardT>
	{
		IList<CardT> _cards;
		
		public Engine(IEnumerable<CardT> cards)
		{
			_cards = new List<CardT>(cards);
		}
		
		IEnumerable<CardT> IEngine<CardT>.Cards
		{
			get { return _cards; }
		}
	}
}
