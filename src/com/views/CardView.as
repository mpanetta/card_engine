package com.views
{
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.managers.CardManager;
  import com.models.Card;

  import flash.display.Bitmap;
  import flash.filters.GlowFilter;

  import starling.display.Image;
  import starling.events.Touch;
  import starling.filters.FragmentFilter;
  import starling.textures.Texture;
  import starling.textures.TextureAtlas;

  public class CardView extends ViewBase
  {
    //
    // Constants.
    //

    [Embed(source="../../../assets/images/assets.xml", mimeType="application/octet-stream")]
    private var CardXml:Class;
    [Embed(source="../../../assets/images/assets.png")]
    private var CardTexture:Class;

    //
    // Instance variables.
    //

    private static var _count:int = 0;
    private static var _atlas:TextureAtlas;

    private var _card:Card;
    private var _image:Image;

    //
    // Constructors.
    //

    public function CardView(card:Card) {
      _card = card;
      _count++;

      createAtlas();
      register();
      update();
    }

    public override function dispose():void {
      _count--;

      destroyAtlas();
      unregister();

      super.dispose();
    }

    //
    // Getters and setters.
    //

    public function get id():Number { return _card.id; }

    //
    // Public methods.
    //

    //
    // Protected methods.
    //

    protected override function handleEnded(touch:Touch):void {
      if(touch)
        dispatchCardClicked();
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
    }

    private function unregister():void {
      _card.removeEventListener(CardMessage.CARD_FLIPPED, card_cardFlipped);
      _card.removeEventListener(CardMessage.CARD_RAISED, card_cardRaised);
      _card.removeEventListener(CardMessage.CARD_LOWERED, card_cardLowered);
    }

    private function createAtlas():void {
      if(_count != 1) return;

      var bitmap:Bitmap = new CardTexture();
      var texture:Texture = Texture.fromBitmap(bitmap);
      var xml:XML = XML(new CardXml());

      _atlas = new TextureAtlas(texture, xml);
    }

    private function destroyAtlas():void {
      if(_count != 0) return;

      _atlas.texture.dispose();
      _atlas.dispose();
    }

    private function update():void {
      if(_image) {
        removeChild(_image);

        _image.texture.dispose();
        _image.dispose();
        _image = null;
      }

      _image = addChild(imageFor(_card.imageFile)) as Image;
      _image.pivotX = _image.width / 2;
      _image.pivotY = _image.height;

      scaleImage();
    }

    private function raise():void {
      y -= 20;
    }

    private function lower():void {
      y += 20;
    }

    private function imageFor(name:String):Image {
      return new Image(_atlas.getTexture(name));
    }

    private function dispatchCardClicked():void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:id }));
    }

    private function scaleImage():void {
      return;  // not sure if we want this at the moment

      var width:Number = _image.width;
      var height:Number = _image.height;

      var scale:Number = 1;

      if(height < width) {
        scale = CardManager.instance.cardWidth / width;
      } else {
        scale = CardManager.instance.cardHeight / height;
      }

      _image.scaleX = scale;
      _image.scaleY = scale;
    }

    //
    // Event handlers.
    //

    private function card_cardFlipped(message:CardMessage):void {
      update();
    }

    private function card_cardRaised(message:CardMessage):void {
      raise();
    }

    private function card_cardLowered(message:CardMessage):void {
      lower();
    }
  }
}