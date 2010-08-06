using System;
using System.Collections.Generic;
using Deckbuild.Dsl.Ast;

namespace Deckbuild.Dsl
{
	public class SemanticError : Exception
	{
	}

	public class UnknownSuite : SemanticError
	{
	}
	
	public class UnknownProperty : SemanticError
	{
		private string _name;
		
		public UnknownProperty(string name)
		{
			_name = name;
		}
		
		public override string ToString()
		{
			return "unknwon property: " + _name;
		}
	}
	public interface SemanticBinder<CardT> where CardT : class
	{
		SuiteBinder<CardT> Suite(string suiteId);		
	}
	
	public interface SuiteBinder<CardT> where CardT : class
	{
		SuiteBodyBinder<CardT, ConcreteCardT> To<ConcreteCardT>(Func<string, CardT> create) where ConcreteCardT : CardT;
	}
	
	public interface SuiteBodyBinder<CardT, ConcreteCardT> where CardT : class
	{
		PropertyBinder<CardT, ConcreteCardT> Property(string propertyId);
		SemanticBinder<CardT> End();
	}
	
	public interface PropertyBinder<CardT, ConcreteCardT> where CardT : class
	{
		SuiteBodyBinder<CardT, ConcreteCardT> To(Action<ConcreteCardT, int> action);
	}
	
	internal class SemanticBinderImpl<CardT> : SemanticBinder<CardT> where CardT : class
	{
		IDictionary<string, SuiteClause> _suites = new Dictionary<string, SuiteClause>();
	
		SuiteBinder<CardT> SemanticBinder<CardT>.Suite(string suiteId)
		{
			var clause = new SuiteClause(this);
			_suites[suiteId] = clause;
			return clause;
		}
		
		public CardT Translate(CardDefinition cardDef)
		{
			try
			{
				var header = cardDef.Header;
				var suiteId = header.Suite.Id.Name;
				var suite = _suites[suiteId];
				return suite.Build(header.Id, cardDef.Properties);
			}
			catch (KeyNotFoundException)
			{
				throw new UnknownSuite();
			}
		}

		private class SuiteClause : SuiteBinder<CardT>
		{
			public SemanticBinderImpl<CardT> Parent { get; private set; }
			
			private Func<string, CardT> _create;
			
			private IDictionary<string, Action<CardT, int>> _propertyActions = new SortedDictionary<string, Action<CardT, int>>();
			
			public SuiteClause(SemanticBinderImpl<CardT> parent)
			{
				_create = null;	//TODO: assign default handler to throw exception
				Parent = parent;
			}
			
			SuiteBodyBinder<CardT, ConcreteCardT> SuiteBinder<CardT>.To<ConcreteCardT>(Func<string, CardT> create)
			{
				_create = create;
				return new SuiteBodyClause<ConcreteCardT>(this);
			}
			
			public CardT Build(Identifier id, IEnumerable<PropertyDefinition> properties)
			{
				var card = _create(id.Name);
				foreach (var propertyDef in properties)
				{
					var integral = propertyDef.Value as IntegralLiteral;
					if (integral != null)
						AssignProperty(card, propertyDef.Id.Name, integral.Value);
				}
				return card;
			}
			
			private void AssignProperty(CardT card, string propertyId, int propertyValue)
			{
				try
				{
					var action = _propertyActions[propertyId];
					action(card, propertyValue);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownProperty(propertyId);
				}
			}
			
			public void RegisterPropertyAction(string propertyId, Action<CardT, int> action)
			{
				_propertyActions[propertyId] = action;
			}
		
			private class SuiteBodyClause<ConcreteCardT> : SuiteBodyBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteClause _parent;
				
				public SuiteBodyClause(SuiteClause parent)
				{
					_parent = parent;
				}
				
				PropertyBinder<CardT, ConcreteCardT> SuiteBodyBinder<CardT, ConcreteCardT>.Property(string propertyId)
				{
					return new PropertyExpr<ConcreteCardT>(_parent, propertyId);
				}
				
				SemanticBinder<CardT> SuiteBodyBinder<CardT, ConcreteCardT>.End()
				{
					return _parent.Parent;
				}		
			}
			
			private class PropertyExpr<ConcreteCardT> : PropertyBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteClause _parent;
				string _id;
				
				public PropertyExpr(SuiteClause parent, string id)
				{
					_parent = parent;
					_id = id;
				}
				
				SuiteBodyBinder<CardT, ConcreteCardT> PropertyBinder<CardT, ConcreteCardT>.To(Action<ConcreteCardT, int> action)
				{
					_parent.RegisterPropertyAction(_id, (x, y) => action((ConcreteCardT)x, y) );
					return new SuiteBodyClause<ConcreteCardT>(_parent);
				}
			}
		}
	}
}