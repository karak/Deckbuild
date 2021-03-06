using System;
using System.Collections.Generic;
using Deckbuild.Core;
using Deckbuild.Dsl.Ast;

namespace Deckbuild.Dsl
{
	public class InvalidSemanticsException : Exception
	{
		public InvalidSemanticsException()
		{
		}
		
		public InvalidSemanticsException(string message) : base(message)
		{
		}
		
		public InvalidSemanticsException(string message, Exception innerException) : base(message, innerException)
		{
		}
	}

	public class UnknownSuiteException : InvalidSemanticsException
	{
		public UnknownSuiteException(string suiteId) : base("\"" + suiteId + "\" is not binded")
		{
		}
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
	
	public interface IFunctionContext
	{
		/// <summary>
		/// last function resturn value
		/// </summary>
		object It { set; }
	}
	
	public interface ISemanticBinder<CardT>
	{
		ISuiteBinder<CardT> Suite(string suiteId);		
	}
	
	public interface ISuiteBinder<CardT>
	{
		Func<string, CardT> Callback { set; }
	}
	
	internal class SemanticBinder<CardT> : ISemanticBinder<CardT>
	{
		IDictionary<string, SuiteClause> _suites = new Dictionary<string, SuiteClause>();
		Func<Duck> _createContext;
		
		public SemanticBinder(Func<IFunctionContext> createContext)
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
				var header = cardDef.Header;
				var suiteId = header.Suite.Id.Name;
				try
				{
					var suite = _suites[suiteId];
					return suite.Transform(operatorRepository, header.Id, cardDef.Body);
				}
				catch (KeyNotFoundException)
				{
					throw new UnknownSuiteException(suiteId);
				}
			};
		}

		private class SuiteClause : ISuiteBinder<CardT>
		{
			public SemanticBinder<CardT> Parent { get; private set; }
			
			private Func<string, CardT> _createCard;
			
			private Func<Duck> _createContext;
			
			public SuiteClause(SemanticBinder<CardT> parent, Func<Duck> createContext)
			{
				_createCard = null;	//TODO: assign default handler to throw exception
				Parent = parent;
				_createContext = createContext;
			}
			
			Func<string, CardT> ISuiteBinder<CardT>.Callback
			{
				set
				{
					_createCard = value;
				}
			}
			
			public CardT Transform(IOperatorRepository operatorRepository, Identifier id, CardDefinitionBody body)
			{
				var card = _createCard(id.Name);
				var duckyCard = new Duck(card);
				foreach (var propertyDef in body.Properties)
				{
					propertyDef.Value.Accept(
						new RValueVisitor{
							WhenIntegralLiteral = rvalue => {
								duckyCard.Property(propertyDef.Id.Name).Set(rvalue.Value);
							}
						}
					);
				}
				foreach (var behaiviorDef in body.Behaviors)
				{
					//TODO: 関数化＆yieldで書き直す
					var callbackList = new List<System.Func<object>>();
						
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
						System.Func<object> seqAction = () => {
							object lastResult = null;
							foreach (var a in callbackList)
								lastResult = a();
							return lastResult;
						};
						duckyCard.Property(trigger.Id.Name).Set(seqAction);
					}
					catch (KeyNotFoundException)
					{
						throw new UnknownBehaviorException(trigger.Id.Name);
					}
				}
				return card;
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
			
			private System.Func<object> TransformFunctionCallSequence(Trigger trigger, FunctionCallSequence actionExpr)
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
						((IFunctionContext)context.Wrapped).It = retval;
					}
					return retval;
				};
			}
			
			private System.Func<object> TransformUserDefinedExpr(IOperatorRepository operatorRepository, CardT card, Trigger trigger, UserDefinedActionExpr actionExpr)
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
		}
	}
}