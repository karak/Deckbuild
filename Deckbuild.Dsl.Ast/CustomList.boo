namespace Deckbuild.Dsl.Ast

import System
import System.Collections
import System.Collections.Generic

internal class CustomList[of T](IEnumerable[of T], IEquatable[of CustomList[of T]]):
	internal final _items as IList[of T]
	
	def constructor(items as T*):
		_items = List[of T](items)
		
	override def ToString() as string:
		//BUG: raise BadImageFormatException if use generator expression
		//itemStrings = x.ToString() for x in _items
		itemStrings = List[of string](_items.Count)
		for x in _items:
			itemStrings.Add(x.ToString())
		joined = String.Join(', ', itemStrings.ToArray())
		return "[${joined}]"
		
	def Equals(other as CustomList[of T]) as bool:
		//ATTENTION: don't use _items.Equals(items)
		return false if _items.Count != other._items.Count
		for i in range(0, _items.Count):
			return false if _items[i] != other._items[i]
		return true
		
	override def Equals(obj as object) as bool:
		objWithSameType = obj as CustomList[of T]
		if objWithSameType is not null:
			return self.Equals(objWithSameType)
		else:
			return false
		
	override def GetHashCode() as int:
		return _items.GetHashCode()
	
	def GetEnumerator() as IEnumerator[of T]:
		return _items.GetEnumerator()
		
	def IEnumerable.GetEnumerator() as IEnumerator:
		return cast(IEnumerable, _items).GetEnumerator()