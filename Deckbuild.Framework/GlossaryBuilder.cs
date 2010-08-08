using System;
using Deckbuild.Core;


namespace Deckbuild.Dsl
{
	public delegate object NiladicFunc<GameT>(GameT g);
	public delegate object MonadicFunc<GameT>(GameT g, object x);
	public delegate object DiadicFunc<GameT>(GameT g, object x, object y);
	
	///repository to user-defined
	public interface IGlossary<GameT>
	{
		NiladicFunc<GameT> Variable(string id);
		MonadicFunc<GameT> Method(string id);
		DiadicFunc<GameT>  Operator(string id);
	}
	
	internal class Glossary<GameT> : IGlossary<GameT>
	{
		private Repository<NiladicFunc<GameT>> _variables = new Repository<NiladicFunc<GameT>>("variable");
		
		private Repository<MonadicFunc<GameT>> _methods = new Repository<MonadicFunc<GameT>>("method");
		
		private Repository<DiadicFunc<GameT>> _operators = new Repository<DiadicFunc<GameT>>("operator");
		
		NiladicFunc<GameT> IGlossary<GameT>.Variable(string id)
		{
			return _variables[id];
		}
		
		public void RegisteVariable(string id, NiladicFunc<GameT> variable)
		{
			_variables[id] = variable;
		}
		
		MonadicFunc<GameT> IGlossary<GameT>.Method(string id)
		{
			return _methods[id];
		}
		
		public void RegisterMethod(string id, MonadicFunc<GameT> method)
		{
			_methods[id] = method;
		}
		
		DiadicFunc<GameT> IGlossary<GameT>.Operator(string symbol)
		{
			return _operators[symbol];
		}
		
		public void RegisterOperator(string symbol, DiadicFunc<GameT> op)
		{
			_operators[symbol] = op;
		}
		
		//TODO: use Ast-attribute to define each Accesser
	}
	
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
