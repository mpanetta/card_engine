package com.models
{
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

    private var _faceUp:Boolean;
    private var _name:String;

    //
    // Constructors.
    //

    public function Card(name:String, faceUp:Boolean) {
      _faceUp = faceUp;
      _name = name;

      _count++;
    }

    public function dispose():void {
      _count--;

      unregister();
    }

    //
    // Getters and setters.
    //

    public function get imageFile():String { return _faceUp ? "card_" + _name : "b1fv"; }

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

    //
    // Event handlers.
    //
  }
}