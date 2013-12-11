package com.views
{
  import com.models.Deck;

  import starling.display.Sprite;

  public class DeckView extends Sprite
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _deck:Deck;

    //
    // Constructors.
    //

    public function DeckView(deck:Deck) {
      _deck = deck;

      register();

      super();
    }

    public override function dispose():void {
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

    }

    private function unregister():void {

    }

    //
    // Event handlers.
    //
  }
}