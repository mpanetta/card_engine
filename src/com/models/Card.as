package com.models
{
  import com.core.dataStructures.ArrayHelper;
  import com.core.dataStructures.Hash;
  import com.events.CardMessage;

  import flash.events.EventDispatcher;

  public class Card extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private static var _count:int = 0;
    private static var _nextId:Number = 0;
    private static var _cardsById:Hash = new Hash();

    private var _faceUp:Boolean;
    private var _name:String;
    private var _id:Number;

    //
    // Constructors.
    //

    public function Card(name:String, faceUp:Boolean, id:Number=-1) {
      _faceUp = faceUp;
      _name = name;

      setId(id);

      _count++;
    }

    public function dispose():void {
      _count--;
      delete _cardsById[_id];

      unregister();
    }

    //
    // Getters and setters.
    //

    public function get imageFile():String { return _faceUp ? "card_" + _name : "b1fv"; }
    public function get id():Number { return _id; }

    //
    // Public methods.
    //

    public override function toString():String {
      return _faceUp ? _name : "XX";
    }

    public function flip(name:String):void {
      _faceUp = _faceUp ? false : true;
      if(name)
        _name = name;

      dispatchEvent(new CardMessage(CardMessage.CARD_FLIPPED, {}));
    }

    //
    // Private methods.
    //

    private function register():void {

    }

    private function unregister():void {

    }

    private function setId(newId):void {
      if(newId != -1 && _cardsById[newId] != null)
        throw new CardError(CardError.MULTIPLE_ID, " id: " + newId);

      _id = newId == -1 ? incrementCount() : newId;
      _cardsById[newId] = this;
    }

    private function incrementCount():Number {
      var numbers:Array = _cardsById.keys;
      while(ArrayHelper.includes(numbers, _nextId)) {
        _nextId++;
      }

      return _nextId;
    }

    //
    // Event handlers.
    //
  }
}