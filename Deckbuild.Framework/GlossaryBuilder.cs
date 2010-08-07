using System;
using Deckbuild.Core;


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
	
	internal class GlossaryImpl<GameT> : Glossary<GameT>
	{
		private Repository<NiladicFunc<GameT>> _objects = new Repository<NiladicFunc<GameT>>("object");
		
		private Repository<MonadicFunc<GameT>> _methods = new Repository<MonadicFunc<GameT>>("method");
		
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
	}
	
	public interface GlossaryBinder<GameT>
	{
		GlossaryBinder<GameT> Object(string id, NiladicFunc<GameT> obj);
		GlossaryBinder<GameT> Method(string id, MonadicFunc<GameT> method);
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
		
		public Glossary<GameT> Build()
		{
			Glossary<GameT> result = _artifact;
			_artifact = null;
			return result;
		}
	}
}
