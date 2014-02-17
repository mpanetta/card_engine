package com.models
{
  import com.core.dataStructures.Hash;
  import com.events.CardMessage;

  import flash.events.EventDispatcher;

  public class Table extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _hands:Hash = new Hash();

    //
    // Constructors.
    //

    public function Table() {
      register();
    }

    public function dispose():void {
      unregister();
    }

    //
    // Getters and setters.
    //

    //
    // Public methods.
    //

    public function deal(id:Number, suit:String, face:String, seat:int, faceUp:Boolean, cardId:Number):void {
      var hand:Hand = getHand(id, seat);

      hand.addCard(new Card(face + suit, faceUp, cardId, face, suit));
    }

    public function sort(handId:Number, seat:int, sortedCards:Array, animate:Boolean):void {
      var hand:Hand = getHand(handId, seat);

      hand.sort(sortedCards, animate);
    }

    public function flip(seat:Number, cardName:String, cardId:Number):void {
      var hand:Hand = _hands[seat];
      hand.flip(cardId, cardName);
    }

    public function raise(seat:Number, cardId:Number):void {
      var hand:Hand = _hands[seat];
      hand.raise(cardId);
    }

    public function lower(seat:Number, cardId:Number):void {
      var hand:Hand = _hands[seat];
      hand.lower(cardId);
    }

    public function removeCard(seat:Number, cardId:Number):void {
      var hand:Hand = _hands[seat];
      hand.removeCard(cardId);
    }

    public function hideHand(seat:Number, value:Boolean):void {
      var hand:Hand = _hands[seat];
      if(hand) hand.hide(value);
    }

    public function changeEnabled(handId:Number, cardId:Number, enabled:Boolean):void {
      var hand:Hand = _hands[handId];
      hand.changeEnabled(cardId, enabled);
    }

    //
    // Private methods.
    //

    private function register():void {

    }

    private function unregister():void {

    }

    private function getHand(id:Number, seat:int):Hand {
      if(_hands[seat]) {
        return _hands[seat]
      } else {
        return createHand(id, seat);
      }
    }

    private function createHand(id:Number, seat:int):Hand {
      var hand:Hand = new Hand(id, seat);
      _hands[seat] = hand;

      dispatchHandCreated(hand);

      return hand
    }

    private function dispatchDispose():void {
      dispatchEvent(new CardMessage(CardMessage.TABLE_DISPOSED, { table:this }));
    }

    private function dispatchHandCreated(hand:Hand):void {
      dispatchEvent(new CardMessage(CardMessage.HAND_CREATED, { hand:hand }));
    }

    //
    // Event handlers.
    //
  }
}