package com.views
{
  import com.engine.Engine;
  import com.events.CardMessage;
  import com.models.CardError;
  import com.models.Hand;
  import com.models.Table;

  import flash.display.Bitmap;

  import starling.display.Image;
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.textures.Texture;

  public class TableView extends Sprite
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _table:Table;
    private var _backgroundImage:Image;

    //
    // Constructors.
    //

    public function TableView(table:Table) {
      _table = table;

      register();
    }

    public override function dispose():void {
      unregister();

      super.dispose();
    }

    //
    // Getters and setters.
    //

    protected function get seatIndexOffset():int { return 1; }
    protected function get positions():Array { throw new CardError(CardError.MUST_OVERRIDE, " method: positions"); }
    protected function get backgroundClass():Class { throw new CardError(CardError.MUST_OVERRIDE, " method: backgroundClass"); }

    //
    // Public methods.
    //

    public function resize():void {
      if(!_backgroundImage) return;

      _backgroundImage.width = Engine.instance.width;
      _backgroundImage.height = Engine.instance.height;
    }

    //
    // Protected methods.
    //

    //
    // Private methods.
    //

    private function register():void {
      addEventListener(Event.ADDED_TO_STAGE, addedToStage);

      _table.addEventListener(CardMessage.TABLE_DISPOSED, table_tableDisposed);
      _table.addEventListener(CardMessage.HAND_CREATED, table_handCreated);
    }

    private function unregister():void {
      removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

      _table.removeEventListener(CardMessage.TABLE_DISPOSED, table_tableDisposed);
      _table.removeEventListener(CardMessage.HAND_CREATED, table_handCreated);
    }

    private function addHand(hand:Hand):void {
      var view:HandView = new HandView(hand);
      var pos:Object = positions[hand.seat + seatIndexOffset];
      addChild(view);

      view.x = pos.x;
      view.y = pos.y;
    }

    private function setBackground():void {
      if(_backgroundImage) return;

      _backgroundImage = new Image(Texture.fromBitmap(new backgroundClass()as Bitmap));

      addChild(_backgroundImage);
    }

    //
    // Event handlers.
    //

    private function table_tableDisposed(message:CardMessage):void {
      dispose();
    }

    private function table_handCreated(event:CardMessage):void {
      addHand(event.hand);
    }

    private function addedToStage(event:Event):void {
      setBackground();
    }
  }
}