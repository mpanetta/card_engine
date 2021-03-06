package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.managers.CardManager;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Hand;
  import com.sound.SoundManager;
  import com.util.randomNumber;

  import flash.geom.Point;

  import starling.animation.Transitions;
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

    public override function set x(value:Number):void { super.x = Math.floor(value); }
    public override function set y(value:Number):void { super.y = Math.floor(value); }

    public function get id():Number { return _hand.id; }
    public function get seat():int { return _hand.seat; }
    public function get anchor():String { return _options.anchor; }

    private function get fanIncrement():Number { return hasMax ? (_fanWidth / maxCards) : (_fanWidth / numCards); }
    private function get numCards():int { return _hand.cards.length; }

    private function get even():Boolean { return numCards / 2.0 == Math.floor(numCards / 2.0); }
    private function get odd():Boolean { return !even; }

    private function get handPos():int { return maxCards == -1 ? 0 : (_fanWidth / maxCards * (maxCards - numCards)) / 4; }
    private function get maxCards():int { return _options.maxCards ? _options.maxCards : -1; }
    private function get hasMax():Boolean { return maxCards != -1; }

    //
    // Public methods.
    //

    public function moveCard(view:CardView, opts:Object):void {
      if(opts.sort) _hand.sort(opts.sort, false);

      var currentPosition:Point = view.parent.localToGlobal(new Point(view.x, view.y));
      var newPosition:Point = globalToLocal(currentPosition);
      view.x = newPosition.x;
      view.y = newPosition.y;

      addChild(view);
      addCardListeners(view);
      _cards[view.id] = view;

      if(!opts.noSound) SoundManager.instance.playTrack("cards", "cardSlide" + randomNumber(1, 6));

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_VIEW_ADDED, { handId:id }));
    }

    //
    // Protected methods.
    //

    protected override function handleAddedToStage():void {
      if(_options.scaleFactor) scaleX = scaleY = _options.scaleFactor;
    }

    protected function handleCardClicked(cardId:Number):void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:cardId, handId:id }));
    }

    protected function addCard(card:Card):CardView {
      if(!card) return null;

      var cardView:CardView = addChild(new CardView(card)) as CardView;
      var pos:Object = nextCardPosition(cardView, numCards - 1);
      cardView.x = pos.x;
      cardView.y = pos.y;
      cardView.rotation = pos.rotation;

      addCardListeners(cardView);

      _cards[cardView.id] = cardView;

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_VIEW_ADDED, { handId:id }));

      return cardView;
    }

    protected function removeCard(id:Number, moveIndex:int=-1):CardView {
      var card:CardView = _cards[id];
      removeCardListeners(card);

      delete _cards[id];

      removeChild(card) as CardView;

      return card;
    }

    protected function handleMoving(cardId:Number, handId:Number, options:Object):CardView {
      var cardView:CardView = _cards[cardId];
      delete _cards[cardId];
      removeCardListeners(cardView);
      cardView.moving = true;

      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_MOVING, { cardView:cardView, handId:handId, options:options }));

      return cardView;
    }

    protected function nextCardPosition(view:CardView, assumedIndex:int = -1):Object {
      var data:Object = {};
      var index:int = assumedIndex > -1 ? assumedIndex : numCards + 1;
      data.rotation = rotationFor(index);
      data.x = (_fanWidth ? index * fanIncrement : 0) + totalOffset();
      data.y = archFor(index, view);
      data.order = index;

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
      _hand.addEventListener(CardMessage.HAND_FAN, hand_handFan);
    }

    private function unregister():void {
      _hand.removeEventListener(CardMessage.CARD_ADDED, hand_cardAdded);
      _hand.removeEventListener(CardMessage.CARD_REMOVED, hand_cardRemoved);
      _hand.removeEventListener(CardMessage.HAND_SORTED, hand_handSorted);
      _hand.removeEventListener(CardMessage.HAND_HIDE, hand_handHide);
      _hand.removeEventListener(CardMessage.CARD_MOVING, hand_cardMoving);
      _hand.removeEventListener(CardMessage.HAND_FAN, hand_handFan);
    }

    private function setCards():void {
      for each(var card:Card in _hand.cards)
        addCard(card);
    }

    private function fan(opts:Object):void {
      var i:int = 0;
      var card:CardView;

      for each(var id:Number in _hand.order) {
        card = _cards[id];

        if(card) {
          fanCard(card, i, opts);
          i++;
        }
      }
    }

    private function fanCard(card:CardView, index:int, opts:Object):void {
      addChild(card);
      var trans:Object = nextCardPosition(card, index);

      if(card.moving) {
        Starling.juggler.removeTweens(card);
        card.moving = false;
      }

      card.moving = true;
      Starling.juggler.tween(card, 0.33, { transition:Transitions.LINEAR,
        x:trans.x, y:trans.y, rotation:trans.rotation,
        onComplete:function():void {
          card.moving = false; if(!opts.noSound) SoundManager.instance.playTrack("cards", "cardSlap" + randomNumber(1, 6));
          Starling.juggler.removeTweens(card);
        }
      });
    }

    private function rotationFor(index:int):Number {
      if(numCards <= 1) return 0;
      var center:Number = (numCards / 2) - 0.5;

      return deg2rad((index - center) * (_options.arch ? 0.75 : 7));
    }

    private function indexFor(view:CardView, sort:Array):int {
      var card:Card;
      for(var i:int = 0; i < sort.length; i++) {
        card = sort[i];
        if(view.name == card.name) return i;
      }

      return -1;
    }

    private function archFor(index:int, view:CardView):int {
      if(!_options.arch) return 0;

      var oldRot:Number = view.rotation;
      var center:Number = (numCards / 2) - 0.5;
      var defaultY:Number = -1;
      view.rotation = rotationFor(index);

      if(index == center)
        defaultY = 0;
      if(index < center)
        defaultY = -view.transformationMatrix.deltaTransformPoint(new Point(view.width, 0)).y;
      else
        defaultY = view.transformationMatrix.deltaTransformPoint(new Point(view.width, 0)).y;

      view.rotation = oldRot;
      return defaultY;
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
    }

    private function sortIndex(sorted:Array, id:Number):int {
      for(var i:int = 0; i < sorted.length; i++) {
        if(sorted[i].id == id)
          return i
      }

      throw new CardError(CardError.NO_ID, "Couldn't find id: " + id);
    }

    private function hide():void {
      visible = !_hand.hidden;
    }

    private function moveComplete(noSound:Boolean, view:CardView):void {
      if(!noSound)
        SoundManager.instance.playTrack("cards", "cardSlap" + randomNumber(1, 6));

      view.moving = false;
    }

    private function fanRequest(options:Object):void {
      fan(options)
    }

    private function totalOffset():Number {
      if(!_fanWidth || _fanWidth <= CardManager.instance.cardWidth) return 0;

      return (_fanWidth - (aabbWidth(numCards - 1) + numCards * fanIncrement)) / 2;
    }

    private function aabbWidth(index:int):Number {
      if(index < 0) return 0;

      var rot:Number = rotationFor(index);
      return CardManager.instance.cardHeight * Math.sin(rot) + CardManager.instance.cardWidth * Math.cos(rot);
    }

    //
    // Event handlers.
    //

    private function hand_cardAdded(message:CardMessage):void {
      addCard(message.card);
    }

    private function hand_cardRemoved(message:CardMessage):void {
      removeCard(message.cardId, message.moveIndex);
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

    private function hand_handFan(message:CardMessage):void {
      fanRequest(message.options);
    }
  }
}