package com.managers
{
  import com.core.error.ErrorBase;
  import com.models.Card;
  import com.models.CardError;
  import com.models.Deck;

  import flash.events.EventDispatcher;

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

    //
    // Constructors.
    //

    public function CardManager(sb:SingletonBlocker, options:Object) {
      _options = options;
    }

    public static function initialize(options:Object=null):void {
      _instance = new CardManager(new SingletonBlocker, options);
    }

    public static function get instance():CardManager {
      if(_instance) return _instance;

      throw new ErrorBase(ErrorBase.UNINITIALIZED, "");
    }

    //
    // Getters and setters.
    //

    //
    // Public methods.
    //

    public function createStandardDeck():Deck {
      var deck:Deck = new Deck();
      for(var i:int = 0; i < 52; i++) {
        var card:Card = new Card(standardNameFor(i), false);
        deck.addCard(card);
      }

      return deck;
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

    //
    // Event handlers.
    //
  }
}

class SingletonBlocker {}