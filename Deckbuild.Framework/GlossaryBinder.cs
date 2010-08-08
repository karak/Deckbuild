using System;
using Deckbuild.Core;


namespace Deckbuild.Dsl
{
	public interface IGlossaryBinder<GameT>
	{
		IGlossaryBinder<GameT> Variable(string id, NiladicFunc<GameT> variableDelegate);
		IGlossaryBinder<GameT> Method(string id, MonadicFunc<GameT> methodDelegate);
		IGlossaryBinder<GameT> Operator(string symbol, DiadicFunc<GameT> operatorDelegate);
	}

	internal class GlossaryBinder<GameT> : IGlossaryBinder<GameT>
	{
		private Glossary<GameT> _artifact = new Glossary<GameT>();
		
		IGlossaryBinder<GameT> IGlossaryBinder<GameT>.Variable(string id, NiladicFunc<GameT> variableDelegate)
		{
			_artifact.RegisteVariable(id, variableDelegate);
			return this;
		}
		IGlossaryBinder<GameT> IGlossaryBinder<GameT>.Method(string id, MonadicFunc<GameT> methodDelegate)
		{
			_artifact.RegisterMethod(id, methodDelegate);
			return this;
		}
		
		IGlossaryBinder<GameT> IGlossaryBinder<GameT>.Operator(string symbol, DiadicFunc<GameT> operatorDelegate)
		{
			_artifact.RegisterOperator(symbol, operatorDelegate);
			return this;
		}
		
		public IGlossary<GameT> Build()
		{
			IGlossary<GameT> result = _artifact;
			_artifact = null;
			return result;
		}
	}
}
