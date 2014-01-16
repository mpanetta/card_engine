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
  import starling.display.Sprite;
  import starling.events.Event;
  import starling.textures.Texture;
  import starling.utils.deg2rad;

  public class TableView extends ViewBase
  {
    //
    // Constants.
    //

    //
    // Instance variables.
    //

    private var _table:Table;
    private var _backgroundLayer:Sprite;
    private var _playLayer:Sprite;
    private var _backgroundImage:Image;
    private var _hands:Hash = new Hash();

    //
    // Constructors.
    //

    public function TableView(table:Table) {
      _table = table;
      createLayers();

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

    protected function get hands():Array { return _hands.values; }
    protected function get seatIndexOffset():int { return 1; }
    protected function get positions():Array { throw new CardError(CardError.MUST_OVERRIDE, " method: positions"); }
    protected function get backgroundClass():Class { throw new CardError(CardError.MUST_OVERRIDE, " method: backgroundClass"); }
    protected function get appWidth():Number { return Engine.instance.appWidth; }
    protected function get appHeight():Number { return Engine.instance.appHeight; }

    //
    // Public methods.
    //

    public function resize(newWidth:Number, newHeight:Number):void {
      scaleBackground(newWidth, newHeight);
      scalePlayLayer(newWidth, newHeight);
      positionHands();
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

    private function build():void {
      setBackground();
    }

    private function createLayers():void {
      _backgroundLayer = addChild(new Sprite()) as Sprite;
      _playLayer = addChild(new Sprite()) as Sprite;
    }

    private function setBackground():void {
      if(_backgroundImage || !backgroundClass) return;

      _backgroundImage = new Image(Texture.fromBitmap(new backgroundClass() as Bitmap));
      _backgroundImage.pivotX = _backgroundImage.width / 2;
      _backgroundImage.pivotY = _backgroundImage.height / 2;

      _backgroundLayer.addChild(_backgroundImage);
    }

    private function addHand(hand:Hand):void {
      var pos:Object = positions[hand.seat + seatIndexOffset];
      var view:HandView = _playLayer.addChild(new HandView(hand, pos.fanWidth)) as HandView;
      _hands[hand.id] = view;

      view.rotation = deg2rad(pos.rotation);
      addHandListeners(view);
      positionView(view, pos.x, pos.y);
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

    private function scaleBackground(newWidth:Number, newHeight:Number):void {
      if(!_backgroundImage) return;

      var scale:Number = newHeight / (_backgroundImage.height / _backgroundImage.scaleX);

      _backgroundImage.scaleX = scale;
      _backgroundImage.scaleY = scale;
      _backgroundImage.x = newWidth / 2;
      _backgroundImage.y = newHeight / 2;
    }

    private function scalePlayLayer(newWidth:Number, newHeight:Number):void {
      var scale:Number = 1;
      var scaledX:Number = newWidth / appWidth;
      var scaledY:Number = newHeight / appHeight;

      if(newHeight > newWidth) {
        scale = scaledX;

        _playLayer.x = 0;
        _playLayer.y = ((appHeight * scaledX) - (appHeight * scaledY)) / 2
      } else {
        scale = scaledY;

        _playLayer.x =  (scaledX - scaledY) * appWidth / 2
        _playLayer.y = 0;
      }

      _playLayer.scaleX = scale;
      _playLayer.scaleY = scale;
    }

    private function positionHands():void {
      for each(var hand:HandView in hands) {
        var position:Object = positions[hand.seat + seatIndexOffset];
        positionView(hand, position.x, position.y);
      }
    }

    private function positionView(hand:HandView, xPos:int, yPos:int):void {
      hand.x = xPos;
      hand.y = yPos;
    }

    //
    // Event handlers.582.75
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