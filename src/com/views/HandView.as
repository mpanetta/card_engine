package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Hand;

  public class HandView extends ViewBase
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
    private var _cards:Hash = new Hash();

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
      cleanupCards();

      _hand = null;
      _disposed = true;
      _count--;

      super.dispose();
    }

    //
    // Getters and setters.
    //

    public function get id():Number { return _hand.id; }

    //
    // Public methods.
    //

    //
    // Protected methods.
    //

    protected function handleCardClicked(cardId:Number):void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:cardId, handId:id }));
    }

    //
    // Private methods.
    //

    private function register():void {
      _hand.addEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.addEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
    }

    private function unregister():void {
      _hand.removeEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.removeEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
    }

    private function setCards():void {
      for each(var card:Card in _hand.cards)
        addCard(card);
    }

    private function addCard(card:Card):void {
      if(!card) return;

      var cardView:CardView = addChild(new CardView(card)) as CardView;
      addCardListeners(cardView);

      _cards[cardView.id] = cardView;
      cardView.x = _hand.cards.length * 20;
    }

    private function removeCard(id:Number):void {
      var card:CardView = removeChild(_cards[id]) as CardView;
      removeCardListeners(card);

      delete _cards[id];

      var i:int = 1;
      for each(card in _cards.values) {
        addChild(card);
        card.x = i * 20;
        i++;
      }
    }

    private function addCardListeners(card:CardView):void {
      card.addListener(CardMessage.CARD_CLICKED, card_cardClicked);
    }

    private function removeCardListeners(card:CardView):void {
      card.removeListener(CardMessage.CARD_CLICKED, card_cardClicked);
    }

    private function cleanupCards():void {
      for each(var card:CardView in _cards.values)
        removeCardListeners(card);

      _cards.clear();
    }

    //
    // Event handlers.
    //

    private function hand_cardAdded(message:CardMessage):void {
      addCard(message.card);
    }

    private function hand_cardRemoved(message:CardMessage):void {
      removeCard(message.cardId);
    }

    private function card_cardClicked(message:CardMessage):void {
      handleCardClicked(message.cardId);
    }
  }
}