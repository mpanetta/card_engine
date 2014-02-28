package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Hand;
  import com.sound.SoundManager;
  import com.util.randomNumber;

  import flash.geom.Point;
  import flash.geom.Transform;

  import starling.animation.Transitions;
  import starling.animation.Tween;
  import starling.core.Starling;
  import starling.utils.deg2rad;

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
    private var _sorting:Boolean = false;
    private var _sortedCount:int = 0;

    private var _options:Object;

    //
    // Constructors.
    //

    public function HandView(hand:Hand, fanWidth:int, opts:Object) {
      _hand = hand;
      _fanWidth = fanWidth;
      _options = opts;

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

    private function get fanIncrement():Number { return hasMax ? (_fanWidth / maxCards) : (_fanWidth / numCards); }
    private function get numCards():int { return _hand.cards.length; }

    private function get even():Boolean { return numCards / 2.0 == Math.floor(numCards / 2.0); }
    private function get odd():Boolean { return !even; }

    private function get handPos():int { return maxCards == -1 ? 0 : (_fanWidth / maxCards * (maxCards - numCards)) / 2; }
    private function get maxCards():int { return _options.maxCards ? _options.maxCards : -1; }
    private function get hasMax():Boolean { return maxCards != -1; }

    //
    // Public methods.
    //

    public function moveCard(view:CardView, opts:Object):void {
      var trans:Object = nextCardPosition();
      var currentPosition:Point = view.parent.localToGlobal(new Point(view.x, view.y));
      var newPosition:Point = globalToLocal(currentPosition);
      view.x = newPosition.x;
      view.y = newPosition.y;

      addChild(view);
      addCardListeners(view);
      _cards[view.id] = view;

      Starling.juggler.tween(view, 0.15, { transition:Transitions.EASE_IN_OUT, repeatCount:2, reverse:true, scaleX:1.06, scaleY:1.06 });
      Starling.juggler.tween(view, 0.30, { transition:Transitions.EASE_IN_OUT, x:trans.x, y:trans.y, rotation:trans.rotation,
        onComplete:function():void { moveComplete(opts.noSound, view)
      }});

      if(!opts.noSound)
        SoundManager.instance.playTrack("cards", "cardSlide" + randomNumber(1, 6));

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_VIEW_ADDED, { handId:id }));
    }

    //
    // Protected methods.
    //

    protected function handleCardClicked(cardId:Number):void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:cardId, handId:id }));
    }

    protected function addCard(card:Card):CardView {
      if(!card) return null;

      var cardView:CardView = addChild(new CardView(card)) as CardView;
      addCardListeners(cardView);

      _cards[cardView.id] = cardView;

      fan();

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_VIEW_ADDED, { handId:id }));

      return cardView;
    }

    protected function removeCard(id:Number):CardView {
      var card:CardView = removeChild(_cards[id]) as CardView;
      removeCardListeners(card);

      delete _cards[id];

      fan();

      return card;
    }

    protected function handleMoving(cardId:Number, handId:Number, options:Object):CardView {
      var cardView:CardView = _cards[cardId];
      delete _cards[cardId];
      removeCardListeners(cardView);
      cardView.moving = true;

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_MOVING, { cardView:cardView, handId:handId, options:options }));
      fan();

      return cardView;
    }

    protected function nextCardPosition():Object {
      var data:Object = {};
      data.rotation = rotationFor(numCards + 1);
      data.x = (_fanWidth ? ((numCards + 1) * fanIncrement) : 0);
      data.y = 0;

      return data;
    }

    //
    // Private methods.
    //

    private function register():void {
      _hand.addEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.addEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
      _hand.addEventListener(CardMessage.HAND_SORTED, hand_handSorted);
      _hand.addEventListener(CardMessage.HAND_HIDE, hand_handHide);
      _hand.addEventListener(CardMessage.CARD_MOVING, hand_cardMoving);
    }

    private function unregister():void {
      _hand.removeEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.removeEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
      _hand.removeEventListener(CardMessage.HAND_SORTED, hand_handSorted);
      _hand.removeEventListener(CardMessage.HAND_HIDE, hand_handHide);
      _hand.removeEventListener(CardMessage.CARD_MOVING, hand_cardMoving);
    }

    private function setCards():void {
      for each(var card:Card in _hand.cards)
        addCard(card);
    }

    private function fan():void {
      if(_options.noFan) return;

      var i:int = 0;
      var card:CardView;

      for each(var id:Number in _hand.order) {
        card = _cards[id];

        fanCard(card, i);
        i++;
      }
    }

    private function rotationFor(index:int):Number {
      if(numCards <= 1) return 0;
      var center:Number = (numCards / 2) - 0.5;

      return deg2rad((index - center) * (_options.arch ? 0.75 : 5))
    }

    private function fanCard(card:CardView, index:int):void {
      addChild(card);
      card.x = (index * fanIncrement) + handPos;
      card.y = archAdjustment(index, card);

      if(_options.rotation)
        card.rotation = rotationFor(index);
    }

    private function archAdjustment(index:int, view:CardView):int {
      if(!_options.arch) return 0;
      var center:Number = (numCards / 2) - 0.5;
      if(index == center)
        return 0;
      else if(index < center)
        return -view.transformationMatrix.deltaTransformPoint(new Point(view.width, 0)).y;
      else
        return view.transformationMatrix.deltaTransformPoint(new Point(view.width, 0)).y;
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
      if(_sorting == true) return;
      if(animate) _sorting = true;

      _sortedCount = sortedCards.length;

      var index:int;

      for each(var view:CardView in _cards.values) {
        if(animate) {
          index = sortIndex(sortedCards, view.id);
          var tween:Tween = new Tween(view, 0.2, Transitions.EASE_IN_OUT);
          tween.animate("x", index * fanIncrement);

          if(_options.rotate)
            tween.animate("rotation", rotationFor(index));

          tween.onComplete = sortTweenComplete;

          addChild(view);

          Starling.juggler.add(tween);
        } else {
          fanCard(view, sortIndex(sortedCards, view.id));
        }
      }
    }

    private function sortIndex(sorted:Array, id:Number):int {
      for(var i:int = 0; i < sorted.length; i++) {
        if(sorted[i].id == id)
          return i
      }

      throw new CardError(CardError.NO_ID, "Couldn't fund id: " + id);
    }

    private function sortTweenComplete():void {
      _sortedCount -= 1;
      if(_sortedCount == 0) {
        _sorting = false;
        return;
      }

      fan();
    }

    private function hide():void {
      visible = !_hand.hidden;
    }

    private function moveComplete(noSound:Boolean, view:CardView):void {
      if(!noSound)
        SoundManager.instance.playTrack("cards", "cardSlap" + randomNumber(1, 6));

      view.moving = false;
      fan();
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

    private function hand_handHide(message:CardMessage):void {
      hide();
    }

    private function hand_cardMoving(message:CardMessage):void {
      handleMoving(message.cardId, message.handId, message.options);
    }
  }
}