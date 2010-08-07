using System;
using Deckbuild.Core;


namespace Deckbuild.Dsl
{
	public delegate object NiladicFunc<GameT>(GameT g);
	public delegate object MonadicFunc<GameT>(GameT g, object x);
	public delegate object DiadicFunc<GameT>(GameT g, object x, object y);
	
	///repository to user-defined
	public interface Glossary<GameT>
	{
		//TODO: rename Object->NiladicAction, Method->MonadicAction
		NiladicFunc<GameT> Object(string id);
		MonadicFunc<GameT> Method(string id);
		DiadicFunc<GameT>  Operator(string id);
	}
	
	internal class GlossaryImpl<GameT> : Glossary<GameT>
	{
		private Repository<NiladicFunc<GameT>> _objects = new Repository<NiladicFunc<GameT>>("object");
		
		private Repository<MonadicFunc<GameT>> _methods = new Repository<MonadicFunc<GameT>>("method");
		
		private Repository<DiadicFunc<GameT>> _operators = new Repository<DiadicFunc<GameT>>("operator");
		
		NiladicFunc<GameT> Glossary<GameT>.Object(string id)
		{
			return _objects[id];
		}
		
		public void RegisterObject(string id, NiladicFunc<GameT> obj)
		{
			_objects[id] = obj;
		}
		
		MonadicFunc<GameT> Glossary<GameT>.Method(string id)
		{
			return _methods[id];
		}
		
		public void RegisterMethod(string id, MonadicFunc<GameT> method)
		{
			_methods[id] = method;
		}
		
		DiadicFunc<GameT> Glossary<GameT>.Operator(string symbol)
		{
			return _operators[symbol];
		}
		
		public void RegisterOperator(string symbol, DiadicFunc<GameT> op)
		{
			_operators[symbol] = op;
		}
		
		//TODO: use Ast-attribute to define each Accesser
	}
	
	public interface GlossaryBinder<GameT>
	{
		GlossaryBinder<GameT> Object(string id, NiladicFunc<GameT> obj);
		GlossaryBinder<GameT> Method(string id, MonadicFunc<GameT> method);
		GlossaryBinder<GameT> Operator(string symbol, DiadicFunc<GameT> op);
	}

	internal class GlossaryBinderImpl<GameT> : GlossaryBinder<GameT>
	{
		private GlossaryImpl<GameT> _artifact = new GlossaryImpl<GameT>();
		
		GlossaryBinder<GameT> GlossaryBinder<GameT>.Object(string id, NiladicFunc<GameT> obj)
		{
			_artifact.RegisterObject(id, obj);
			return this;
		}
		GlossaryBinder<GameT> GlossaryBinder<GameT>.Method(string id, MonadicFunc<GameT> method)
		{
			_artifact.RegisterMethod(id, method);
			return this;
		}
		
		GlossaryBinder<GameT> GlossaryBinder<GameT>.Operator(string symbol, DiadicFunc<GameT> op)
		{
			_artifact.RegisterOperator(symbol, op);
			return this;
		}
		
		public Glossary<GameT> Build()
		{
			Glossary<GameT> result = _artifact;
			_artifact = null;
			return result;
		}
	}
}
