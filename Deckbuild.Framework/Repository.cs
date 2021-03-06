using System;
using System.Text;
using System.Collections.Generic;


namespace Deckbuild.Core
{
	public class IdDupulicationException : Exception
	{
		public IdDupulicationException(string typeNickName, string id)
			: base(String.Format("\"{1}\" is already registered in {0}.", typeNickName, id))
		{
		}
	}
	public class NotFoundException : Exception
	{
		public NotFoundException(string typeNickName, string id)
			: base(String.Format("\"{1}\" is not found in {0} repository", typeNickName, id))
		{
		}
	}
	
	
	internal class Repository<T>
	{
		private string _typeNickName;
		private IDictionary<string, T> _impl = new Dictionary<string, T>();
		
		public Repository(string typeNickName)
		{
			_typeNickName = typeNickName;
		}
		
		public T this[string id]
		{
			set
			{
				try {
					_impl[id] = value;
				} catch (ArgumentException) {
					throw new IdDupulicationException(_typeNickName, id);
				}
			}
			get
			{
				try {
					return _impl[id];
				} catch (KeyNotFoundException) {
					throw new NotFoundException(_typeNickName, id);
				}
			}
		}
	}
}
