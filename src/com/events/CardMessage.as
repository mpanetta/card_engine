package com.events
{
  import com.core.messageBus.MessageBase;
  import com.models.Card;
  import com.models.Hand;
  import com.models.Table;
  import com.views.CardView;

  public class CardMessage extends MessageBase
  {
    //
    // Constants.
    //

    public static const CARD_FLIPPED:String = "CARD_MESSAGE_CARD_FLIPPED";
    public static const CARD_ADDED:String = "CARD_MESSAGE_CARD_ADDED";
    public static const CARD_REMOVED:String = "CARD_MESSAGE_CARD_REMOVED";
    public static const HAND_CREATED:String = "CARD_MESSAGE_HAND_CREATED";
    public static const TABLE_DISPOSED:String = "CARD_MESSAGE_TABLE_DISPOSED";
    public static const CARD_CLICKED:String = "CARD_MESSAGE_CARD_CLICKED";
    public static const CARD_RAISED:String = "CARD_MESSAGE_CARD_RAISED";
    public static const CARD_LOWERED:String = "CARD_MESSAGE_CARD_LOWERED";
    public static const HAND_SORTED:String = "CARD_MESSAGE_HAND_SORTED";
    public static const HAND_HIDE:String = "CARD_MESSAGE_HAND_HIDE";
    public static const ENABLED_CHANGED:String = "CARD_MESSAGE_ENABLED_CHANGED";
    public static const CARD_VIEW_ADDED:String = "CARD_MESSAGE_CARD_VIEW_ADDED";
    public static const CARD_MOVING:String = "CARD_MESSAGE_CARD_MOVING";
    public static const HAND_FAN:String = "CARD_MESSAGE_HAND_FAN";

    //
    // Instance variables.
    //

    //
    // Constructors.
    //

    public function CardMessage(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, data, bubbles, cancelable);
    }

    //
    // Getters and setters.
    //

    public function get hand():Hand { return data.hand; }
    public function get table():Table { return data.table; }
    public function get card():Card { return data.card; }
    public function get cardId():Number { return data.cardId; }
    public function get handId():Number { return data.handId; }
    public function get sortedCards():Array { return data.sortedCards; }
    public function get animate():Boolean { return data.animate; }
    public function get enabled():Boolean { return data.enabled; }
    public function get cardView():CardView { return data.cardView; }
    public function get options():Object { return data.options; }
    public function get moveIndex():int { return data.moveIndex; }

    //
    // Public methods.
    //

    //
    // Private methods.
    //

    //
    // Event handlers.
    //
  }
}