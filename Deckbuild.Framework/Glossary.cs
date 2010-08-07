using System;

namespace Deckbuild.Dsl
{
	public delegate object NiladicFunc<GameT>(GameT g);
	public delegate object MonadicFunc<GameT>(GameT g, object x);
	
	///repository to user-defined
	public interface Glossary<GameT>
	{
		//TODO: rename Object->NiladicAction, Method->MonadicAction
		NiladicFunc<GameT> Object(string id);
		MonadicFunc<GameT> Method(string id);
	}
}
