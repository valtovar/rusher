package rusher.data 
{
  import flash.errors.IllegalOperationError;
  
  public class InList 
  {
    /** @private */
    internal var head:InListNode = new InListNode();
    
    /** @private */
    internal var tail:InListNode = new InListNode();
    
    private var size_:int = 0;
    public function size():int { return size_; }
    
    public function InList()
    {
      head.next = tail;
      tail.prev = head;
    }
    
    public function pushBack(node:InListNode):void
    {
      if (node.list) throw new IllegalOperationError("Node already belongs to a list.");
      
      tail.prev.next = node;
      node.prev = tail.prev;
      
      tail.prev = node;
      node.next = tail;
      
      node.list = this;
      
      ++size_;
    }
    
    public function pushFront(node:InListNode):void
    {
      if (node.list) throw new IllegalOperationError("Node already belongs to a list.");
      
      head.next.prev = node;
      node.next = head.next;
      
      head.next = node;
      node.prev = head;
      
      node.list = this;
      
      ++size_;
    }
    
    public function remove(node:InListNode):void
    {
      if (node.list != this) throw new IllegalOperationError("Node does not belong to this list.");
      
      node.prev.next = node.next;
      node.next.prev = node.prev;
      
      node.next = null;
      node.prev = null;
      
      node.list = null;
      
      --size_;
    }
    
    public function getIterator():InListIterator
    {
      return new InListIterator(this);
    }
  }
}