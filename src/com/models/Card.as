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

    private var _faceUp:Boolean;
    private var _name:String;
    private var _id:Number;
    private var _face:String;
    private var _suit:String;
    private var _raised:Boolean = false;
    private var _value:int;
    private var _enabled:Boolean = true;

    //
    // Constructors.
    //

    public function Card(name:String, faceUp:Boolean, id:Number, face:String=null, suit:String=null, value:int=-1) {
      _faceUp = faceUp;
      _name = name;
      _id = id;

      _face = face;
      _suit = suit;
      _value = value;
    }

    public function dispose():void {
      unregister();
    }

    //
    // Getters and setters.
    //

    public function get imageFile():String { return "247_" + (_faceUp ? fullSuit + "_" + face.toUpperCase() : "CardBack_III_Blank"); }
    public function get id():Number { return _id; }
    public function get face():String { return _face; }
    public function get suit():String { return _suit; }
    public function get value():int { return _value; }
    public function get faceUp():Boolean { return _faceUp; }
    public function get name():String { return _name; }

    public function set enabled(val:Boolean):void { _enabled = val; dispatchEnabledChanged(); }
    public function get enabled():Boolean { return _enabled; }

    private function get fullSuit():String {
      switch(_suit) {
        case "c":
          return "Clubs";
          break;
        case "d":
          return "Diamonds";
          break;
        case "h":
          return "Hearts";
          break;
        case "s":
          return "Spades";
          break;
        default:
          throw new CardError(CardError.UNKOWN_STANDARD_SUIT, _suit);
      }
    }

    //
    // Public methods.
    //

    public override function toString():String {
      return _name;
      return _faceUp ? _name : "XX";
    }

    public function flip(name:String=null):void {
      _faceUp = _faceUp ? false : true;
      if(name)
        _name = name;

      dispatchEvent(new CardMessage(CardMessage.CARD_FLIPPED, {}));
    }

    public function raise():void {
      if(_raised) return;

      _raised = true;
      dispatchEvent(new CardMessage(CardMessage.CARD_RAISED, {}));
    }

    public function lower():void {
      if(!_raised) return;

      _raised = false;
      dispatchEvent(new CardMessage(CardMessage.CARD_LOWERED, {}));
    }

    private function dispatchEnabledChanged():void {
      dispatchEvent(new CardMessage(CardMessage.ENABLED_CHANGED, { enabled:_enabled }));
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