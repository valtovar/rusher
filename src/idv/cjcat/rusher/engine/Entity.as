package idv.cjcat.rusher.engine 
{
  import flash.utils.Dictionary;
  import idv.cjcat.rusher.utils.construct;
  import org.swiftsuspenders.Injector;
	
  public class Entity extends RusherObject
  {
    private var name_:String;
    public function getName():String { return name_; }
    
    private var parent_:Entity = null;
    public function getParent():Entity { return parent_; }
    
    private var components_:Dictionary = new Dictionary();
    private var children_:Dictionary = new Dictionary();
    
    public function getComponent(ComponentClass:Class):*
    {
      return IComponent(getInstance(ComponentClass));
    }
    
    public function Entity(name:String)
    {
      name_ = name;
    }
    
    public function addComponent(ComponentClass:Class, ...params):*
    {
      var injector:Injector = getInjector();
      
      //check component existence
      if (injector.satisfies(ComponentClass)) throw new Error("Component " + ComponentClass + " already added.");
      
      //add component to entity
      var component:IComponent  = construct(ComponentClass, params);
      
      //map to entity's and engine's injectors
      injector.map(ComponentClass).toValue(component);
      injector.parentInjector.map(ComponentClass, getName()).toValue(component);
      
      //intialize component
      component.setInjector(getInjector());
      components_[ComponentClass] = component;
      
      getInjector().injectInto(component);
      component.onAdded();
      
      return component;
    }
    
    public function removeComponent(ComponentClass:Class):void
    {
      var injector:Injector = getInjector();
      
      //check component existence
      if (!injector.satisfies(ComponentClass)) throw new Error("Component " + ComponentClass + " not found.");
      
      var component:IComponent = getComponent(ComponentClass);
      
      //remove component from entity
      component.onRemoved();
      component.setInjector(null);
      delete components_[ComponentClass];
    }
    
    public function getChild(name:Entity):Entity
    {
      if (!children_[name]) throw new Error("Child entity named \"" + name + "\" not found.");
      return children_[name];
    }
    
    public function mount(child:Entity):Entity
    {
      if (children_[child.name_]) throw new Error("Entity named \"" + child.name_ + "\" already mounted.");
      if (child.parent_) throw new Error("Entity named \"" + child.name_ + "\" already mounted onto parent named \"" + child.parent_.name_ + "\"");
      
      //establish parent-child relation
      children_[child.name_] = child;
      child.parent_ = this;
      
      return child;
    }
    
    public function unmount(child:Entity):Entity
    {
      if (!children_[child.name_]) throw new Error("Child entity named \"" + child.name_ + "\" not found.");
      
      //remove parent-child relation
      delete children_[child.name_];
      child.parent_ = null;
      
      return child;
    }
    
    public function destroy():void
    {
      //destroy all children first
      for (var key:* in children_)
      {
        getInstance(Engine).destroyEntity(key);
        delete children_[key];
      }
      
      //and then destroy this entity itself
      getInstance(Engine).destroyEntity(getName());
    }
    
    /** @private */
    internal function dispose():void
    {
      for (var ComponentClass:* in components_)
      {
        removeComponent(ComponentClass);
      }
    }
  }
}
