using System;
using System.Reflection;


namespace Deckbuild.Core
{
	/// <summary>
	/// C# Duck type adapter by reflection API
	/// </summary>
	/// <remarks>this class is inspired by duck typing implementation in Boo.</remarks>
	public class Duck
	{
		private object _wrapped;
		
		public Duck(object wrapped)
		{
			_wrapped = wrapped;
		}
		
		public MethodProxy Method(string name)
		{
			return new MethodProxyImpl(_wrapped, name);
		}
		
		public PropertyProxy Property(string name)
		{
			return new PropertyProxyImpl(_wrapped, name);
		}
		
		public object Wrapped
		{
			get { return _wrapped; }
		}
		
		public interface MethodProxy
		{
			object Invoke(params object[] args);
		}
		
		public interface PropertyProxy
		{
			object Get();
			
			void Set(object value);
		}
		
		private abstract class MemberProxy
		{
			private string _name;
			private object _wrapped;
			
			protected const BindingFlags DefaultBF = BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.FlattenHierarchy;
			
			protected MemberProxy(object wrapped, string name)
			{
				_wrapped = wrapped;
				_name = name;
			}
			
			protected object InvokeMember(BindingFlags flags, object[] args)
			{
				try
				{
					return _wrapped.GetType().InvokeMember(_name, flags, null, _wrapped, args);
				}
				catch (MissingMemberException e)
				{
					//TODO: use special exception
					throw new Exception(e.ToString(), e);
				}
			}
		}
		
		private class MethodProxyImpl : MemberProxy, MethodProxy
		{
			const BindingFlags InvokeBF = DefaultBF | BindingFlags.InvokeMethod;
			
			public MethodProxyImpl(object wrapped, string name) : base(wrapped, name)
			{
			}
			
			object MethodProxy.Invoke(params object[] args)
			{
				return InvokeMember(InvokeBF, args);
			}
		}
		
		private class PropertyProxyImpl : MemberProxy, PropertyProxy
		{
			static readonly object[] EmptyArray = new object[0];
			
			const BindingFlags GetPropertyBF = DefaultBF | BindingFlags.GetProperty | BindingFlags.GetField;
			
			const BindingFlags SetPropertyBF = DefaultBF | BindingFlags.SetProperty | BindingFlags.SetField;
			
			public PropertyProxyImpl(object wrapped, string name) : base(wrapped, name)
			{
			}
			
			object PropertyProxy.Get()
			{
				return InvokeMember(GetPropertyBF, EmptyArray);
			}
			
			void PropertyProxy.Set(object value)
			{
				InvokeMember(SetPropertyBF, new object[]{ value });
			}
		}
	}

}