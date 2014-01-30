package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Hand;

  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;

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
    private var _fanWidth:int;
    private var _disposed:Boolean = false;
    private var _cards:Hash = new Hash();

    //
    // Constructors.
    //

    public function HandView(hand:Hand, fanWidth:int) {
      _hand = hand;
      _fanWidth = fanWidth;
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
    public function get seat():int { return _hand.seat; }

    private function get fanIncrement():Number { return (_fanWidth / _hand.cards.length); }

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
      _hand.addEventListener(CardMessage.HAND_SORTED, hand_handSorted);
    }

    private function unregister():void {
      _hand.removeEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.removeEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
      _hand.removeEventListener(CardMessage.HAND_SORTED, hand_handSorted);
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
      fan();
    }

    private function removeCard(id:Number):void {
      var card:CardView = removeChild(_cards[id]) as CardView;
      removeCardListeners(card);

      delete _cards[id];

      fan();
    }

    private function fan():void {
      var i:int = 0;
      var card:CardView;

      for each(var id:Number in _hand.order) {
        card = _cards[id];
        addChild(card);
        card.x = i * fanIncrement;
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

    private function sort(sortedCards:Array, animate:Boolean):void {
      for each(var view:CardView in _cards.values) {
        if(animate) {
          var tween:Tween = new Tween(view, 0.3, Transitions.LINEAR);
          tween.animate("x", sortIndex(sortedCards, view.id) * fanIncrement);
          Starling.juggler.add(tween);
        } else {
          view.x = sortIndex(sortedCards, view.id) * fanIncrement;
        }
      }

      for each(var card:Card in sortedCards) {
        view = _cards[card.id];
        addChild(view);
      }
    }

    private function sortIndex(sorted:Array, id:Number):int {
      for(var i:int = 0; i < sorted.length; i++) {
        if(sorted[i].id == id)
          return i
      }

      throw new CardError(CardError.NO_ID, "Couldn't fund id: " + id);
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

    private function hand_handSorted(message:CardMessage):void {
      sort(message.sortedCards, message.animate);
    }
  }
}