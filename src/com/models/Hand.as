package com.models
{
  import com.core.dataStructures.ArrayHelper;
  import com.events.CardMessage;

  import flash.events.EventDispatcher;

  public class Hand extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _cards:Array = [];
    private var _id:Number = -1;
    private var _seat:int = -1

    //
    // Constructors.
    //

    public function Hand(id:Number, seat:int) {
      _id = id;
      _seat = seat;

      register();

      dispatchCreated();
    }

    public function dispose():void {
      unregister();
    }

    //
    // Getters and setters.
    //

    public function get id():Number { return id; }
    public function get seat():int { return _seat; }
    public function get cards():Array { return _cards; }

    //
    // Public methods.
    //

    public function addCard(card:Card):void {
      _cards.push(card);

      dispatchCardAdded(card);
    }

    public function flip(cardName:String):void {
      for each(var card:Card in _cards) {
        trace(card.toString);
        if(card.toString() == "XX")
          card.flip(cardName);
      }
    }

    public override function toString():String {
      return ArrayHelper.collect(_cards, function(card:Card):String { return card.toString(); }).join(', ');
    }

    //
    // Private methods.
    //

    private function register():void {
    }

    private function unregister():void {
    }

    private function dispatchCardAdded(card:Card=null):void {
      dispatchEvent(new CardMessage(CardMessage.CARD_ADDED, { hand:this, card:card }));
    }

    private function dispatchCreated():void {
      dispatchEvent(new CardMessage(CardMessage.HAND_CREATED, { hand:this }));
    }

    //
    // Event handlers.
    //
  }
}