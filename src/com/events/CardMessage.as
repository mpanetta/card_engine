package com.events
{
  import com.core.messageBus.MessageBase;
  import com.models.Card;
  import com.models.Hand;
  import com.models.Table;

  public class CardMessage extends MessageBase
  {
    //
    // Constants.
    //

    public static const CARD_FLIPPED:String = "CARD_MESSAGE_CARD_FLIPPED";
    public static const CARD_ADDED:String = "CARD_MESSAGE_CARD_ADDED";
    public static const HAND_CREATED:String = "CARD_MESSAGE_HAND_CREATED";
    public static const TABLE_DISPOSED:String = "CARD_MESSAGE_TABLE_DISPOSED";

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