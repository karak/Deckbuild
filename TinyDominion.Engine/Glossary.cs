using System;

namespace Deckbuild.Dsl
{
	///repository to user-defined
	public interface Glossary
	{
		//TODO: rename Object->NiladicAction, Method->MonadicAction
		object Object(string id);
		Action<object> Method(string id);
	}
}
