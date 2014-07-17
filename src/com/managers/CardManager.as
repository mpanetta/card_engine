package com.managers
{
  import com.core.dataStructures.ArrayHelper;
  import com.core.error.ErrorBase;
  import com.engine.Engine;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Deck;

  import flash.events.EventDispatcher;

  import starling.display.Image;
  import starling.textures.TextureAtlas;

  public class CardManager extends EventDispatcher
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private static var _instance:CardManager;

    private var _options:Object;
    private var _cardSheets:Array = [];
    private var _deck:Deck;

    //
    // Constructors.
    //

    public function CardManager(sb:SingletonBlocker, options:Object) {
      _options = options;
    }

    public static function initialize(options:Object=null):void {
      if(_instance)
        throw new ErrorBase(ErrorBase.MULTIPLE_INITIALIZE, "CardManager");

      _instance = new CardManager(new SingletonBlocker, options);
    }

    public static function get instance():CardManager {
      if(_instance) return _instance;

      throw new ErrorBase(ErrorBase.UNINITIALIZED, "CardManager");
    }

    //
    // Getters and setters.
    //

    public function get cardWidth():int { return _options.hasOwnProperty("cardWidth") ? _options.cardWidth : 50; }
    public function get cardHeight():int { return _options.hasOwnProperty("cardHeight") ? _options.cardHeight : 100; }

    private function get assets():* { return Engine.instance.assetManager; }

    //
    // Public methods.
    //

    public function createStandardDeck():Deck {
      if(_deck) return _deck;
      var deck:Deck = new Deck();
      for(var i:int = 0; i < 52; i++) {
        var card:Card = new Card(standardNameFor(i), true, i, standardFaceFor(i), standardSuitFor(i), valueFor(i));
        deck.addCard(card);
        imageForCard(card.imageFile);
        card.flip();
      }

      _deck = deck;
      return _deck;
    }

    public function findCard(cards:Array, face:String, suit:String):Card {
      return ArrayHelper.find(cards, function(card:Card):Boolean { return card.face == face && card.suit == suit }) as Card;
    }

    public function findBySuit(cards:Array, suit:String):Array {
      return ArrayHelper.select(cards, function(card:Card):Boolean { return card.suit == suit });
    }

    public function rejectBySuit(cards:Array, suit:String):Array {
      return ArrayHelper.reject(cards, function(card:Card):Boolean { return card.suit == suit });
    }

    public function setCardAssets(sheets:Array):void {
      _cardSheets = sheets;
    }

    public function imageForCard(name:String):Image {
      return assets.cardImage(name);

      for(var i:int = 0; i < _cardSheets.length; i++) {
        try {
          if(_cardSheets[i] is TextureAtlas) {
            return new Image(_cardSheets[i].getTexture(name));
          } else {
            return new Image(_cardSheets[i][name]);
          }
        } catch(error:Error) {
          // Do nothing
        }
      }

      throw new CardError(CardError.MISSING_CARD_IMAGE, " name: " + name);
    }

    //
    // Private methods.
    //

    private function register():void {
    }

    private function unregister():void {
    }

    private function standardNameFor(i):String {
      return standardFaceFor(i) + standardSuitFor(i);
    }

    private function standardFaceFor(i):String {
      var suitNum:int = i % 13;
      if(suitNum == 0) return 'a';
      if(suitNum <= 9) return (suitNum + 1).toString();
      if(suitNum == 10) return 'j';
      if(suitNum == 11) return 'q';
      if(suitNum == 12) return 'k';

      throw new CardError(CardError.UNKOWN_STANDARD_SUIT, " suit num: " + suitNum);
    }

    private function standardSuitFor(i):String {
      if(i <= 12) return 's';
      if(i <= 25) return 'h';
      if(i <= 38) return 'd';

      return 'c';
    }

    private function valueFor(i):int {
      var x:int = i % 13;
      return x == 0 ? 13 : x;
    }

    private function imageFile(face:String, suit:String, faceUp:Boolean):String {
      return "247_" + (faceUp ? fullSuit + "_" + face.toUpperCase() : "CardBack_III_Blank");
    }

    private function fullSuit(suit:String):String {
      switch(suit) {
        case "c":
          return "Clubs";
          break;
        case "d":
          return "Diamonds";
          break;
        case "h":
          return "Hearts";
          break;
        case "s":
          return "Spades";
          break;
        default:
          throw new CardError(CardError.UNKOWN_STANDARD_SUIT, suit);
      }
    }

    //
    // Event handlers.
    //
  }
}

class SingletonBlocker {}