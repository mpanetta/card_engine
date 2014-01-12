package com.models
{
  import com.core.dataStructures.ArrayHelper;
  import com.core.dataStructures.Hash;
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

    private var _cards:Hash = new Hash();
    private var _id:Number = -1;
    private var _seat:int = -1;

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
      _cards.clear();

      unregister();
    }

    //
    // Getters and setters.
    //

    public function get id():Number { return _id; }
    public function get seat():int { return _seat; }
    public function get cards():Array { return _cards.values; }

    //
    // Public methods.
    //

    public function addCard(card:Card):void {
      if(_cards[card.id])
        throw new CardError(CardError.MULTIPLE_ID, "");

      _cards[card.id] = card;

      dispatchCardAdded(card);
    }

    public function removeCard(cardId:Number):void {
      if(!_cards[cardId])
        throw new CardError(CardError.NO_ID, cardId.toString());

      delete _cards[cardId];

      dispatchCardRemoved(cardId);
    }

    public function flip(cardId:Number, cardName:String):void {
      _cards[cardId].flip(cardName);
    }

    public function raise(cardId:Number):void {
      _cards[cardId].raise();
    }

    public function lower(cardId:Number):void {
      _cards[cardId].lower();
    }

    public override function toString():String {
      return ArrayHelper.collect(cards, function(card:Card):String { return card.toString(); }).join(', ');
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

    private function dispatchCardRemoved(cardId:Number):void {
      dispatchEvent(new CardMessage(CardMessage.CARD_REMOVED, { handId:id, cardId:cardId }));
    }

    private function dispatchCreated():void {
      dispatchEvent(new CardMessage(CardMessage.HAND_CREATED, { hand:this }));
    }

    //
    // Event handlers.
    //
  }
}