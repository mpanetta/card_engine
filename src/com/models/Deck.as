package com.models
{
  import com.core.dataStructures.ArrayHelper;

  public class Deck
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _cards:Array = [];

    //
    // Constructors.
    //

    public function Deck() {
      super();
    }

    //
    // Getters and setters.
    //

    public function get count():int { return _cards.length; }

    //
    // Public methods.
    //

    public function shuffle():void {
      _cards = ArrayHelper.shuffle(_cards);
    }

    public function drawCard():Card {
      return _cards.pop();
    }

    public function drawCards(num:int):Array {
      var drawn:Array = [];
      for(var i:int = 0; i < num; i++)
        drawn.push(_cards.pop);

      return drawn;
    }

    public function addCard(card:Card):void {
      _cards.push(card);
    }

    public function addCards(cards:Array):void {
      _cards = _cards.concat(cards);
    }

    //
    // Private methods.
    //

    //
    // Event handlers.
    //
  }
}