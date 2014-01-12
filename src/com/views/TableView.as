package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.scene.ViewBase;
  import com.engine.Engine;
  import com.events.CardMessage;
  import com.models.CardError;
  import com.models.Hand;
  import com.models.Table;

  import flash.display.Bitmap;

  import starling.display.Image;
  import starling.events.Event;
  import starling.textures.Texture;

  public class TableView extends ViewBase
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _table:Table;
    private var _backgroundImage:Image;
    private var _hands:Hash = new Hash();

    //
    // Constructors.
    //

    public function TableView(table:Table) {
      _table = table;

      register();
    }

    public override function dispose():void {
      cleanupHands();
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

    protected function handleCardSelected(cardId:Number, handId:Number):void {
      dispatcher.dispatchEvent(new CardMessage(CardMessage.CARD_CLICKED, { cardId:cardId, handId:handId }));
    }

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
      var view:HandView = addChild(new HandView(hand)) as HandView;
      _hands[hand.id] = _hands;

      addHandListeners(view);

      var pos:Object = positions[hand.seat + seatIndexOffset];

      view.x = pos.x;
      view.y = pos.y;
    }

    private function setBackground():void {
      if(_backgroundImage || !backgroundClass) return;

      _backgroundImage = new Image(Texture.fromBitmap(new backgroundClass() as Bitmap));

      addChild(_backgroundImage);
    }

    private function addHandListeners(hand:HandView):void {
      hand.addListener(CardMessage.CARD_CLICKED, hand_cardClicked);
    }

    private function removeHandListeners(hand:HandView):void {
      hand.removeListener(CardMessage.CARD_CLICKED, hand_cardClicked);
    }

    private function cleanupHands():void {
      for each(var hand:HandView in _hands.values)
        removeHandListeners(hand);

      _hands.clear();
    }

    //
    // Event handlers.
    //

    private function table_tableDisposed(message:CardMessage):void {
      dispose();
    }

    private function hand_cardClicked(message:CardMessage):void {
      handleCardSelected(message.cardId, message.handId);
    }

    private function table_handCreated(event:CardMessage):void {
      addHand(event.hand);
    }

    private function addedToStage(event:Event):void {
      setBackground();
    }
  }
}