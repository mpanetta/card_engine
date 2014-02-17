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
    private var _order:Array = [];
    private var _hidden:Boolean = false;

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
    public function get cards():Array { return ArrayHelper.collect(_order, function(id:Number):Card { return _cards[id]; }); }
    public function get order():Array { return _order; }
    public function get hidden():Boolean { return _hidden; }

    //
    // Public methods.
    //

    public function addCard(card:Card):void {
      if(_cards[card.id])
        throw new CardError(CardError.MULTIPLE_ID, "");

      _cards[card.id] = card;
      _order.push(card.id);

      dispatchCardAdded(card);
    }

    public function removeCard(cardId:Number):void {
      if(!_cards[cardId])
        throw new CardError(CardError.NO_ID, cardId.toString());

      delete _cards[cardId];

      _order.splice(order.indexOf(cardId), 1);

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

    public function sort(sortedCards:Array, animate:Boolean):void {
      _order = ArrayHelper.collect(sortedCards, 'id');

      dispatchHandSorted(sortedCards, animate);
    }

    public function hide(value:Boolean):void {
      _hidden = value;

      dispatchHide();
    }

    public function changeEnabled(cardId:Number, enabled:Boolean):void {
      var card:Card = _cards[cardId];
      card.enabled = enabled;
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

    private function dispatchHandSorted(sortedCards:Array, animate:Boolean):void {
      dispatchEvent(new CardMessage(CardMessage.HAND_SORTED, { sortedCards:sortedCards, animate:Boolean }));
    }

    private function dispatchHide():void {
      dispatchEvent(new CardMessage(CardMessage.HAND_HIDE, {}));
    }

    //
    // Event handlers.
    //
  }
}