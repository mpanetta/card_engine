package com.events
{
  import com.core.messageBus.MessageBase;

  public class RoomMessage extends MessageBase
  {
    //
    // Constants
    //

    public static const JOIN_SUCCEEDED:String = 'ROOM_MESSAGE_JOIN_SUCCEEDED';
    public static const JOIN_FAILED:String = 'ROOM_MESSAGE_JOIN_FAILED';
    public static const INTERACT:String = 'ROOM_MESSAGE_INTERACT';

    // All of the below are sub_cmd's of INTERACT events and are here for conveience.
    // Note that the below events will fire in addition to the INTERACT event.
    // So make sure you don't process both.
    public static const SEAT:String        = 'ROOM_MESSAGE_SEAT';
    public static const LEAVING:String     = 'ROOM_MESSAGE_LEAVING';
    public static const START:String       = 'ROOM_MESSAGE_START';
    public static const TURN:String        = 'ROOM_MESSAGE_TURN';
    public static const BET:String         = 'ROOM_MESSAGE_BET';
    public static const HIT:String         = 'ROOM_MESSAGE_HIT';
    public static const BUST:String        = 'ROOM_MESSAGE_BUST';
    public static const STAND:String       = 'ROOM_MESSAGE_STAND';
    public static const SPLIT:String       = 'ROOM_MESSAGE_SPLIT';
    public static const DOUBLE:String      = 'ROOM_MESSAGE_DOUBLE';
    public static const INSURE:String      = 'ROOM_MESSAGE_INSURE';
    public static const DONT_INSURE:String = 'ROOM_MESSAGE_DONT_INSURE';
    public static const DEAL:String        = 'ROOM_MESSAGE_DEAL';
    public static const ROUND_END:String   = 'ROOM_MESSAGE_ROUND_END';
    public static const PAYOUT:String      = 'ROOM_MESSAGE_PAYOUT';
    public static const UNSEAT:String      = 'ROOM_MESSAGE_UNSEAT';
    public static const FLIP:String        = 'ROOM_MESSAGE_FLIP';
    public static const STATE:String       = 'ROOM_MESSAGE_STATE';
    public static const EXCEPTION:String   = 'ROOM_MESSAGE_EXCEPTION';

    public function RoomMessage(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
      super(type, data, bubbles, cancelable);
    }

    //
    // Getters and setters.
    //

    public function get eventId():Number { return data.event_id; }
    public function get playerId():String { return data.player_id; }
    public function get cardName():String { return data.card_name; }
    public function get gameId():Number { return data.game_id; }
    public function get handId():Number { return data.hand_id; }
    public function get roomName():String { return data.room_name; }
    public function get subCommand():String { return data.sub_cmd; }
    public function get visible():Boolean { return data.visible; }
    public function get scope():String { return data.scope; }
    public function get seat():Number { return data.seat; }
    public function get choices():Array { return data.choices; }
  }
}

