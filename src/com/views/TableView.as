package com.views
{
  import com.engine.Engine;
  import com.events.CardMessage;
  import com.models.Hand;
  import com.models.Table;

  import flash.display.Bitmap;

  import starling.display.Image;
  import starling.display.Sprite;
  import starling.textures.Texture;

  public class TableView extends Sprite
  {
    //
    // Constants.
    //

    [Embed(source = "../../../assets/images/background.jpeg")]
    private static const Background:Class;

    private const POSITIONS:Array = [{ x:345, y:125 }, { x:345, y:450 }];

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

      setBackground();
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

    //
    // Public methods.
    //

    public function resize():void {
      _backgroundImage.width = Engine.instance.width;
      _backgroundImage.height = Engine.instance.height;
    }

    //
    // Private methods.
    //

    private function register():void {
      _table.addEventListener(CardMessage.TABLE_DISPOSED, table_tableDisposed);
      _table.addEventListener(CardMessage.HAND_CREATED, table_handCreated);
    }

    private function unregister():void {
      _table.removeEventListener(CardMessage.TABLE_DISPOSED, table_tableDisposed);
      _table.removeEventListener(CardMessage.HAND_CREATED, table_handCreated);
    }

    private function setBackground():void {
      _backgroundImage = new Image(Texture.fromBitmap(new Background() as Bitmap));

      addChild(_backgroundImage);
    }

    private function addHand(hand:Hand):void {
      var view:HandView = new HandView(hand);
      var pos:Object = POSITIONS[hand.seat + seatIndexOffset];
      addChild(view);

      view.x = pos.x;
      view.y = pos.y;
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
  }
}