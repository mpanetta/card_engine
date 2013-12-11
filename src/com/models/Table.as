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

    public function deal(id:Number, cardName:String, seat:int, faceUp:Boolean):void {
      var hand:Hand = getHand(id, seat);

      hand.addCard(new Card(cardName, faceUp));
    }

    public function flip(seat:Number, cardName:String):void {
      var hand:Hand = _hands[seat];
      hand.flip(cardName);
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