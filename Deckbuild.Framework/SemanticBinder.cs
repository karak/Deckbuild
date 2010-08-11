using System;
using System.Collections.Generic;
using Deckbuild.Dsl.Ast;

namespace Deckbuild.Dsl
{
	public class InvalidSemanticsException : Exception
	{
	}

	public class UnknownSuiteException : InvalidSemanticsException
	{
	}
	
	public class UnknownPropertyException : InvalidSemanticsException
	{
		private string _name;
		
		public UnknownPropertyException(string name)
		{
			_name = name;
		}
		
		public override string ToString()
		{
			return "unknwon property: " + _name;
		}
	}
	public class UnknownBehaviorException : InvalidSemanticsException
	{
		private string _triggerId;
		
		public UnknownBehaviorException(string triggerId)
		{
			_triggerId = triggerId;
		}
		
		public override string ToString()
		{
			return "unknwon trigger: " + _triggerId;
		}
	}
	
	
	public interface ISemanticBinder<CardT>
	{
		ISuiteBinder<CardT> Suite(string suiteId);		
	}
	
	public interface ISuiteBinder<CardT>
	{
		ISuiteBodyBinder<CardT, ConcreteCardT> To<ConcreteCardT>(Func<string, CardT> create) where ConcreteCardT : CardT;
	}
	
	public interface ISuiteBodyBinder<CardT, ConcreteCardT>
	{
		IPropertyBinder<CardT, ConcreteCardT> Property(string propertyId);
		IBehaviorBinder<CardT, ConcreteCardT> Behavior(string id);
		ISemanticBinder<CardT> End();
	}
	
	public interface IPropertyBinder<CardT, ConcreteCardT>
	{
		ISuiteBodyBinder<CardT, ConcreteCardT> To(Action<ConcreteCardT, int> action);
	}
	
	public delegate object BehaviorCallback();
	
	public interface IBehaviorBinder<CardT, ConcreteCardT>
	{
		ISuiteBodyBinder<CardT, ConcreteCardT> To(Action<ConcreteCardT, BehaviorCallback> action);
	}
	
	internal class SemanticBinder<CardT> : ISemanticBinder<CardT>
	{
		IDictionary<string, SuiteClause> _suites = new Dictionary<string, SuiteClause>();
		
		ISuiteBinder<CardT> ISemanticBinder<CardT>.Suite(string suiteId)
		{
			var clause = new SuiteClause(this);
			_suites[suiteId] = clause;
			return clause;
		}
		
		public Func<CardDefinition, CardT> GetTransformer<GameFacadeT>(GameFacadeT game, IGlossary<GameFacadeT> glossary)
		{
			return (cardDef) => {
				try
				{
					var header = cardDef.Header;
					var suiteId = header.Suite.Id.Name;
					var suite = _suites[suiteId];
					return suite.Transform(game, glossary, header.Id, cardDef.Body);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownSuiteException();
				}
			};
		}

		private class SuiteClause : ISuiteBinder<CardT>
		{
			public SemanticBinder<CardT> Parent { get; private set; }
			
			private Func<string, CardT> _create;
			
			private IDictionary<string, Action<CardT, int>> _propertyActions = new SortedDictionary<string, Action<CardT, int>>();
			private IDictionary<string, Action<CardT, BehaviorCallback>> _behaviorActions = new SortedDictionary<string, Action<CardT, BehaviorCallback>>();
			
			public SuiteClause(SemanticBinder<CardT> parent)
			{
				_create = null;	//TODO: assign default handler to throw exception
				Parent = parent;
			}
			
			ISuiteBodyBinder<CardT, ConcreteCardT> ISuiteBinder<CardT>.To<ConcreteCardT>(Func<string, CardT> create)
			{
				_create = create;
				return new SuiteBodyClause<ConcreteCardT>(this);
			}
			
