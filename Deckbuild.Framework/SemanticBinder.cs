using System;
using System.Collections.Generic;
using Deckbuild.Core;
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
		Func<Duck> _createContext;
		
		public SemanticBinder(Func<object> createContext)
		{
			_createContext = () => {
				var context = createContext();
				return new Duck(context);//convert to duck
			};
		}
		
		ISuiteBinder<CardT> ISemanticBinder<CardT>.Suite(string suiteId)
		{
			var clause = new SuiteClause(this, _createContext);
			_suites[suiteId] = clause;
			return clause;
		}
		
		public Func<CardDefinition, CardT> GetTransformer(IOperatorRepository operatorRepository)
		{
			return (cardDef) => {
				try
				{
					var header = cardDef.Header;
					var suiteId = header.Suite.Id.Name;
					var suite = _suites[suiteId];
					return suite.Transform(operatorRepository, header.Id, cardDef.Body);
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
			private Func<Duck> _createContext;
			
			public SuiteClause(SemanticBinder<CardT> parent, Func<Duck> createContext)
			{
				_create = null;	//TODO: assign default handler to throw exception
				Parent = parent;
				_createContext = createContext;
			}
			
			ISuiteBodyBinder<CardT, ConcreteCardT> ISuiteBinder<CardT>.To<ConcreteCardT>(Func<string, CardT> create)
			{
				_create = create;
				return new SuiteBodyClause<ConcreteCardT>(this);
			}
			
			public CardT Transform(IOperatorRepository operatorRepository, Identifier id, CardDefinitionBody body)
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
								WhenFunctionCallSequence = functionCallSeq => {
									callbackList.Add(TransformFunctionCallSequence(behaiviorDef.Trigger, functionCallSeq));
								},
								WhenUserDefinedActionExpr = userDefined => {
									callbackList.Add(TransformUserDefinedExpr(operatorRepository, card, behaiviorDef.Trigger, userDefined));
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
			
			private System.Func<Duck, object> TransformFunctionCall(FunctionCall f)
			{
				var mappedArgs = new List<System.Func<Duck, object>>();
				foreach (var arg in f.Args)
				{
					System.Func<Duck, object> mappedArg = null;
					arg.Accept(
						new ActionParameterVisitor{
							WhenIntegralLiteral = parameter => mappedArg = context => parameter.Value,
							WhenFunctionCall = innerF => mappedArg = TransformFunctionCall(innerF)
						}
					);
					mappedArgs.Add(mappedArg);
				}
				if (mappedArgs.Count != 0)
				{
					return context => {
						var args = new object[mappedArgs.Count];
						for (int i = 0; i < mappedArgs.Count; ++i)
							args[i] = mappedArgs[i](context);
						return context.Method(f.Id.Name).Invoke(args);
					};
				}
				else
				{
					return context => {
						return context.Property(f.Id.Name).Get();
					};
				}
			}
			
			private BehaviorCallback TransformFunctionCallSequence(Trigger trigger, FunctionCallSequence actionExpr)
			{
				var fs = new List<System.Func<Duck, object>>();
				foreach (var f in actionExpr.FunctionCalls)
				{
					fs.Add(TransformFunctionCall(f));
				}
				return () => {
					object retval = null;
					var context = _createContext();
					foreach (var f in fs)
					{
						retval = f(context);
						context.Property("It").Set(retval);
					}
					return retval;
				};
			}
			
			private BehaviorCallback TransformUserDefinedExpr(IOperatorRepository operatorRepository, CardT card, Trigger trigger, UserDefinedActionExpr actionExpr)
			{
				var mappedOp = operatorRepository[actionExpr.Operator.Symbol];
				//TODO: error handling
				System.Func<Duck, object> mapLhs = null;
				int integralRhs = 0;
				actionExpr.Lhs.Accept(
					new LValueVisitor {
						WhenFunctionCall = f => mapLhs = TransformFunctionCall(f)
					}
				);
				actionExpr.Rhs.Accept(
					new RValueVisitor {
						WhenIntegralLiteral = x => integralRhs = x.Value
					}
				);
				return () => {
					var context = _createContext();
					var mappedLhs = mapLhs(context);
					return mappedOp(mappedLhs, integralRhs);
				};
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