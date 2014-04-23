package com.views
{
  import com.core.dataStructures.Hash;
  import com.core.enum.Anchor;
  import com.core.scene.ViewBase;
  import com.engine.Engine;
  import com.events.CardMessage;
  import com.models.CardError;
  import com.models.Hand;
  import com.models.Table;

  import flash.display.Bitmap;
  import flash.utils.getDefinitionByName;

  import starling.display.BlendMode;
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
    protected function get backgroundBitmap():Bitmap { throw new CardError(CardError.MUST_OVERRIDE, " method: backgroundClass"); }
    protected function get appWidth():Number { return Engine.instance.appWidth; }
    protected function get appHeight():Number { return Engine.instance.appHeight; }
    protected function get playLayer():Sprite { return _playLayer; }

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

    protected function handleCardViewAdded(handId:Number):void {

    }

    protected function moveCard(cardView:CardView, handId:Number, options:Object):void {
      var hand:HandView = _hands[handId];
      hand.moveCard(cardView, options);
    }

    protected function bringHandToFront(id:Number):void {
      var view:HandView = _hands[id];
      _playLayer.addChild(view);
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
      if(_backgroundImage || !backgroundBitmap) return;

      _backgroundImage = new Image(Texture.fromBitmap(backgroundBitmap));
//      _backgroundImage.pivotX = _backgroundImage.width / 2;
//      _backgroundImage.pivotY = _backgroundImage.height / 2;

      _backgroundLayer.addChild(_backgroundImage);
    }

    private function addHand(hand:Hand):void {
      var pos:Object = positions[hand.seat + seatIndexOffset];
      var klass:Class = getDefinitionByName(pos.options.handClass ? pos.options.handClass : "com.views.HandView") as Class;
      var view:HandView = _playLayer.addChild(new klass(hand, pos.fanWidth, pos.options)) as HandView;
      _hands[hand.id] = view;

      view.rotation = deg2rad(pos.rotation);
      addHandListeners(view);
      positionView(view, pos.x, pos.y, view.anchor);
    }

    private function addHandListeners(hand:HandView):void {
      hand.addListener(CardMessage.CARD_CLICKED, hand_cardClicked);
      hand.addListener(CardMessage.CARD_VIEW_ADDED, hand_cardViewAdded);
      hand.addListener(CardMessage.CARD_MOVING, hand_cardMoving);
    }

    private function removeHandListeners(hand:HandView):void {
      hand.removeListener(CardMessage.CARD_CLICKED, hand_cardClicked);
      hand.removeListener(CardMessage.CARD_VIEW_ADDED, hand_cardViewAdded);
      hand.removeListener(CardMessage.CARD_MOVING, hand_cardMoving);
    }

    private function cleanupHands():void {
      for each(var hand:HandView in _hands.values)
        removeHandListeners(hand);

      _hands.clear();
    }

    private function scaleBackground(cw:Number, ch:Number):void {
      if(!_backgroundImage) return;

      var p:Number = ch / cw < _backgroundImage.height / _backgroundImage.width ? cw / _backgroundImage.width : ch / _backgroundImage.height;

      _backgroundImage.width *= p;
      _backgroundImage.height *= p;
      _backgroundImage.x = (cw - _backgroundImage.width) / 2;
      _backgroundImage.y = (ch - _backgroundImage.height) / 2;

      _backgroundImage.blendMode = BlendMode.NONE;
    }

    private function scalePlayLayer(newWidth:Number, newHeight:Number):void {
      var scaleX:Number = newWidth / appWidth;
      var scaleY:Number = newHeight / appHeight;
      var scale:Number = Math.min(scaleX, scaleY);

      _playLayer.scaleX = _playLayer.scaleY = scale;

      if(scale == scaleY) {
        _playLayer.x = (scaleX - scaleY) * appWidth / 2;
        _playLayer.y = 0;
      } else {
        _playLayer.x = 0;
        _playLayer.y = (scaleY - scaleX) * appHeight / 2;
      }
    }

    private function positionHands():void {
      for each(var hand:HandView in hands) {
        var position:Object = positions[hand.seat + seatIndexOffset];
        positionView(hand, position.x, position.y, hand.anchor);
      }
    }

    private function positionView(hand:HandView, xPos:Number, yPos:Number, anchor:String):void {
      hand.x = xPos;
      hand.y = yPos;

      switch(anchor) {
        case Anchor.LEFT:
          hand.x -= _playLayer.x / _playLayer.scaleX;
          break;
        case Anchor.RIGHT:
          hand.x += _playLayer.x / _playLayer.scaleX;
          break;
        case Anchor.TOP:
          hand.y -= _playLayer.y / _playLayer.scaleY;
          break;
        case Anchor.BOTTOM:
          hand.y += _playLayer.y / _playLayer.scaleY;
          break;
        case Anchor.BOTTOM_LEFT:
          hand.x -= _playLayer.x / _playLayer.scaleX;
          hand.y += _playLayer.y / _playLayer.scaleY;
          break;
      }
    }

    //
    // Event handlers
    //

    private function table_tableDisposed(message:CardMessage):void {
      dispose();
    }

    private function hand_cardClicked(message:CardMessage):void {
      handleCardSelected(message.cardId, message.handId);
    }

    private function hand_cardViewAdded(message:CardMessage):void {
      handleCardViewAdded(message.handId);
    }

    private function hand_cardMoving(message:CardMessage):void {
      moveCard(message.cardView, message.handId, message.options);
    }

    private function table_handCreated(event:CardMessage):void {
      addHand(event.hand);
    }

    private function addedToStage(event:Event):void {
      setBackground();
    }
  }
}