			public CardT Transform<GameFacadeT>(GameFacadeT game, IGlossary<GameFacadeT> glossary, Identifier id, CardDefinitionBody body)
			{
				var card = _create(id.Name);
				foreach (var propertyDef in body.Properties)
				{
					propertyDef.Value.Accept(
						new RValueVisitor{
							WhenIntegralLiteral = rvalue => {
								AssignProperty(card, propertyDef.Id, rvalue);
							}
						}
					);
				}
				foreach (var behaiviorDef in body.Behaviors)
				{
					//TODO: 関数化＆yieldで書き直す
					var callbackList = new List<BehaviorCallback>();
						
					foreach (var actionExpr in behaiviorDef.Actions)
					{
						actionExpr.Accept(
							new ActionExprVisitor {
								WhenUserDefinedActionExpr = userDefined => {
									callbackList.Add(TransformUserDefinedExpr(game, glossary, card, behaiviorDef.Trigger, userDefined));
								}
							}
						);
					}
					
					var trigger = behaiviorDef.Trigger;
					try
					{
						var callback = _behaviorActions[trigger.Id.Name];
						BehaviorCallback seqAction = () => {
							object lastResult = null;
							foreach (var a in callbackList)
								lastResult = a();
							return lastResult;
						};
						callback(card, seqAction);
					}
					catch (KeyNotFoundException)
					{
						throw new UnknownBehaviorException(trigger.Id.Name);
					}
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
					throw new UnknownPropertyException(propertyId.Name);
				}
			}
			
			private BehaviorCallback TransformUserDefinedExpr<GameFacadeT>(GameFacadeT game, IGlossary<GameFacadeT> glossary, CardT card, Trigger trigger, UserDefinedActionExpr actionExpr)
			{
				try
				{
					var action = _behaviorActions[trigger.Id.Name];
					var mappedOp = glossary.Operator(actionExpr.Operator.Symbol);
					NiladicFunc<GameFacadeT> mappedLhs = null;
					int integralRhs = 0;
					actionExpr.Lhs.Accept(
						new LValueVisitor {
							WhenVariable = x => mappedLhs = glossary.Variable(x.Id.Name)
						}
					);
					actionExpr.Rhs.Accept(
						new RValueVisitor {
							WhenIntegralLiteral = x => integralRhs = x.Value
						}
					);
					return () => mappedOp(game, mappedLhs(game), integralRhs);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownBehaviorException(trigger.Id.Name);
				}	
				//TODO: handle the other errors
			}
			
			public void RegisterPropertyAction(string propertyId, Action<CardT, int> action)
			{
				_propertyActions[propertyId] = action;
			}
			
			public void RegisterBehaviorAction(string behaviorId, Action<CardT, BehaviorCallback> action)
			{
				_behaviorActions[behaviorId] = action;
			}
			
		
			private class SuiteBodyClause<ConcreteCardT> : ISuiteBodyBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
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
				
				IPropertyBinder<CardT, ConcreteCardT> ISuiteBodyBinder<CardT, ConcreteCardT>.Property(string propertyId)
				{
					return new PropertyExpr<ConcreteCardT>(_parent, propertyId);
				}
				
				IBehaviorBinder<CardT, ConcreteCardT>  ISuiteBodyBinder<CardT, ConcreteCardT>.Behavior(string id)
				{
					return new BehaviorExpr<ConcreteCardT>(this, id);
				}
				
				ISemanticBinder<CardT> ISuiteBodyBinder<CardT, ConcreteCardT>.End()
				{
					return _parent.Parent;
				}		
			}
			
			private class PropertyExpr<ConcreteCardT> : IPropertyBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteClause _parent;
				string _id;
				
				public PropertyExpr(SuiteClause parent, string id)
				{
					_parent = parent;
					_id = id;
				}
				
				ISuiteBodyBinder<CardT, ConcreteCardT> IPropertyBinder<CardT, ConcreteCardT>.To(Action<ConcreteCardT, int> action)
				{
					_parent.RegisterPropertyAction(_id, (x, y) => action((ConcreteCardT)x, y));
					return new SuiteBodyClause<ConcreteCardT>(_parent);
				}
			}
			
			private class BehaviorExpr<ConcreteCardT> : IBehaviorBinder<CardT, ConcreteCardT> where ConcreteCardT : CardT
			{
				SuiteBodyClause<ConcreteCardT> _parent;
				string _id;
				
				public BehaviorExpr(SuiteBodyClause<ConcreteCardT> parent, string id)
				{
					_parent = parent;
					_id = id;
				}
				
				ISuiteBodyBinder<CardT, ConcreteCardT> IBehaviorBinder<CardT, ConcreteCardT>.To(Action<ConcreteCardT, BehaviorCallback>  action)
				{
					_parent.Parent.RegisterBehaviorAction(_id, (x, y) => action((ConcreteCardT)x, y));
					return _parent;
				}
			}
		}
	}
}