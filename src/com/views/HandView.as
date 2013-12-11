package com.views
{
  import com.events.CardMessage;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Hand;

  import starling.display.Sprite;

  public class HandView extends Sprite
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private static var _count:int = 0;

    private var _hand:Hand;
    private var _disposed:Boolean = false;

    //
    // Constructors.
    //

    public function HandView(hand:Hand) {
      _hand = hand;
      _count++;

      setCards();
      register();

      super();
    }

    public override function dispose():void {
      if(_disposed)
        throw new CardError(CardError.ALREADY_DISPOSED, "hand view with hand id of: " + _hand.id);

      unregister();

      _hand = null;
      _disposed = true;
      _count--;

      super.dispose();
    }

    //
    // Getters and setters.
    //

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    private function register():void {
      _hand.addEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
    }

    private function unregister():void {
      _hand.removeEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
    }

    private function setCards():void {
      for each(var card:Card in _hand.cards)
        addCard(card);
    }

    private function addCard(card:Card):void {
      if(!card) return;

      var cardView:CardView = new CardView(card);
      addChild(cardView);
      cardView.x = _hand.cards.length * 20;
    }

    //
    // Event handlers.
    //

    private function hand_cardAdded(message:CardMessage):void {
      addCard(message.card);
    }
  }
}