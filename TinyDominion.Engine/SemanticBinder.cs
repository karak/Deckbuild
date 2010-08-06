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
	public class UnknownBehavior : SemanticError
	{
		private string _triggerId;
		
		public UnknownBehavior(string triggerId)
		{
			_triggerId = triggerId;
		}
		
		public override string ToString()
		{
			return "unknwon trigger: " + _triggerId;
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
		BehaviorBinder<CardT, ConcreteCardT> Behavior(string id);
		SemanticBinder<CardT> End();
	}
	
	public interface PropertyBinder<CardT, ConcreteCardT> where CardT : class
	{
		SuiteBodyBinder<CardT, ConcreteCardT> To(Action<ConcreteCardT, int> action);
	}
	
	public interface BehaviorBinder<CardT, ConcreteCardT> where CardT : class
	{
		SuiteBodyBinder<CardT, ConcreteCardT> To(Action<ConcreteCardT, Action> action);
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
		
		public Func<CardDefinition, CardT> GetTransformer(Glossary glossary)
		{
			return (cardDef) => {
				try
				{
					var header = cardDef.Header;
					var suiteId = header.Suite.Id.Name;
					var suite = _suites[suiteId];
					return suite.Transform(glossary, header.Id, cardDef.Body);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownSuite();
				}
			};
		}

		private class SuiteClause : SuiteBinder<CardT>
		{
			public SemanticBinderImpl<CardT> Parent { get; private set; }
			
			private Func<string, CardT> _create;
			
			private IDictionary<string, Action<CardT, int>> _propertyActions = new SortedDictionary<string, Action<CardT, int>>();
			private IDictionary<string, Action<CardT, Action>> _behaviorActions = new SortedDictionary<string, Action<CardT, Action>>();
			
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
			
			
			public CardT Transform(Glossary glossary, Identifier id, CardDefinitionBody body)
			{
				var card = _create(id.Name);
				foreach (var propertyDef in body.Properties)
				{
					propertyDef.Value.Accept(
						new RValueVisitorImpl{
							WhenIntegralLiteral = rvalue => {
								AssignProperty(card, propertyDef.Id, rvalue);
							}
						}
					);
				}
				foreach (var behaiviorDef in body.Behaviors)
				{
					behaiviorDef.Action.Accept(new ActionExprVisitorImpl {
							WhenApplyOp = applyOp => {
								applyOp.LValue.Accept(new LValueVisitorImpl {
									WhenObject = obj => {
										AssignApplyOp(glossary, card, behaiviorDef.Trigger, obj, applyOp.Method);
									}
								});
					}});
				}
				return card;
			}
			
			private void AssignProperty(CardT card, Identifier propertyId, IntegralLiteral rvalue)
			{
				try
				{
					var action = _propertyActions[propertyId.Name];
					action(card, rvalue.Value);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownProperty(propertyId.Name);
				}
			}
			
			private void AssignApplyOp(Glossary glossary, CardT card, Trigger trigger, Deckbuild.Dsl.Ast.Object obj, Method method)
			{
				try
				{
					var action = _behaviorActions[trigger.Id.Name];
					var mappedObj = glossary.Object(obj.Id.Name);
					var mappedMethod = glossary.Method(method.Id.Name);
					action(card, () => mappedMethod(mappedObj));
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownBehavior(trigger.Id.Name);
				}
			}
			
			public void RegisterPropertyAction(string propertyId, Action<CardT, int> action)
			{
				_propertyActions[propertyId] = action;
			}
			
			public void RegisterBehaviorAction(string behaviorId, Action<CardT, Action> action)
			{
				_behaviorActions[behaviorId] = action;
			}
			
		
			private class SuiteBodyClause<ConcreteCardT> : SuiteBodyBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteClause _parent;
				
				public SuiteBodyClause(SuiteClause parent)
				{
					_parent = parent;
				}
				
				public SuiteClause Parent
				{
					get { return _parent; }
				}
				
				PropertyBinder<CardT, ConcreteCardT> SuiteBodyBinder<CardT, ConcreteCardT>.Property(string propertyId)
				{
					return new PropertyExpr<ConcreteCardT>(_parent, propertyId);
				}
				
				BehaviorBinder<CardT, ConcreteCardT>  SuiteBodyBinder<CardT, ConcreteCardT>.Behavior(string id)
				{
					return new BehaviorExpr<ConcreteCardT>(this, id);
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
					_parent.RegisterPropertyAction(_id, (x, y) => action((ConcreteCardT)x, y));
					return new SuiteBodyClause<ConcreteCardT>(_parent);
				}
			}
			
			private class BehaviorExpr<ConcreteCardT> : BehaviorBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteBodyClause<ConcreteCardT> _parent;
				string _id;
				
				public BehaviorExpr(SuiteBodyClause<ConcreteCardT> parent, string id)
				{
					_parent = parent;
					_id = id;
				}
				
				SuiteBodyBinder<CardT, ConcreteCardT> BehaviorBinder<CardT, ConcreteCardT>.To(Action<ConcreteCardT, Action>  action)
				{
					_parent.Parent.RegisterBehaviorAction(_id, (x, y) => action((ConcreteCardT)x, y));
					return _parent;
				}
			}
		}
	}
}