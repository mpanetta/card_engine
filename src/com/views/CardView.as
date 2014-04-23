package com.views
{
  import com.core.scene.ViewBase;
  import com.events.CardMessage;
  import com.managers.CardManager;
  import com.models.Card;
  import com.sound.SoundManager;
  import com.util.randomNumber;

  import flash.display.Bitmap;

  import starling.display.Image;
  import starling.events.Touch;
  import starling.filters.ColorMatrixFilter;
  import starling.textures.Texture;
  import starling.textures.TextureAtlas;
  import starling.textures.TextureSmoothing;

  public class CardView extends ViewBase
  {
    //
    // Constants.
    //

    [Embed(source="../../../assets/images/face.xml", mimeType="application/octet-stream")]
    private var FaceXml:Class;
    [Embed(source="../../../assets/images/face.png")]
    private var FaceTexture:Class;

    [Embed(source="../../../assets/images/numbers.xml", mimeType="application/octet-stream")]
    private var NumbersXml:Class;
    [Embed(source="../../../assets/images/numbers.png")]
    private var NumbersTexture:Class;

    //
    // Instance variables.
    //

    private static var _count:int = 0;
    private static var _faceAtlas:TextureAtlas;
    private static var _numbersAtlas:TextureAtlas;
    private static var _dummy:Texture;

    private var _card:Card;
    private var _image:Image;
    private var _moving:Boolean = false;

    //
    // Constructors.
    //

    public function CardView(card:Card) {
      _card = card;
      _count++;

      createTextures();
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

    private function createTextures():void {
      if(_count != 1) return;

      _faceAtlas = createAtlas(FaceTexture, FaceXml);
      _numbersAtlas = createAtlas(NumbersTexture, NumbersXml);
    }

    private function createAtlas(imageKlass:Class, xmlClass:Class):TextureAtlas {
      var bitmap:Bitmap = new imageKlass();
      bitmap.smoothing = true;
      var texture:Texture = Texture.fromBitmap(bitmap, false);
      var xml:XML = XML(new xmlClass());

      return new TextureAtlas(texture, xml)
    }

    private function destroyAtlas():void {
      if(_count != 0) return;

      _numbersAtlas.texture.dispose();
      _numbersAtlas.dispose();

      _faceAtlas.texture.dispose();
      _faceAtlas.dispose();
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
      pivotY = _image.height;

      scaleImage();
    }

    private function raise():void {
      y -= 20;
    }

    private function lower():void {
      y += 20;
    }

    private function imageFor(name:String):Image {
      try {
        return new Image(_faceAtlas.getTexture(name));
      } catch(error:Error) {
        return new Image(_numbersAtlas.getTexture(name));
      }
    }

    private function dispatchCardClicked():void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:id }));
    }

    private function scaleImage():void {
      return;

      var width:Number = _image.width;
      var height:Number = _image.height;

      var scale:Number = 1;

      if(height < width) {
        scale = (CardManager.instance.cardWidth) / width;
      } else {
        scale = (CardManager.instance.cardHeight) / height;
      }
      _image.scaleX = scale;
      _image.scaleY = scale;
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