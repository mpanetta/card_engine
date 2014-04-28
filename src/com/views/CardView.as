package com.views
{
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.managers.CardManager;
  import com.models.Card;
  import com.sound.SoundManager;
  import com.util.randomNumber;

  import starling.display.Image;
  import starling.events.Touch;
  import starling.filters.ColorMatrixFilter;
  import starling.textures.TextureSmoothing;

  public class CardView extends ViewBase
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private static var _count:int = 0;

    private var _card:Card;
    private var _image:Image;
    private var _moving:Boolean = false;

    //
    // Constructors.
    //

    public function CardView(card:Card) {
      _card = card;
      _count++;

      register();
      update();
    }

    public override function dispose():void {
      _count--;

      unregister();

      super.dispose();
    }

    //
    // Getters and setters.
    //

    public function get id():Number { return _card.id; }

    public function set moving(value:Boolean):void { _moving = value; }
    public function get moving():Boolean { return _moving; }

    public override function get name():String { return _card.name; }

    public override function set x(value:Number):void { super.x = Math.floor(value); }
    public override function set y(value:Number):void { super.y = Math.floor(value); }

    //
    // Public methods.
    //

    //
    // Protected methods.
    //

    protected override function handleEnded(touch:Touch):void {
      if(touch && !moving) {
        dispatchCardClicked();
      }
    }

    protected override function handleHover(touch:Touch):void {
    }

    //
    // Private methods.
    //

    private function register():void {
      _card.addEventListener(CardMessage.CARD_FLIPPED, card_cardFlipped);
      _card.addEventListener(CardMessage.CARD_RAISED, card_cardRaised);
      _card.addEventListener(CardMessage.CARD_LOWERED, card_cardLowered);
      _card.addEventListener(CardMessage.ENABLED_CHANGED, card_enabledChanged);
    }

    private function unregister():void {
      _card.removeEventListener(CardMessage.CARD_FLIPPED, card_cardFlipped);
      _card.removeEventListener(CardMessage.CARD_RAISED, card_cardRaised);
      _card.removeEventListener(CardMessage.CARD_LOWERED, card_cardLowered);
      _card.removeEventListener(CardMessage.ENABLED_CHANGED, card_enabledChanged);
    }

    private function update():void {
      if(_image) {
        removeChild(_image);

        _image.texture.dispose();
        _image.dispose();
        _image = null;
      }

      _image = imageFor(_card.imageFile);
      _image.smoothing = TextureSmoothing.TRILINEAR;
      addChild(_image);

      pivotX = _image.width / 2;
      pivotY = _image.height / 2;
      _image.y = -_image.height / 2;
    }

    private function raise():void {
      y -= 20;
    }

    private function lower():void {
      y += 20;
    }

    private function imageFor(name:String):Image {
      return CardManager.instance.imageForCard(name);
    }

    private function dispatchCardClicked():void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:id }));
    }

    private function handleEnabled(enabled:Boolean):void {
      if(_image.filter) _image.filter.dispose();

      if(enabled) {
        _image.filter = null;
      } else {
        _image.filter = createGrayFilter();
      }
    }

    private function createGrayFilter():ColorMatrixFilter {
      var filter:ColorMatrixFilter = new ColorMatrixFilter();
      filter.adjustBrightness(-0.40);

      return filter;
    }

    //
    // Event handlers.
    //

    private function card_cardFlipped(message:CardMessage):void {
      update();
      SoundManager.instance.playTrack("cards", "cardFlip" + randomNumber(1, 3));
    }

    private function card_cardRaised(message:CardMessage):void {
      raise();
    }

    private function card_cardLowered(message:CardMessage):void {
      lower();
    }

    private function card_enabledChanged(message:CardMessage):void {
      handleEnabled(message.enabled);
    }
  }
}