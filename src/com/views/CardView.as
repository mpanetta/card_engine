package com.views
{
  import com.events.CardMessage;
  import com.models.Card;

  import starling.display.Image;
  import starling.display.Sprite;
  import starling.textures.Texture;
  import starling.textures.TextureAtlas;

  public class CardView extends Sprite
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

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    private function register():void {
      _card.addEventListener(CardMessage.CARD_FLIPPED, card_cardFlipped);
    }

    private function unregister():void {
      _card.removeEventListener(CardMessage.CARD_FLIPPED, card_cardFlipped);
    }

    private function createAtlas():void {
      if(_count != 1) return;

      var texture:Texture = Texture.fromBitmap(new CardTexture());
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

      _image = imageFor(_card.imageFile);
      addChild(_image);
    }

    private function imageFor(name:String):Image {
      return new Image(_atlas.getTexture(name));
    }

    //
    // Event handlers.
    //

    private function card_cardFlipped(message:CardMessage):void {
      update();
    }
  }
}